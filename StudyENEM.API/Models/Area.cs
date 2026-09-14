namespace StudyENEM.API.Models;

/// <summary>Área do conhecimento do ENEM (tabela <c>area</c>).</summary>
public class Area
{
    public int Id { get; set; }
    /// <summary>Sigla usada pelo INEP: LC, CH, CN ou MT.</summary>
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    /// <summary>Ordem da área na prova (LC, CH, CN, MT).</summary>
    public int Order { get; set; }
    public ICollection<Subject> Subjects { get; set; } = new List<Subject>();
}
