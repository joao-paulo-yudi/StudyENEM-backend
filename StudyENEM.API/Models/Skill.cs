namespace StudyENEM.API.Models;

/// <summary>Habilidade da Matriz de Referência do ENEM (tabela <c>habilidade</c>).</summary>
public class Skill
{
    public int Id { get; set; }
    public int AreaId { get; set; }
    public Area Area { get; set; } = null!;
    /// <summary>Número da habilidade na matriz da área (H1 a H30).</summary>
    public int Code { get; set; }
    public int Competency { get; set; }
    public string Description { get; set; } = string.Empty;
}
