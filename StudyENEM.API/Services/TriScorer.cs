using StudyENEM.API.Models;

namespace StudyENEM.API.Services;

/// <summary>
/// Estimação da proficiência pela Teoria de Resposta ao Item (TRI), reproduzindo o
/// procedimento descrito pelo INEP para o ENEM ("Enem: procedimentos de análise"):
///
///   Modelo logístico de 3 parâmetros (ML3):
///     P(acerto | θ) = c + (1 − c) / (1 + e^(−a·(θ − b)))
///
///   Estimador EAP (Expected a Posteriori), priori normal padrão g(θ) e 40 pontos de quadratura:
///     θ̂ = Σ θₖ·L(θₖ)·g(θₖ) / Σ L(θₖ)·g(θₖ),   L(θ) = Π P(θ)^u · (1 − P(θ))^(1−u)
///
///   Nota na escala do ENEM (transformação linear por área, ver <see cref="TriScale"/>):
///     nota = intercepto + inclinação·θ̂
///
/// Questões em branco contam como erro, como no ENEM. Itens desconsiderados pelo INEP
/// (sem parâmetros) não entram na estimativa.
/// </summary>
public static class TriScorer
{
    public const int QuadraturePoints = 40;
    private const double GridMin = -4.0, GridMax = 4.0;

    private static readonly double[] Grid = Enumerable.Range(0, QuadraturePoints)
        .Select(k => GridMin + (GridMax - GridMin) * k / (QuadraturePoints - 1))
        .ToArray();

    private static readonly double[] LogPrior = Grid.Select(t => -t * t / 2).ToArray();

    public readonly record struct ItemResponse(double A, double B, double C, bool Correct);

    /// <summary>θ̂ (média a posteriori), desvio-padrão a posteriori e número de itens usados.</summary>
    public readonly record struct Estimate(double Theta, double StandardError, int Items);

    public static double Probability(double a, double b, double c, double theta) =>
        c + (1 - c) / (1 + Math.Exp(-a * (theta - b)));

    /// <summary>Retorna nulo quando não há itens com parâmetros.</summary>
    public static Estimate? EstimateTheta(IEnumerable<ItemResponse> responses)
    {
        var logPosterior = (double[])LogPrior.Clone();
        int items = 0;

        foreach (var r in responses)
        {
            items++;
            for (int k = 0; k < QuadraturePoints; k++)
            {
                double p = Math.Clamp(Probability(r.A, r.B, r.C, Grid[k]), 1e-12, 1 - 1e-12);
                logPosterior[k] += Math.Log(r.Correct ? p : 1 - p);
            }
        }
        if (items == 0) return null;

        // Normaliza em escala logarítmica para evitar underflow com muitos itens.
        double max = logPosterior.Max();
        double sumW = 0, sumT = 0, sumT2 = 0;
        for (int k = 0; k < QuadraturePoints; k++)
        {
            double w = Math.Exp(logPosterior[k] - max);
            sumW += w;
            sumT += w * Grid[k];
            sumT2 += w * Grid[k] * Grid[k];
        }
        double theta = sumT / sumW;
        double variance = Math.Max(sumT2 / sumW - theta * theta, 0);
        return new Estimate(theta, Math.Sqrt(variance), items);
    }

    public static double ToEnemScale(double theta, TriScale scale) => scale.Intercept + scale.Slope * theta;

    /// <summary>Converte o parâmetro de dificuldade b para a escala do ENEM (mesma transformação de θ).</summary>
    public static double DifficultyOnEnemScale(double b, TriScale scale) => ToEnemScale(b, scale);
}
