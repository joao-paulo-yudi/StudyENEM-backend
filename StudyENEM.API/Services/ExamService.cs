using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Data;
using StudyENEM.API.DTOs;
using StudyENEM.API.Models;

namespace StudyENEM.API.Services;

/// <summary>Simulados: montagem (RF02), correção e resultado (RF04) e histórico (RF08).</summary>
public class ExamService(AppDbContext db)
{
    private static readonly string[] ForeignLanguages = ["ingles", "espanhol"];

    public async Task<StartAttemptResponseDto> StartAttemptAsync(int userId, StartAttemptDto dto)
    {
        var mode = dto.Mode == "foco" ? "foco" : "geral";
        var language = ForeignLanguages.Contains(dto.ForeignLanguage) ? dto.ForeignLanguage! : "ingles";

        // Questões anuladas pelo INEP (sem gabarito) só entram na prova completa, para manter a
        // numeração original do caderno; elas não contam na correção.
        bool fullExam = mode == "geral" && dto.Count >= QuestionSelector.FullExamQuestions;
        var query = db.Questions
            .Include(q => q.Area)
            .Include(q => q.Subject)
            .Include(q => q.Topic)
            .Include(q => q.Alternatives)
            .Where(q => (fullExam || q.CorrectOption != null)
                        && (q.ForeignLanguage == null || q.ForeignLanguage == language));

        Area? area = null;
        Topic? topic = null;
        if (mode == "foco")
        {
            if (dto.TopicId is int topicId)
            {
                topic = await db.Topics.FindAsync(topicId) ?? throw new KeyNotFoundException("Conteúdo não encontrado.");
                query = query.Where(q => q.TopicId == topicId);
            }
            else if (!string.IsNullOrWhiteSpace(dto.AreaCode))
            {
                area = await db.Areas.FirstOrDefaultAsync(a => a.Code == dto.AreaCode)
                    ?? throw new KeyNotFoundException("Área não encontrada.");
                query = query.Where(q => q.AreaId == area.Id);
            }
            else
            {
                throw new ArgumentException("Informe a área ou o conteúdo do simulado focado.");
            }
        }

        var pool = await query.ToListAsync();
        var selected = QuestionSelector.Select(pool, balanceAreas: mode == "geral", dto.Count, Random.Shared);
        if (selected.Count == 0)
            throw new InvalidOperationException("Não há questões disponíveis para essa configuração.");

        var attempt = new Attempt
        {
            UserId = userId,
            Mode = mode,
            AreaId = area?.Id ?? (topic is null ? null : selected[0].AreaId),
            TopicId = topic?.Id,
            ForeignLanguage = language,
            StartedAt = DateTime.UtcNow,
            TimeLimitSeconds = dto.Timed ? selected.Count * QuestionSelector.SecondsPerQuestion : null,
        };
        int order = 0;
        foreach (var q in selected)
            attempt.Answers.Add(new AttemptAnswer { QuestionId = q.Id, Order = ++order });

        db.Attempts.Add(attempt);
        await db.SaveChangesAsync();

        return new StartAttemptResponseDto(attempt.Id, attempt.TimeLimitSeconds, selected.Select(q => new ExamQuestionDto(
            q.Id, q.Year, q.Number, q.Area.Code, q.Area.Name, q.Subject.Name, q.Topic.Name, q.ForeignLanguage, q.Statement,
            q.Alternatives.OrderBy(a => a.Letter).Select(a => new AlternativeDto(a.Letter, a.Text)).ToList()
        )).ToList());
    }

    public async Task<AttemptResultDto> SubmitAttemptAsync(int userId, int attemptId, SubmitAttemptDto dto)
    {
        var attempt = await db.Attempts
            .Include(a => a.Answers).ThenInclude(an => an.Question)
            .FirstOrDefaultAsync(a => a.Id == attemptId && a.UserId == userId)
            ?? throw new KeyNotFoundException("Simulado não encontrado.");
        if (attempt.FinishedAt is not null)
            throw new InvalidOperationException("Este simulado já foi finalizado.");

        var submitted = (dto.Answers ?? [])
            .GroupBy(a => a.QuestionId)
            .ToDictionary(g => g.Key, g => g.Last());

        foreach (var answer in attempt.Answers)
        {
            if (submitted.TryGetValue(answer.QuestionId, out var s))
            {
                answer.SelectedOption = NormalizeOption(s.SelectedOption);
                answer.TimeSpentSeconds = s.TimeSpentSeconds is >= 0 ? s.TimeSpentSeconds : null;
            }
            // Em branco conta como erro, como no ENEM.
            answer.IsCorrect = answer.SelectedOption is not null
                               && answer.Question.CorrectOption is not null
                               && answer.SelectedOption == answer.Question.CorrectOption;
        }

        attempt.FinishedAt = DateTime.UtcNow;
        attempt.TimeTakenSeconds = dto.TimeTakenSeconds is >= 0
            ? dto.TimeTakenSeconds
            : attempt.Answers.Sum(a => a.TimeSpentSeconds ?? 0);

        var scales = PerformanceCalculator.ScaleLookup(await db.TriScales.AsNoTracking().ToListAsync());
        foreach (var result in PerformanceCalculator.BuildAttemptResults(attempt.Answers, scales))
            attempt.Results.Add(result);

        await db.SaveChangesAsync();
        return (await GetAttemptResultAsync(userId, attemptId))!;
    }

