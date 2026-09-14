namespace StudyENEM.API.Models;

/// <summary>Resposta de uma questão em um simulado (tabela <c>resposta</c>).</summary>
public class AttemptAnswer
{
    public int Id { get; set; }
    public int AttemptId { get; set; }
    public Attempt Attempt { get; set; } = null!;
    public int QuestionId { get; set; }
    public Question Question { get; set; } = null!;
    /// <summary>Posição da questão dentro do simulado.</summary>
    public int Order { get; set; }
    /// <summary>Alternativa marcada; nula quando a questão ficou em branco.</summary>
    public char? SelectedOption { get; set; }
    public bool IsCorrect { get; set; }
    /// <summary>Tempo (s) em que a questão ficou aberta na tela.</summary>
    public int? TimeSpentSeconds { get; set; }
}
