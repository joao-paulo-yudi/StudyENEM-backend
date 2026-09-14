using System.Text.Json;
using StudyENEM.API.Data;
using StudyENEM.API.Models;
using StudyENEM.API.Services;

namespace StudyENEM.Tests;

/// <summary>
/// Validação da TRI contra o ENEM 2022: padrões de resposta reais de participantes (microdados do INEP,
/// caderno AZUL) precisam reproduzir a nota oficial divulgada. Os parâmetros dos itens e as escalas vêm do
/// script de carga do banco (enem_2022.sql, executado pela migration CargaEnem2022). O arquivo
/// Dados/tri_validacao_2022.json tem só os padrões de resposta e as notas oficiais, exportados por
/// tools/enem-import/importar_enem.py.
/// </summary>
public class TriScorerTests
{
    private static readonly Dictionary<string, int> FirstQuestion = new() { ["LC"] = 1, ["CH"] = 46, ["CN"] = 91, ["MT"] = 136 };

    private static readonly string LoadScript = SqlScript.Load("enem_2022.sql");

    private static readonly List<ItemData> Items = SqlValuesReader.ReadRows(LoadScript, "questao")
        .Select(r => new ItemData((string)r["area"]!, (int)(double)r["numero"]!, (string?)r["lingua"], (string?)r["gabarito"],
            (double?)r["tri_a"], (double?)r["tri_b"], (double?)r["tri_c"]))
        .ToList();

    private static readonly Dictionary<string, TriScale> Scales = SqlValuesReader.ReadRows(LoadScript, "escala_tri")
        .ToDictionary(r => (string)r["area"]!, r => new TriScale { Intercept = (double)r["intercepto"]!, Slope = (double)r["inclinacao"]! });

    private static readonly ValidationData Data = JsonSerializer.Deserialize<ValidationData>(
        File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "Dados", "tri_validacao_2022.json")),
        new JsonSerializerOptions { PropertyNameCaseInsensitive = true })!;

    public static IEnumerable<object?[]> OfficialScores() =>
        Data.Casos.Select(c => new object?[] { c.Area, c.Lingua, c.Respostas, c.NotaOficial });

    [Fact]
    public void ScriptDeCargaTemAProvaCompleta()
    {
        Assert.Equal(185, Items.Count);
        Assert.Equal(["CH", "CN", "LC", "MT"], Scales.Keys.Order());
    }

    [Theory]
    [MemberData(nameof(OfficialScores))]
    public void ReproduzANotaOficialDoInep(string area, string? lingua, string respostas, double notaOficial)
    {
        var items = new List<TriScorer.ItemResponse>();

        for (int i = 0; i < respostas.Length; i++)
        {
            int number = FirstQuestion[area] + i;
            string? language = area == "LC" && number <= 5 ? lingua : null;
            var item = Items.Single(q => q.Area == area && q.Numero == number && q.Lingua == language);
            if (item.A is null) continue; // item desconsiderado pelo INEP

            items.Add(new TriScorer.ItemResponse(item.A.Value, item.B!.Value, item.C!.Value,
                respostas[i].ToString() == item.Gabarito));
        }

        var estimate = TriScorer.EstimateTheta(items);
        Assert.NotNull(estimate);

        double nota = TriScorer.ToEnemScale(estimate.Value.Theta, Scales[area]);
        // As notas oficiais são publicadas com uma casa decimal.
        Assert.InRange(nota, notaOficial - 0.2, notaOficial + 0.2);
    }

    [Fact]
    public void SemItensNaoHaEstimativa() =>
        Assert.Null(TriScorer.EstimateTheta([]));

    [Fact]
    public void AcertarItemDificilValeMaisQueAcertarItemFacil()
    {
        // Mesmo número de acertos, padrões diferentes: a TRI considera a coerência das respostas.
        var facil = (A: 2.0, B: -1.0, C: 0.15);
        var dificil = (A: 2.0, B: 2.0, C: 0.15);

        var acertouFacil = TriScorer.EstimateTheta([
            new(facil.A, facil.B, facil.C, true), new(dificil.A, dificil.B, dificil.C, false)])!.Value;
        var acertouDificil = TriScorer.EstimateTheta([
            new(facil.A, facil.B, facil.C, false), new(dificil.A, dificil.B, dificil.C, true)])!.Value;

        Assert.True(acertouFacil.Theta > acertouDificil.Theta,
            "Errar a questão fácil e acertar a difícil é um padrão incoerente e deve resultar em proficiência menor.");
    }

    [Fact]
    public void MaisAcertosAumentamAProficiencia()
    {
        // Acerta sempre os itens mais fáceis primeiro (padrão coerente).
        var itens = Items.Where(q => q.Area == "MT" && q.A is not null).Take(20).OrderBy(q => q.B).ToList();
        double previous = double.NegativeInfinity;
        for (int acertos = 0; acertos <= itens.Count; acertos += 5)
        {
            var theta = TriScorer.EstimateTheta(itens.Select((q, i) =>
                new TriScorer.ItemResponse(q.A!.Value, q.B!.Value, q.C!.Value, i < acertos)))!.Value.Theta;
            Assert.True(theta > previous);
            previous = theta;
        }
    }

    private sealed record ItemData(string Area, int Numero, string? Lingua, string? Gabarito, double? A, double? B, double? C);
    private sealed record ValidationData(List<ValidationCase> Casos);
    private sealed record ValidationCase(string Area, string? Lingua, string Respostas, double NotaOficial);
}
