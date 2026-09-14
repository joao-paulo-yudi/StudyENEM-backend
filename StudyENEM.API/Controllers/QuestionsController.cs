using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudyENEM.API.Services;

namespace StudyENEM.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class QuestionsController(QuestionService service) : ControllerBase
{
    /// <summary>Anos, áreas, disciplinas e conteúdos disponíveis, com contagem de questões.</summary>
    [HttpGet("catalog")]
    public async Task<IActionResult> GetCatalog() => Ok(await service.GetCatalogAsync());

    /// <summary>Banco de questões com gabarito e metadados do INEP.</summary>
    [HttpGet]
    public async Task<IActionResult> GetQuestions(
        [FromQuery] int? year, [FromQuery] string? area, [FromQuery] int? subjectId, [FromQuery] int? topicId) =>
        Ok(await service.GetBankAsync(year, area, subjectId, topicId));
}
