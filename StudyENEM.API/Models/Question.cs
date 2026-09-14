using System.ComponentModel.DataAnnotations.Schema;

namespace StudyENEM.API.Models;

/// <summary>Questão de uma prova do ENEM (tabela <c>questao</c>).</summary>
public class Question
{
    public int Id { get; set; }
    public int AreaId { get; set; }
    public Area Area { get; set; } = null!;
    public int SubjectId { get; set; }
    public Subject Subject { get; set; } = null!;
    public int TopicId { get; set; }
    public Topic Topic { get; set; } = null!;
    public int SkillId { get; set; }
    public Skill Skill { get; set; } = null!;

    public int Year { get; set; }
    /// <summary>Número da questão no caderno de prova (1 a 180).</summary>
    public int Number { get; set; }
    public int Day { get; set; }
    /// <summary>"ingles" ou "espanhol" nas questões 1 a 5; nulo nas demais.</summary>
    public string? ForeignLanguage { get; set; }
    /// <summary>Código do item nos microdados do INEP (CO_ITEM).</summary>
    public int InepItemCode { get; set; }

    /// <summary>Texto-base e comando da questão, em Markdown.</summary>
    public string Statement { get; set; } = string.Empty;
    /// <summary>Gabarito oficial; nulo quando a questão foi anulada pelo INEP.</summary>
    public char? CorrectOption { get; set; }

    // Parâmetros do modelo logístico de 3 parâmetros publicados pelo INEP.
    public double? TriA { get; set; }
    public double? TriB { get; set; }
    public double? TriC { get; set; }
    /// <summary>Motivo pelo qual o INEP desconsiderou o item no cálculo da nota.</summary>
    public string? TriExclusionReason { get; set; }

    /// <summary>Como disciplina/conteúdo foram atribuídos: habilidade, palavras-chave ou revisão manual.</summary>
    public string ClassificationMethod { get; set; } = string.Empty;

    public ICollection<Alternative> Alternatives { get; set; } = new List<Alternative>();
    public ICollection<AttemptAnswer> Answers { get; set; } = new List<AttemptAnswer>();

    [NotMapped]
    public bool HasTriParameters => TriA.HasValue && TriB.HasValue && TriC.HasValue;
}