    public async Task<AttemptResultDto?> GetAttemptResultAsync(int userId, int attemptId)
    {
        var attempt = await db.Attempts.AsNoTracking()
            .Include(a => a.Area)
            .Include(a => a.Topic)
            .Include(a => a.Results).ThenInclude(r => r.Area)
            .Include(a => a.Answers).ThenInclude(an => an.Question).ThenInclude(q => q.Area)
            .Include(a => a.Answers).ThenInclude(an => an.Question).ThenInclude(q => q.Subject)
            .Include(a => a.Answers).ThenInclude(an => an.Question).ThenInclude(q => q.Topic)
            .AsSplitQuery()
            .FirstOrDefaultAsync(a => a.Id == attemptId && a.UserId == userId);

        if (attempt?.FinishedAt is null) return null;

        var summary = ToSummary(attempt);
        var byTopic = attempt.Answers
            .Where(a => a.Question.CorrectOption is not null)
            .GroupBy(a => a.Question.TopicId)
            .Select(g =>
            {
                var q = g.First().Question;
                int total = g.Count(), correct = g.Count(a => a.IsCorrect);
                return new TopicResultDto(q.TopicId, q.Topic.Name, q.Subject.Name, q.Area.Code, total, correct,
                    PerformanceCalculator.Percentage(correct, total));
            })
            .OrderBy(t => t.Percentage).ThenByDescending(t => t.Total)
            .ToList();

        var answers = attempt.Answers.OrderBy(a => a.Order).Select(a => new AnswerResultDto(
            a.QuestionId, a.Order, a.Question.Year, a.Question.Number, a.Question.Area.Code,
            a.Question.Subject.Name, a.Question.Topic.Name,
            a.SelectedOption, a.Question.CorrectOption, a.IsCorrect, a.TimeSpentSeconds
        )).ToList();

        return new AttemptResultDto(
            attempt.Id, attempt.Mode, attempt.Area?.Code, attempt.Topic?.Name,
            attempt.StartedAt, attempt.FinishedAt.Value, attempt.TimeTakenSeconds,
            summary.Total, summary.Correct, summary.Percentage, summary.TriAverage,
            summary.ByArea, byTopic, answers);
    }

    public async Task<List<AttemptSummaryDto>> GetHistoryAsync(int userId)
    {
        var attempts = await db.Attempts.AsNoTracking()
            .Include(a => a.Area)
            .Include(a => a.Topic)
            .Include(a => a.Results).ThenInclude(r => r.Area)
            .Where(a => a.UserId == userId && a.FinishedAt != null)
            .OrderByDescending(a => a.FinishedAt)
            .ToListAsync();

        return attempts.Select(ToSummary).ToList();
    }

    /// <summary>Resumo de um simulado finalizado; exige <c>Results.Area</c>, <c>Area</c> e <c>Topic</c> carregados.</summary>
    internal static AttemptSummaryDto ToSummary(Attempt attempt)
    {
        var results = attempt.Results.OrderBy(r => r.Area.Order).ToList();
        int total = results.Sum(r => r.TotalQuestions);
        int correct = results.Sum(r => r.TotalCorrect);

        return new AttemptSummaryDto(
            attempt.Id, attempt.FinishedAt!.Value, attempt.Mode, attempt.Area?.Code, attempt.Topic?.Name,
            total, correct, PerformanceCalculator.Percentage(correct, total),
            PerformanceCalculator.TriAverage(results.Select(r => r.TriScore)),
            attempt.TimeTakenSeconds,
            results.Select(r => new AreaResultDto(
                r.Area.Code, r.Area.Name, r.TotalQuestions, r.TotalCorrect, r.Percentage,
                r.TriScore is double score ? new TriScoreDto(score, r.TriStandardError ?? 0, r.TriItems) : null,
                r.AverageTimeSeconds
            )).ToList());
    }

    private static char? NormalizeOption(char? option)
    {
        if (option is null) return null;
        char c = char.ToUpperInvariant(option.Value);
        return c is >= 'A' and <= 'E' ? c : null;
    }
}
