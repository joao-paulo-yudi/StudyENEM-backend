using StudyENEM.API.Models;

namespace StudyENEM.API.Services;

/// <summary>Seleção das questões de um simulado.</summary>
public static class QuestionSelector
{
    /// <summary>
    /// Tempo de referência por questão para o cronômetro: 3 minutos, próximo ao do ENEM
    /// (5 h para as 90 questões do 2º dia).
    /// </summary>
    public const int SecondsPerQuestion = 180;

    /// <summary>Quantidade de questões objetivas de uma edição completa do ENEM.</summary>
    public const int FullExamQuestions = 180;

    /// <summary>
    /// Sorteia <paramref name="count"/> questões do conjunto. No simulado geral as vagas são
    /// distribuídas igualmente entre as áreas (180 questões = prova completa). O resultado é
    /// ordenado como no caderno do ENEM: LC, CH, CN, MT e, dentro da área, pelo número da questão.
    /// </summary>
    public static List<Question> Select(IReadOnlyList<Question> pool, bool balanceAreas, int count, Random rng)
    {
        if (pool.Count == 0) return [];
        count = Math.Clamp(count, 1, pool.Count);

        List<Question> chosen;
        if (!balanceAreas)
        {
            chosen = pool.OrderBy(_ => rng.Next()).Take(count).ToList();
        }
        else
        {
            var byArea = pool
                .GroupBy(q => q.Area.Order)
                .OrderBy(g => g.Key)
                .Select(g => g.OrderBy(_ => rng.Next()).ToList())
                .ToList();

            var quotas = new int[byArea.Count];
            for (int remaining = count; remaining > 0;)
            {
                bool assigned = false;
                for (int i = 0; i < byArea.Count && remaining > 0; i++)
                {
                    if (quotas[i] >= byArea[i].Count) continue;
                    quotas[i]++;
                    remaining--;
                    assigned = true;
                }
                if (!assigned) break;
            }
            chosen = byArea.SelectMany((questions, i) => questions.Take(quotas[i])).ToList();
        }

        return chosen
            .OrderBy(q => q.Area.Order)
            .ThenBy(q => q.Year)
            .ThenBy(q => q.Number)
            .ToList();
    }
}
