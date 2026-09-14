using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudyENEM.API.Infrastructure;
using StudyENEM.API.Services;

namespace StudyENEM.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class DashboardController(DashboardService service) : ControllerBase
{
    /// <summary>Indicadores de desempenho, histórico e plano de estudos do estudante autenticado.</summary>
    [HttpGet]
    public async Task<IActionResult> GetPerformance() => Ok(await service.GetSummaryAsync(User.GetUserId()));
}
