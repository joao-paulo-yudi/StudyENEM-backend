namespace StudyENEM.API.Models;

/// <summary>
/// Fonte de estudo externa recomendada pelo plano (tabela <c>recurso</c>): um canal do
/// YouTube, um banco de exercícios ou um material de apoio. O catálogo é curado por
/// disciplina — e, quando faz sentido, por conteúdo — e a busca dentro da fonte é montada
/// em tempo de execução por <see cref="Services.StudyResourceRecommender"/>.
/// </summary>
public class StudyResource
{
    public int Id { get; set; }

    /// <summary>Disciplina atendida pela fonte; nula quando ela serve a qualquer disciplina.</summary>
    public int? SubjectId { get; set; }
    public Subject? Subject { get; set; }

    /// <summary>Conteúdo específico; nulo quando a fonte vale para toda a disciplina.</summary>
    public int? TopicId { get; set; }
    public Topic? Topic { get; set; }

    /// <summary>"video", "exercicio" ou "material".</summary>
    public string Kind { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    /// <summary>Nome do canal ou do site, exibido como origem da recomendação.</summary>
    public string Provider { get; set; } = string.Empty;

    /// <summary>
    /// URL da fonte. O marcador <c>{consulta}</c> é substituído pelo nome do conteúdo
    /// priorizado, o que direciona a busca para o assunto em que o estudante errou mais.
    /// </summary>
    public string UrlTemplate { get; set; } = string.Empty;

    public string? Description { get; set; }
    /// <summary>Ordem de exibição dentro do mesmo tipo.</summary>
    public int Order { get; set; }
}
