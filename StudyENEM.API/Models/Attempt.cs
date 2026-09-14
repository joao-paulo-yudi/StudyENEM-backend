namespace StudyENEM.API.Models;

/// <summary>Simulado realizado por um estudante (tabela <c>simulado</c>).</summary>
public class Attempt
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;

    /// <summary>"geral" (todas as áreas, formato ENEM) ou "foco" (uma área ou conteúdo).</summary>
    public string Mode { get; set; } = "geral";
    public int? AreaId { get; set; }
    public Area? Area { get; set; }
    public int? TopicId { get; set; }
    public Topic? Topic { get; set; }
    public string? ForeignLanguage { get; set; }

    public DateTime StartedAt { get; set; }
    public DateTime? FinishedAt { get; set; }
    /// <summary>Tempo limite do cronômetro; nulo quando o cronômetro está desligado.</summary>
    public int? TimeLimitSeconds { get; set; }
    public int? TimeTakenSeconds { get; set; }

    public ICollection<AttemptAnswer> Answers { get; set; } = new List<AttemptAnswer>();
    public ICollection<AttemptResult> Results { get; set; } = new List<AttemptResult>();
}
