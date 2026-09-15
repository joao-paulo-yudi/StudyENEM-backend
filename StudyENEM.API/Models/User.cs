namespace StudyENEM.API.Models;

/// <summary>Estudante cadastrado (tabela <c>usuario</c>).</summary>
public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;

    /// <summary>Nulos nas contas criadas pelo login com Google, que não definem senha local.</summary>
    public string? PasswordHash { get; set; }
    public string? PasswordSalt { get; set; }

    /// <summary>Identificador do usuário no Google (claim <c>sub</c>), quando a conta está vinculada.</summary>
    public string? GoogleId { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public ICollection<Attempt> Attempts { get; set; } = new List<Attempt>();
}
