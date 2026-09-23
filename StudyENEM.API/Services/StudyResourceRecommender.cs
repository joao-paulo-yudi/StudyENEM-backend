using System.Text.RegularExpressions;
using StudyENEM.API.DTOs;
using StudyENEM.API.Models;

namespace StudyENEM.API.Services;

/// <summary>
/// Escolhe as fontes de estudo de um conteúdo dentro do catálogo da tabela <c>recurso</c>
/// e monta a URL final, trocando o marcador <c>{consulta}</c> pelo nome do conteúdo.
/// A preferência é sempre pela fonte mais específica: primeiro as do próprio conteúdo,
/// depois as da disciplina e, por último, as gerais.
/// </summary>
public static partial class StudyResourceRecommender
{
    private const string QueryPlaceholder = "{consulta}";

    /// <summary>Quantas fontes de cada tipo entram na recomendação de um conteúdo.</summary>
    private static readonly Dictionary<string, int> LimitByKind = new()
    {
        // Os vídeos abrem espaço para uma quarta fonte, que é a busca geral do YouTube.
        ["video"] = 4, ["exercicio"] = 3, ["material"] = 2,
    };

    /// <summary>Ordem em que os tipos aparecem na tela.</summary>
    private static readonly string[] KindOrder = ["video", "exercicio", "material"];

    public static List<StudyResourceDto> Recommend(int topicId, int subjectId, string topicName, IReadOnlyList<StudyResource> catalog)
    {
        string query = BuildQuery(topicName);

        return catalog
            .Select(r => (Resource: r, Specificity: Specificity(r, topicId, subjectId)))
            .Where(x => x.Specificity >= 0)
            .GroupBy(x => x.Resource.Kind)
            .OrderBy(g => Array.IndexOf(KindOrder, g.Key))
            .SelectMany(g => g
                .OrderBy(x => x.Specificity)
                .ThenBy(x => x.Resource.Order)
                .ThenBy(x => x.Resource.Provider, StringComparer.Ordinal)
                .Take(LimitByKind.GetValueOrDefault(g.Key, 2)))
            .Select(x => new StudyResourceDto(
                x.Resource.Kind,
                x.Resource.Title,
                x.Resource.Provider,
                x.Resource.UrlTemplate.Replace(QueryPlaceholder, query, StringComparison.Ordinal),
                x.Resource.Description))
            .ToList();
    }

    /// <summary>0 para a fonte do próprio conteúdo, 1 para a da disciplina, 2 para a geral, -1 quando não se aplica.</summary>
    private static int Specificity(StudyResource resource, int topicId, int subjectId) => resource switch
    {
        { TopicId: { } t } => t == topicId ? 0 : -1,
        { SubjectId: { } s } => s == subjectId ? 1 : -1,
        _ => 2,
    };

    /// <summary>
    /// Termo de busca do conteúdo, pronto para entrar na URL. A pontuação do nome do
    /// conteúdo ("Mecânica: movimento e forças") vira espaço, porque os buscadores dos
    /// canais tratam os termos separadamente.
    /// </summary>
    public static string BuildQuery(string topicName)
    {
        string cleaned = Punctuation().Replace(topicName, " ").Trim();
        return Uri.EscapeDataString(Whitespace().Replace(cleaned, " "));
    }

    [GeneratedRegex(@"[:;,/\-–—()]")]
    private static partial Regex Punctuation();

    [GeneratedRegex(@"\s+")]
    private static partial Regex Whitespace();
}
