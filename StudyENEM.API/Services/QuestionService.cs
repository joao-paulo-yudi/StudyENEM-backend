using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Data;
using StudyENEM.API.DTOs;

namespace StudyENEM.API.Services;

/// <summary>Banco de questões (RF03, RF09): catálogo de áreas/disciplinas/conteúdos e listagem.</summary>
public class QuestionService(AppDbContext db)
{
    public async Task<QuestionCatalogDto> GetCatalogAsync()
    {
        var counts = await db.Questions
            .GroupBy(q => q.TopicId)
            .Select(g => new { TopicId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.TopicId, x => x.Count);

        var areas = await db.Areas.AsNoTracking()
            .Include(a => a.Subjects).ThenInclude(s => s.Topics)
            .OrderBy(a => a.Order)
            .ToListAsync();

        var years = await db.Questions.Select(q => q.Year).Distinct().OrderByDescending(y => y).ToListAsync();

        return new QuestionCatalogDto(years, areas.Select(a => new AreaCatalogDto(
            a.Id, a.Code, a.Name,
            a.Subjects.SelectMany(s => s.Topics).Sum(t => counts.GetValueOrDefault(t.Id)),
            a.Subjects.OrderBy(s => s.Name).Select(s => new SubjectDto(
                s.Id, s.Name,
                s.Topics.OrderBy(t => t.Name).Select(t => new TopicDto(t.Id, t.Name, counts.GetValueOrDefault(t.Id))).ToList()
            )).ToList()
        )).ToList());
    }

    public async Task<List<QuestionBankItemDto>> GetBankAsync(int? year, string? areaCode, int? subjectId, int? topicId)
    {
        var scales = PerformanceCalculator.ScaleLookup(await db.TriScales.AsNoTracking().ToListAsync());

        var query = db.Questions.AsNoTracking()
            .Include(q => q.Area)
            .Include(q => q.Subject)
            .Include(q => q.Topic)
            .Include(q => q.Skill)
            .Include(q => q.Alternatives)
            .AsQueryable();

        if (year.HasValue) query = query.Where(q => q.Year == year);
        if (!string.IsNullOrWhiteSpace(areaCode)) query = query.Where(q => q.Area.Code == areaCode);
        if (subjectId.HasValue) query = query.Where(q => q.SubjectId == subjectId);
        if (topicId.HasValue) query = query.Where(q => q.TopicId == topicId);

        var questions = await query
            .OrderByDescending(q => q.Year).ThenBy(q => q.Number).ThenBy(q => q.ForeignLanguage)
            .ToListAsync();

        return questions.Select(q => new QuestionBankItemDto(
            q.Id, q.Year, q.Number, q.Day,
            q.Area.Code, q.Area.Name,
            q.SubjectId, q.Subject.Name,
            q.TopicId, q.Topic.Name,
            q.ForeignLanguage,
            q.Skill.Code, q.Skill.Description,
            q.Statement,
            q.Alternatives.OrderBy(a => a.Letter).Select(a => new AlternativeDto(a.Letter, a.Text)).ToList(),
            q.CorrectOption,
            q.TriB.HasValue && scales.TryGetValue((q.AreaId, q.Year), out var scale)
                ? Math.Round(TriScorer.DifficultyOnEnemScale(q.TriB.Value, scale))
                : null,
            q.TriExclusionReason
        )).ToList();
    }
}
