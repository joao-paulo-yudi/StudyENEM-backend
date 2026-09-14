namespace StudyENEM.API.Models;

/// <summary>Conteúdo (objeto de conhecimento) de uma disciplina (tabela <c>conteudo</c>).</summary>
public class Topic
{
    public int Id { get; set; }
    public int SubjectId { get; set; }
    public Subject Subject { get; set; } = null!;
    public string Name { get; set; } = string.Empty;
}
