using StudyENEM.API.DTOs;
using StudyENEM.API.Services;

namespace StudyENEM.Tests;

public class StudyPlanServiceTests
{
    private static TopicPerformanceDto Topic(int id, string name, string subject, string area, int total, int correct) =>
        new(id, name, subject, area, total, correct,
            PerformanceCalculator.Percentage(correct, total),
            PerformanceCalculator.DifficultyIndex(correct, total),
            null);

    /// <summary>Oito conteúdos difíceis de quatro áreas, como chegam do cálculo de desempenho.</summary>
    private static List<TopicPerformanceDto> Difficult() =>
        [
            Topic(1, "Estatística", "Matemática", "MT", 10, 0),
            Topic(2, "Funções", "Matemática", "MT", 10, 1),
            Topic(3, "Genética", "Biologia", "CN", 10, 2),
            Topic(4, "Citologia", "Biologia", "CN", 10, 3),
            Topic(5, "Brasil República", "História", "CH", 10, 4),
            Topic(6, "Brasil Colônia", "História", "CH", 10, 5),
            Topic(7, "Gêneros textuais", "Língua Portuguesa", "LC", 10, 6),
            Topic(8, "Variação linguística", "Língua Portuguesa", "LC", 10, 7),
        ];

    [Fact]
    public void ItensSeguemAOrdemRecebidaENumeramOsPassos()
    {
        var items = StudyPlanService.BuildItems(Difficult());

        Assert.Equal(Enumerable.Range(1, 8), items.Select(i => i.Step));
        Assert.Equal("Estatística", items[0].Topic);
    }

    [Fact]
    public void EsforcoCresceComOIndiceDeDificuldade()
    {
        var items = StudyPlanService.BuildItems(Difficult());

        Assert.True(items[0].EstimatedMinutes > items[^1].EstimatedMinutes);
        Assert.Equal(75, StudyPlanService.EstimatedMinutes(1.0));
        Assert.Equal(30, StudyPlanService.EstimatedMinutes(0.0));
        Assert.Equal(15, StudyPlanService.RecommendedQuestions(0.6));
        Assert.Equal(10, StudyPlanService.RecommendedQuestions(0.4));
        Assert.Equal(5, StudyPlanService.RecommendedQuestions(0.3));
    }

    [Fact]
    public void ItensDoResumoNaoTrazemFontesDeEstudo()
    {
        Assert.All(StudyPlanService.BuildItems(Difficult()), item => Assert.Empty(item.Resources));
    }

    [Fact]
    public void CronogramaNaoRepeteAMesmaAreaNoMesmoDia()
    {
        var schedule = StudyPlanService.BuildSchedule(StudyPlanService.BuildItems(Difficult()));

        foreach (var day in schedule.Where(d => d.Day != "Domingo"))
        {
            var areas = day.Tasks.Select(t => t.AreaCode).ToList();
            Assert.Equal(areas.Count, areas.Distinct().Count());
        }
    }

    [Fact]
    public void CronogramaFechaComSimuladoERevisaoNoDomingo()
    {
        var schedule = StudyPlanService.BuildSchedule(StudyPlanService.BuildItems(Difficult()));

        var sunday = schedule[^1];
        Assert.Equal("Domingo", sunday.Day);
        Assert.All(sunday.Tasks, task => Assert.Null(task.TopicId));
        Assert.Equal(sunday.Tasks.Sum(t => t.Minutes), sunday.TotalMinutes);
    }

    [Fact]
    public void ConteudosMaisCriticosEntramPrimeiroNoCronograma()
    {
        // Doze conteúdos de uma área só não cabem na semana: a distribuição para na carga diária.
        var many = Enumerable.Range(1, 12)
            .Select(i => Topic(i, $"Conteúdo {i}", "Matemática", "MT", 10, i - 1))
            .ToList();

        var scheduled = StudyPlanService.BuildSchedule(StudyPlanService.BuildItems(many))
            .SelectMany(d => d.Tasks)
            .Where(t => t.TopicId is not null)
            .Select(t => t.TopicId)
            .ToList();

        Assert.NotEmpty(scheduled);
        Assert.All(scheduled, id => Assert.True(id <= scheduled.Count));
    }

    [Fact]
    public void SemHistoricoOCronogramaFicaVazio()
    {
        Assert.Empty(StudyPlanService.BuildSchedule([]));
    }
}
