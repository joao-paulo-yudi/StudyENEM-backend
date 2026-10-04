using StudyENEM.API.Models;
using StudyENEM.API.Services;

namespace StudyENEM.Tests;

public class PerformanceCalculatorTests
{
    private static readonly Area Mt = new() { Id = 4, Code = "MT", Name = "Matemática" };
    private static readonly Subject Math = new() { Id = 1, AreaId = 4, Area = Mt, Name = "Matemática" };

    /// <summary>Respostas a um conteúdo: <paramref name="wrong"/> erradas e o restante certas.</summary>
    private static IEnumerable<AttemptAnswer> Answers(int topicId, string topic, int total, int wrong)
    {
        var t = new Topic { Id = topicId, SubjectId = Math.Id, Subject = Math, Name = topic };
        return Enumerable.Range(0, total).Select(i => new AttemptAnswer
        {
            QuestionId = topicId * 100 + i,
            Question = new Question { Id = topicId * 100 + i, AreaId = Mt.Id, Area = Mt, SubjectId = Math.Id, Subject = Math, TopicId = topicId, Topic = t },
            IsCorrect = i >= wrong,
        });
    }

    [Fact]
    public void ConteudosEmpatadosSaemSempreNaMesmaOrdemQualquerQueSejaAOrdemDasRespostas()
    {
        // Funções, Aritmética e Equações empatam em índice (1,00) e total (4); Geometria vem antes pelo total.
        var answers = Answers(7, "Funções", 4, 4)
            .Concat(Answers(3, "Aritmética e conjuntos numéricos", 4, 4))
            .Concat(Answers(9, "Geometria espacial", 10, 10))
            .Concat(Answers(5, "Equações e inequações", 4, 4))
            .Concat(Answers(2, "Estatística", 4, 2))
            .ToList();

        var expected = new[] { "Geometria espacial", "Aritmética e conjuntos numéricos", "Equações e inequações", "Funções", "Estatística" };
        var rng = new Random(1);
        for (int i = 0; i < 20; i++)
        {
            var shuffled = answers.OrderBy(_ => rng.Next()).ToList();
            Assert.Equal(expected, PerformanceCalculator.ByTopic(shuffled).Select(t => t.Topic));
        }
    }
}
