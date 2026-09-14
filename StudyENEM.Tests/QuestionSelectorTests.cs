using StudyENEM.API.Models;
using StudyENEM.API.Services;

namespace StudyENEM.Tests;

public class QuestionSelectorTests
{
    private static List<Question> Bank()
    {
        var areas = new[] { ("LC", 1, 1), ("CH", 2, 46), ("CN", 3, 91), ("MT", 4, 136) }
            .Select(a => (Area: new Area { Id = a.Item2, Code = a.Item1, Order = a.Item2 }, Start: a.Item3))
            .ToList();
        int id = 0;
        return areas.SelectMany(a => Enumerable.Range(a.Start, 45).Select(n => new Question
        {
            Id = ++id, Area = a.Area, AreaId = a.Area.Id, Year = 2022, Number = n,
        })).ToList();
    }

    [Fact]
    public void SimuladoGeralCom180QuestoesEhAProvaCompletaNaOrdemDoEnem()
    {
        var selected = QuestionSelector.Select(Bank(), balanceAreas: true, 180, new Random(1));

        Assert.Equal(180, selected.Count);
        Assert.All(new[] { "LC", "CH", "CN", "MT" }, code => Assert.Equal(45, selected.Count(q => q.Area.Code == code)));
        Assert.Equal(Enumerable.Range(1, 180), selected.Select(q => q.Number));
    }

    [Fact]
    public void SimuladoGeralDistribuiQuestoesEntreAsAreas()
    {
        var selected = QuestionSelector.Select(Bank(), balanceAreas: true, 10, new Random(1));

        Assert.Equal(new[] { 3, 3, 2, 2 }, new[] { "LC", "CH", "CN", "MT" }.Select(c => selected.Count(q => q.Area.Code == c)));
        Assert.Equal(selected.OrderBy(q => q.Area.Order).ThenBy(q => q.Number), selected);
    }

    [Fact]
    public void QuantidadeMaiorQueOBancoNaoRepeteQuestoes()
    {
        var pool = Bank().Where(q => q.Area.Code == "MT").Take(12).ToList();
        var selected = QuestionSelector.Select(pool, balanceAreas: false, 45, new Random(1));

        Assert.Equal(12, selected.Count);
        Assert.Equal(12, selected.Select(q => q.Id).Distinct().Count());
    }
}
