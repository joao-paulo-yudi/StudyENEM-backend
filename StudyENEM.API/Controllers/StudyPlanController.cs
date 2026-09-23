using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudyENEM.API.Infrastructure;
using StudyENEM.API.Services;

namespace StudyENEM.API.Controllers;

[ApiController]
[Authorize]
[Route("api/studyplan")]
public class StudyPlanController(StudyPlanService service) : ControllerBase
{
    /// <summary>
    /// Plano de estudos do estudante autenticado: conteúdos priorizados, esforço sugerido,
    /// fontes de estudo recomendadas e cronograma semanal.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetPlan() => Ok(await service.GetPlanAsync(User.GetUserId()));
}
