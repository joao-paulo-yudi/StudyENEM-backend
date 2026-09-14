namespace StudyENEM.API.Models;

/// <summary>Estudante cadastrado (tabela <c>usuario</c>).</summary>
public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string PasswordSalt { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public ICollection<Attempt> Attempts { get; set; } = new List<Attempt>();
}
