using StudyENEM.API.Models;
using StudyENEM.API.Services;

namespace StudyENEM.Tests;

public class StudyResourceRecommenderTests
{
    private const int Matematica = 10, Biologia = 20;
    private const int Funcoes = 100, Genetica = 200;

    private static List<StudyResource> Catalog() =>
    [
        new() { Id = 1, SubjectId = null, TopicId = null, Kind = "video", Provider = "YouTube", Order = 90,
                UrlTemplate = "https://www.youtube.com/results?search_query={consulta}+ENEM" },
        new() { Id = 2, SubjectId = null, TopicId = null, Kind = "exercicio", Provider = "Brasil Escola", Order = 90,
                UrlTemplate = "https://exercicios.brasilescola.uol.com.br/busca?q={consulta}" },
        new() { Id = 3, SubjectId = Matematica, TopicId = null, Kind = "video", Provider = "Professor Ferretto", Order = 1,
                UrlTemplate = "https://www.youtube.com/@professorferretto/search?query={consulta}" },
        new() { Id = 4, SubjectId = Biologia, TopicId = null, Kind = "video", Provider = "Biologia Total", Order = 1,
                UrlTemplate = "https://www.youtube.com/@paulojubilut/search?query={consulta}" },
        new() { Id = 5, SubjectId = Matematica, TopicId = Funcoes, Kind = "video", Provider = "Canal do conteúdo", Order = 9,
                UrlTemplate = "https://www.youtube.com/@conteudo/search?query={consulta}" },
    ];

    [Fact]
    public void FonteDoConteudoVemAntesDaDisciplinaEDaGeral()
    {
        var videos = StudyResourceRecommender.Recommend(Funcoes, Matematica, "Funções", Catalog())
            .Where(r => r.Kind == "video")
            .Select(r => r.Provider);

        Assert.Equal(["Canal do conteúdo", "Professor Ferretto", "YouTube"], videos);
    }

    [Fact]
    public void FontesDeOutraDisciplinaFicamDeFora()
    {
        var providers = StudyResourceRecommender.Recommend(Genetica, Biologia, "Genética e biotecnologia", Catalog())
            .Select(r => r.Provider)
            .ToList();

        Assert.Contains("Biologia Total", providers);
        Assert.DoesNotContain("Professor Ferretto", providers);
        // A fonte presa a outro conteúdo também não aparece.
        Assert.DoesNotContain("Canal do conteúdo", providers);
    }

    [Fact]
    public void RecomendacaoTrazVideosExerciciosEMateriaisNessaOrdem()
    {
        var kinds = StudyResourceRecommender.Recommend(Genetica, Biologia, "Genética e biotecnologia", Catalog())
            .Select(r => r.Kind)
            .Distinct();

        Assert.Equal(["video", "exercicio"], kinds);
    }

    [Fact]
    public void ConsultaSubstituiOMarcadorComOConteudoCodificado()
    {
        var resource = StudyResourceRecommender.Recommend(Genetica, Biologia, "Genética e biotecnologia", Catalog())
            .First(r => r.Provider == "Biologia Total");

        Assert.Equal("https://www.youtube.com/@paulojubilut/search?query=Gen%C3%A9tica%20e%20biotecnologia", resource.Url);
    }

    [Fact]
    public void PontuacaoDoNomeDoConteudoViraEspacoNaBusca()
    {
        Assert.Equal("Mec%C3%A2nica%20movimento%20e%20for%C3%A7as", StudyResourceRecommender.BuildQuery("Mecânica: movimento e forças"));
        Assert.Equal("Raz%C3%A3o%20propor%C3%A7%C3%A3o%20e%20regra%20de%20tr%C3%AAs", StudyResourceRecommender.BuildQuery("Razão, proporção e regra de três"));
    }

    [Fact]
    public void CatalogoVazioNaoQuebraARecomendacao()
    {
        Assert.Empty(StudyResourceRecommender.Recommend(Funcoes, Matematica, "Funções", []));
    }
}
