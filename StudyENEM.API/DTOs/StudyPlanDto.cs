namespace StudyENEM.API.DTOs;

/// <summary>
/// Plano de estudos (RF06): os conteúdos ordenados pelo índice de dificuldade do histórico,
/// com o esforço sugerido, as fontes de estudo recomendadas e um cronograma semanal.
/// </summary>
public record StudyPlanDto(
    int TotalTopics,
    int HighPriority,
    int MediumPriority,
    int LowPriority,
    // Soma do tempo sugerido para os conteúdos do plano.
    int EstimatedMinutes,
    // Conteúdos com menor aproveitamento, em ordem de prioridade.
    List<StudyPlanItemDto> Items,
    List<StudyPlanDayDto> Schedule
);

/// <summary>Um conteúdo do plano, com o esforço sugerido e as fontes de estudo.</summary>
public record StudyPlanItemDto(
    int TopicId,
    string Topic,
    string Subject,
    string AreaCode,
    string Priority,
    double DifficultyIndex,
    int Mastery,
    int Attempts,
    string Reason,
    // Posição do conteúdo na ordem sugerida de estudo (1 = comece por aqui).
    int Step,
    // Tempo de estudo sugerido, proporcional ao índice de dificuldade.
    int EstimatedMinutes,
    // Quantidade de questões sugerida para o treino do conteúdo.
    int RecommendedQuestions,
    // Vídeos, exercícios e materiais recomendados; vazia no resumo do dashboard.
    List<StudyResourceDto> Resources
);

/// <summary>Fonte de estudo recomendada, já com a busca do conteúdo aplicada à URL.</summary>
public record StudyResourceDto(
    string Kind,
    string Title,
    string Provider,
    string Url,
    string? Description
);

/// <summary>Um dia do cronograma semanal sugerido.</summary>
public record StudyPlanDayDto(
    string Day,
    int TotalMinutes,
    List<StudyPlanTaskDto> Tasks
);

/// <summary>Tarefa do cronograma: o que estudar, por quanto tempo e de que forma.</summary>
public record StudyPlanTaskDto(
    // Nulo nas tarefas que não são de um conteúdo (o simulado e a revisão de domingo).
    int? TopicId,
    string Topic,
    string Subject,
    string? AreaCode,
    string Activity,
    int Minutes,
    // Para onde o botão da tarefa leva: "treinar", "simulado" ou "revisar".
    string Action
);
