namespace StudyENEM.API.Models;

/// <summary>Alternativa de uma questão (tabela <c>alternativa</c>).</summary>
public class Alternative
{
    public int Id { get; set; }
    public int QuestionId { get; set; }
    public Question Question { get; set; } = null!;
    public char Letter { get; set; }
    /// <summary>Texto da alternativa em Markdown (pode conter imagem).</summary>
    public string Text { get; set; } = string.Empty;
}
