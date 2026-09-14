namespace StudyENEM.API.DTOs;

/// <summary>
/// Indicadores de desempenho (métricas da Seção 3.1.2 do relatório):
/// (i) taxa de acerto por área; (ii) taxa de acerto por conteúdo; (iii) evolução temporal
/// (histórico por simulado e por área); (iv) índice de dificuldade por conteúdo;
/// (v) tempo médio por questão; e a nota estimada pela TRI por área.
/// </summary>
public record PerformanceSummaryDto(
    string StudentName,
    int TotalAttempts,
    int TotalQuestions,
    int TotalCorrect,
    int TotalTimeSeconds,
    double? AverageTimePerQuestion,
    double? TriAverage,
    List<AreaPerformanceDto> ByArea,
    List<SubjectPerformanceDto> BySubject,
    List<TopicPerformanceDto> ByTopic,
    List<AttemptSummaryDto> History,
    ComparisonDto? LastComparison,
    List<StudyPlanItemDto> StudyPlan
);

/// <summary>Tri: proficiência acumulada, estimada com a resposta mais recente de cada questão da área.</summary>
public record AreaPerformanceDto(
    string AreaCode,
    string AreaName,
    int Total,
    int Correct,
    double Percentage,
    TriScoreDto? Tri,
    double? AverageTimeSeconds
);

public record SubjectPerformanceDto(string Subject, string AreaCode, int Total, int Correct, double Percentage);

/// <summary>DifficultyIndex = erros / questões respondidas no conteúdo (0 a 1), acumulado no histórico.</summary>
public record TopicPerformanceDto(
    int TopicId,
    string Topic,
    string Subject,
    string AreaCode,
    int Total,
    int Correct,
    double Percentage,
    double DifficultyIndex,
    double? AverageTimeSeconds
);

/// <summary>Variação do último simulado em relação ao anterior.</summary>
public record ComparisonDto(double PercentageDelta, double? TriAverageDelta);

public record StudyPlanItemDto(
    int TopicId,
    string Topic,
    string Subject,
    string AreaCode,
    string Priority,
    double DifficultyIndex,
    int Mastery,
    int Attempts,
    string Reason
);
