using System.Globalization;
using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Data;
using StudyENEM.API.DTOs;

namespace StudyENEM.API.Services;

/// <summary>Indicadores do dashboard (RF05) e plano de estudos (RF06).</summary>
public class DashboardService(AppDbContext db)
{
    private static readonly CultureInfo PtBr = new("pt-BR");

    public async Task<PerformanceSummaryDto> GetSummaryAsync(int userId)
    {
        var user = await db.Users.FindAsync(userId) ?? throw new KeyNotFoundException("Usuário não encontrado.");

        var attempts = await db.Attempts.AsNoTracking()
            .Include(a => a.Area)
            .Include(a => a.Topic)
            .Include(a => a.Results).ThenInclude(r => r.Area)
            .Include(a => a.Answers).ThenInclude(an => an.Question).ThenInclude(q => q.Area)
            .Include(a => a.Answers).ThenInclude(an => an.Question).ThenInclude(q => q.Subject)
            .Include(a => a.Answers).ThenInclude(an => an.Question).ThenInclude(q => q.Topic)
            .AsSplitQuery()
            .Where(a => a.UserId == userId && a.FinishedAt != null)
            .OrderByDescending(a => a.FinishedAt)
            .ToListAsync();

        var scales = PerformanceCalculator.ScaleLookup(await db.TriScales.AsNoTracking().ToListAsync());
        // Questões anuladas pelo INEP (presentes apenas na prova completa) não contam nos indicadores.
        var answers = attempts.SelectMany(a => a.Answers).Where(a => a.Question.CorrectOption != null).ToList();

        // Para a proficiência TRI acumulada, cada questão entra uma única vez (resposta mais recente),
        // preservando a independência local entre itens pressuposta pelo modelo.
        var latestAnswers = answers.GroupBy(a => a.QuestionId).Select(g => g.First()).ToList();

        var byArea = answers
            .GroupBy(a => a.Question.AreaId)
            .Select(g =>
            {
                var area = g.First().Question.Area;
                int total = g.Count(), correct = g.Count(a => a.IsCorrect);
                return (area.Order, Dto: new AreaPerformanceDto(
                    area.Code, area.Name, total, correct,
                    PerformanceCalculator.Percentage(correct, total),
                    PerformanceCalculator.EstimateAreaScore(latestAnswers.Where(a => a.Question.AreaId == g.Key), scales),
                    PerformanceCalculator.AverageTime(g)));
            })
            .OrderBy(x => x.Order)
            .Select(x => x.Dto)
            .ToList();

        var bySubject = answers
            .GroupBy(a => a.Question.SubjectId)
            .Select(g =>
            {
                var q = g.First().Question;
                int total = g.Count(), correct = g.Count(a => a.IsCorrect);
                return new SubjectPerformanceDto(q.Subject.Name, q.Area.Code, total, correct, PerformanceCalculator.Percentage(correct, total));
            })
            .OrderBy(s => s.Percentage)
            .ToList();

        var byTopic = answers
            .GroupBy(a => a.Question.TopicId)
            .Select(g =>
            {
                var q = g.First().Question;
                int total = g.Count(), correct = g.Count(a => a.IsCorrect);
                return new TopicPerformanceDto(
                    q.TopicId, q.Topic.Name, q.Subject.Name, q.Area.Code, total, correct,
                    PerformanceCalculator.Percentage(correct, total),
                    PerformanceCalculator.DifficultyIndex(correct, total),
                    PerformanceCalculator.AverageTime(g));
            })
            .OrderByDescending(t => t.DifficultyIndex).ThenByDescending(t => t.Total)
            .ToList();

        var studyPlan = byTopic.Select(t =>
        {
            int wrong = t.Total - t.Correct;
            string reason = $"{wrong} {(wrong == 1 ? "erro" : "erros")} em {t.Total} {(t.Total == 1 ? "questão" : "questões")} · " +
                            $"índice de dificuldade {t.DifficultyIndex.ToString("0.00", PtBr)}";
            return new StudyPlanItemDto(
                t.TopicId, t.Topic, t.Subject, t.AreaCode,
                PerformanceCalculator.Priority(t.DifficultyIndex),
                t.DifficultyIndex, (int)Math.Round(t.Percentage), t.Total, reason);
        }).ToList();

        var history = attempts.Select(ExamService.ToSummary).ToList();
        ComparisonDto? comparison = history.Count >= 2
            ? new ComparisonDto(
                Math.Round(history[0].Percentage, 1),
                Math.Round(history[1].Percentage, 1),
                Math.Round(history[0].Percentage - history[1].Percentage, 1),
                history[0].TriAverage is double last && history[1].TriAverage is double previous
                    ? Math.Round(last - previous, 1)
                    : null)
            : null;

        return new PerformanceSummaryDto(
            user.Name,
            attempts.Count,
            answers.Count,
            answers.Count(a => a.IsCorrect),
            attempts.Sum(a => a.TimeTakenSeconds ?? 0),
            PerformanceCalculator.AverageTime(answers),
            PerformanceCalculator.TriAverage(byArea.Select(a => a.Tri?.Score)),
            byArea, bySubject, byTopic, history, comparison, studyPlan);
    }
}
