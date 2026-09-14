using StudyENEM.API.DTOs;
using StudyENEM.API.Models;

namespace StudyENEM.API.Services;

/// <summary>
/// Cálculos de desempenho compartilhados entre a correção dos simulados, o dashboard
/// e o histórico de demonstração. As respostas precisam vir com <c>Question</c> carregada.
/// </summary>
public static class PerformanceCalculator
{
    public static IReadOnlyDictionary<(int AreaId, int Year), TriScale> ScaleLookup(IEnumerable<TriScale> scales) =>
        scales.ToDictionary(s => (s.AreaId, s.Year));

    public static double Percentage(int correct, int total) =>
        total > 0 ? Math.Round(100.0 * correct / total, 1) : 0;

    /// <summary>
    /// Resultado por área de um simulado (linhas da tabela <c>resultado</c>).
    /// Questões anuladas pelo INEP (sem gabarito) não entram na correção.
    /// </summary>
    public static List<AttemptResult> BuildAttemptResults(
        IEnumerable<AttemptAnswer> answers,
        IReadOnlyDictionary<(int AreaId, int Year), TriScale> scales)
    {
        return answers
            .Where(a => a.Question.CorrectOption is not null)
            .GroupBy(a => a.Question.AreaId)
            .Select(g =>
            {
                var list = g.ToList();
                int correct = list.Count(a => a.IsCorrect);
                var tri = EstimateAreaScore(list, scales);
                return new AttemptResult
                {
                    AreaId = g.Key,
                    TotalQuestions = list.Count,
                    TotalCorrect = correct,
                    Percentage = Percentage(correct, list.Count),
                    TriScore = tri?.Score,
                    TriStandardError = tri?.StandardError,
                    TriItems = tri?.Items ?? 0,
                    AverageTimeSeconds = AverageTime(list),
                };
            })
            .ToList();
    }

    /// <summary>
    /// Nota TRI de uma área. Cada ano de prova tem sua própria escala, então a estimativa é feita
    /// por ano e as notas são combinadas ponderando pelo inverso da variância.
    /// </summary>
    public static TriScoreDto? EstimateAreaScore(
        IEnumerable<AttemptAnswer> answers,
        IReadOnlyDictionary<(int AreaId, int Year), TriScale> scales)
    {
        double sumWeights = 0, sumScores = 0;
        int items = 0;

        foreach (var byYear in answers.Where(a => a.Question.HasTriParameters).GroupBy(a => (a.Question.AreaId, a.Question.Year)))
        {
            if (!scales.TryGetValue(byYear.Key, out var scale)) continue;

            var estimate = TriScorer.EstimateTheta(byYear.Select(a => new TriScorer.ItemResponse(
                a.Question.TriA!.Value, a.Question.TriB!.Value, a.Question.TriC!.Value, a.IsCorrect)));
            if (estimate is null) continue;

            double score = TriScorer.ToEnemScale(estimate.Value.Theta, scale);
            double se = Math.Max(scale.Slope * estimate.Value.StandardError, 1e-3);
            double weight = 1 / (se * se);
            sumWeights += weight;
            sumScores += weight * score;
            items += estimate.Value.Items;
        }

        if (items == 0) return null;
        return new TriScoreDto(Math.Round(sumScores / sumWeights, 1), Math.Round(Math.Sqrt(1 / sumWeights), 1), items);
    }

    /// <summary>Média simples das notas das áreas (como a média das provas objetivas do ENEM).</summary>
    public static double? TriAverage(IEnumerable<double?> areaScores)
    {
        var values = areaScores.Where(s => s.HasValue).Select(s => s!.Value).ToList();
        return values.Count > 0 ? Math.Round(values.Average(), 1) : null;
    }

    public static double? AverageTime(IEnumerable<AttemptAnswer> answers)
    {
        var times = answers.Where(a => a.TimeSpentSeconds.HasValue).Select(a => (double)a.TimeSpentSeconds!.Value).ToList();
        return times.Count > 0 ? Math.Round(times.Average(), 1) : null;
    }

    /// <summary>Índice de dificuldade do conteúdo: proporção de erros no histórico (0 a 1).</summary>
    public static double DifficultyIndex(int correct, int total) =>
        total > 0 ? Math.Round((double)(total - correct) / total, 2) : 0;

    public static string Priority(double difficultyIndex) =>
        difficultyIndex >= 0.6 ? "alta" : difficultyIndex >= 0.4 ? "média" : "baixa";
}
