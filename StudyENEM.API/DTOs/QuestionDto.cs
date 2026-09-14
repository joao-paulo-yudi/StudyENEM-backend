namespace StudyENEM.API.DTOs;

// ── Catálogo (filtros do banco de questões e do simulado) ──────────────────
public record TopicDto(int Id, string Name, int QuestionCount);
public record SubjectDto(int Id, string Name, List<TopicDto> Topics);
public record AreaCatalogDto(int Id, string Code, string Name, int QuestionCount, List<SubjectDto> Subjects);
public record QuestionCatalogDto(List<int> Years, List<AreaCatalogDto> Areas);

public record AlternativeDto(char Letter, string Text);

/// <summary>Questão do banco de questões, com gabarito e metadados do INEP.</summary>
public record QuestionBankItemDto(
    int Id,
    int Year,
    int Number,
    int Day,
    string AreaCode,
    string AreaName,
    int SubjectId,
    string Subject,
    int TopicId,
    string Topic,
    string? ForeignLanguage,
    int Skill,
    string SkillDescription,
    string Statement,
    List<AlternativeDto> Alternatives,
    char? CorrectOption,
    /// <summary>Parâmetro b convertido para a escala do ENEM (dificuldade do item).</summary>
    double? TriDifficulty,
    string? TriExclusionReason
);
