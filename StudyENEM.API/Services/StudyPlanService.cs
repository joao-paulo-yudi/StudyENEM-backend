using System.Globalization;
using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Data;
using StudyENEM.API.DTOs;

namespace StudyENEM.API.Services;

/// <summary>
/// Plano de estudos (RF06). Ordena os conteúdos pelo índice de dificuldade do histórico de
/// respostas, dimensiona o esforço sugerido para cada um, anexa as fontes de estudo
/// recomendadas (vídeos, exercícios e materiais) e distribui tudo num cronograma semanal.
/// </summary>
public class StudyPlanService(AppDbContext db)
{
    private static readonly CultureInfo PtBr = new("pt-BR");

    /// <summary>Dias de estudo do cronograma; o domingo fica reservado ao simulado e à revisão.</summary>
    private static readonly string[] StudyDays = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"];

    /// <summary>Carga diária que o cronograma tenta respeitar; um dia só recebe mais um
    /// conteúdo enquanto estiver abaixo dela.</summary>
    private const int DailyMinutesTarget = 120;

    public async Task<StudyPlanDto> GetPlanAsync(int userId)
    {
        var answers = await db.AttemptAnswers.AsNoTracking()
            .Include(a => a.Question).ThenInclude(q => q.Area)
            .Include(a => a.Question).ThenInclude(q => q.Subject)
            .Include(a => a.Question).ThenInclude(q => q.Topic)
            .AsSplitQuery()
            // Questões anuladas pelo INEP não entram nos indicadores.
            .Where(a => a.Attempt.UserId == userId && a.Attempt.FinishedAt != null && a.Question.CorrectOption != null)
            .ToListAsync();

        var byTopic = PerformanceCalculator.ByTopic(answers);
        var catalog = await db.StudyResources.AsNoTracking().ToListAsync();

        // O conteúdo guarda a disciplina, necessária para escolher as fontes especializadas.
        var subjectByTopic = answers
            .GroupBy(a => a.Question.TopicId)
            .ToDictionary(g => g.Key, g => g.First().Question.SubjectId);

        var items = BuildItems(byTopic)
            .Select(item => item with
            {
                Resources = StudyResourceRecommender.Recommend(
                    item.TopicId, subjectByTopic.GetValueOrDefault(item.TopicId), item.Topic, catalog),
            })
            .ToList();

        return new StudyPlanDto(
            items.Count,
            items.Count(i => i.Priority == "alta"),
            items.Count(i => i.Priority == "média"),
            items.Count(i => i.Priority == "baixa"),
            items.Sum(i => i.EstimatedMinutes),
            items,
            BuildSchedule(items));
    }

    /// <summary>
    /// Itens do plano sem as fontes de estudo, como aparecem no resumo do dashboard.
    /// Os conteúdos já chegam ordenados pelo índice de dificuldade.
    /// </summary>
    public static List<StudyPlanItemDto> BuildItems(IEnumerable<TopicPerformanceDto> byTopic) =>
        byTopic.Select((t, index) =>
        {
            int wrong = t.Total - t.Correct;
            string reason = $"{wrong} {(wrong == 1 ? "erro" : "erros")} em {t.Total} {(t.Total == 1 ? "questão" : "questões")} · " +
                            $"índice de dificuldade {t.DifficultyIndex.ToString("0.00", PtBr)}";
            return new StudyPlanItemDto(
                t.TopicId, t.Topic, t.Subject, t.AreaCode,
                PerformanceCalculator.Priority(t.DifficultyIndex),
                t.DifficultyIndex, (int)Math.Round(t.Percentage), t.Total, reason,
                index + 1,
                EstimatedMinutes(t.DifficultyIndex),
                RecommendedQuestions(t.DifficultyIndex),
                []);
        }).ToList();

    /// <summary>Tempo sugerido: 30 min de base, crescendo até 75 min conforme o índice de dificuldade.</summary>
    public static int EstimatedMinutes(double difficultyIndex) =>
        (int)Math.Round((30 + difficultyIndex * 45) / 5) * 5;

    /// <summary>Treino sugerido, na mesma escala de prioridade do índice de dificuldade.</summary>
    public static int RecommendedQuestions(double difficultyIndex) =>
        difficultyIndex >= 0.6 ? 15 : difficultyIndex >= 0.4 ? 10 : 5;

    /// <summary>
    /// Cronograma da semana. Os conteúdos entram por ordem de prioridade e cada um vai para
    /// o dia mais vago que ainda não tem a sua área, de modo que a semana não concentre a
    /// mesma matéria num dia só nem ultrapasse muito a carga diária. A distribuição para
    /// quando todos os dias atingem <see cref="DailyMinutesTarget"/>; o domingo fecha a
    /// semana com um simulado e a revisão dos erros.
    /// </summary>
    public static List<StudyPlanDayDto> BuildSchedule(IReadOnlyList<StudyPlanItemDto> items)
    {
        var week = StudyDays.Select(_ => new List<StudyPlanTaskDto>()).ToList();

        foreach (var item in items)
        {
            if (ChooseDay(week, item.AreaCode) is not int day) break;
            week[day].Add(new StudyPlanTaskDto(
                item.TopicId, item.Topic, item.Subject, item.AreaCode,
                Activity(item), item.EstimatedMinutes, "treinar"));
        }

        var days = week
            .Select((tasks, index) => new StudyPlanDayDto(StudyDays[index], tasks.Sum(t => t.Minutes), tasks))
            .Where(d => d.Tasks.Count > 0)
            .ToList();

        if (days.Count > 0)
        {
            List<StudyPlanTaskDto> sunday =
            [
                new(null, "Simulado da semana", "Todas as áreas", null,
                    "Faça um simulado para medir o efeito da semana de estudos.", 90, "simulado"),
                new(null, "Revisão dos erros", "Todas as áreas", null,
                    "Releia as questões erradas do simulado e refaça as que ainda gerarem dúvida.", 30, "revisar"),
            ];
            days.Add(new StudyPlanDayDto("Domingo", sunday.Sum(t => t.Minutes), sunday));
        }

        return days;
    }

    /// <summary>
    /// Dia que recebe o próximo conteúdo: entre os que ainda não fecharam a carga diária,
    /// prefere um sem a área do conteúdo e, entre esses, o mais vago. Devolve <c>null</c>
    /// quando a semana já está cheia.
    /// </summary>
    private static int? ChooseDay(IReadOnlyList<List<StudyPlanTaskDto>> week, string areaCode)
    {
        var open = Enumerable.Range(0, week.Count)
            .Where(day => week[day].Sum(t => t.Minutes) < DailyMinutesTarget)
            .ToList();

        if (open.Count == 0) return null;

        return open
            .OrderBy(day => week[day].Any(t => t.AreaCode == areaCode) ? 1 : 0)
            .ThenBy(day => week[day].Sum(t => t.Minutes))
            .ThenBy(day => day)
            .First();
    }

    private static string Activity(StudyPlanItemDto item) => item.Priority switch
    {
        "alta" => $"Assista à videoaula, faça um resumo e resolva {item.RecommendedQuestions} questões.",
        "média" => $"Revise a teoria e resolva {item.RecommendedQuestions} questões do conteúdo.",
        _ => $"Treino rápido: {item.RecommendedQuestions} questões para não perder o ritmo.",
    };
}
