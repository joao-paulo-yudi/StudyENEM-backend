namespace StudyENEM.API.Models;

/// <summary>Desempenho de um simulado agregado por área (tabela <c>resultado</c>).</summary>
public class AttemptResult
{
    public int Id { get; set; }
    public int AttemptId { get; set; }
    public Attempt Attempt { get; set; } = null!;
    public int AreaId { get; set; }
    public Area Area { get; set; } = null!;

    public int TotalQuestions { get; set; }
    public int TotalCorrect { get; set; }
    public double Percentage { get; set; }

    /// <summary>Nota estimada na escala do ENEM pela TRI; nula se nenhum item tem parâmetros.</summary>
    public double? TriScore { get; set; }
    public double? TriStandardError { get; set; }
    /// <summary>Quantidade de itens com parâmetros TRI usados na estimativa.</summary>
    public int TriItems { get; set; }

    public double? AverageTimeSeconds { get; set; }
}
