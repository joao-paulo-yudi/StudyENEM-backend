namespace StudyENEM.API.Models;

/// <summary>Disciplina de uma área (tabela <c>disciplina</c>).</summary>
public class Subject
{
    public int Id { get; set; }
    public int AreaId { get; set; }
    public Area Area { get; set; } = null!;
    public string Name { get; set; } = string.Empty;
    public ICollection<Topic> Topics { get; set; } = new List<Topic>();
}
