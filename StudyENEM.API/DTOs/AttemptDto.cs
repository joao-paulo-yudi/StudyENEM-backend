namespace StudyENEM.API.DTOs;

/// <summary>
/// Configuração do simulado. Mode: "geral" (questões de todas as áreas, na ordem do ENEM)
/// ou "foco" (uma área via AreaCode ou um conteúdo via TopicId).
/// </summary>
public record StartAttemptDto(string Mode, int Count, string? AreaCode, int? TopicId, string? ForeignLanguage, bool Timed);

/// <summary>Questão apresentada no simulado (sem gabarito).</summary>
public record ExamQuestionDto(
    int Id,
    int Year,
    int Number,
    string AreaCode,
    string AreaName,
    string Subject,
    string Topic,
    string? ForeignLanguage,
    string Statement,
    List<AlternativeDto> Alternatives
);

public record StartAttemptResponseDto(int AttemptId, int? TimeLimitSeconds, List<ExamQuestionDto> Questions);

/// <summary>SelectedOption nulo = questão em branco (conta como erro, como no ENEM).</summary>
public record SubmitAnswerDto(int QuestionId, char? SelectedOption, int? TimeSpentSeconds);

public record SubmitAttemptDto(int? TimeTakenSeconds, List<SubmitAnswerDto> Answers);

/// <summary>Nota estimada pela TRI na escala do ENEM, erro-padrão e itens usados.</summary>
public record TriScoreDto(double Score, double StandardError, int Items);

public record AreaResultDto(
    string AreaCode,
    string AreaName,
    int Total,
    int Correct,
    double Percentage,
    TriScoreDto? Tri,
    double? AverageTimeSeconds
);

public record TopicResultDto(int TopicId, string Topic, string Subject, string AreaCode, int Total, int Correct, double Percentage);

public record AnswerResultDto(
    int QuestionId,
    int Order,
    int Year,
    int Number,
    string AreaCode,
    string Subject,
    string Topic,
    char? SelectedOption,
    char? CorrectOption,
    bool IsCorrect,
    int? TimeSpentSeconds
);

public record AttemptResultDto(
    int AttemptId,
    string Mode,
    string? AreaCode,
    string? Topic,
    DateTime StartedAt,
    DateTime FinishedAt,
    int? TimeTakenSeconds,
    int TotalQuestions,
    int CorrectAnswers,
    double Percentage,
    double? TriAverage,
    List<AreaResultDto> ByArea,
    List<TopicResultDto> ByTopic,
    List<AnswerResultDto> Answers
);

public record AttemptSummaryDto(
    int AttemptId,
    DateTime Date,
    string Mode,
    string? AreaCode,
    string? Topic,
    int Total,
    int Correct,
    double Percentage,
    double? TriAverage,
    int? TimeTakenSeconds,
    List<AreaResultDto> ByArea
);
