using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudyENEM.API.DTOs;
using StudyENEM.API.Infrastructure;
using StudyENEM.API.Services;

namespace StudyENEM.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class AttemptsController(ExamService service) : ControllerBase
{
    /// <summary>Monta um simulado e retorna as questões (sem gabarito).</summary>
    [HttpPost]
    public async Task<IActionResult> Start([FromBody] StartAttemptDto dto) =>
        Ok(await service.StartAttemptAsync(User.GetUserId(), dto));

    /// <summary>Registra as respostas, corrige e calcula o desempenho por área (inclusive TRI).</summary>
    [HttpPost("{id:int}/submit")]
    public async Task<IActionResult> Submit(int id, [FromBody] SubmitAttemptDto dto) =>
        Ok(await service.SubmitAttemptAsync(User.GetUserId(), id, dto));

    /// <summary>Resultado detalhado de um simulado finalizado.</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetResult(int id)
    {
        var result = await service.GetAttemptResultAsync(User.GetUserId(), id);
        return result is null ? NotFound(new { message = "Resultado não encontrado." }) : Ok(result);
    }

    /// <summary>Histórico completo de simulados do estudante.</summary>
    [HttpGet]
    public async Task<IActionResult> GetHistory() => Ok(await service.GetHistoryAsync(User.GetUserId()));
}
