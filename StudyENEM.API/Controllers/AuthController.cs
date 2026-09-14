using Microsoft.AspNetCore.Mvc;
using StudyENEM.API.DTOs;
using StudyENEM.API.Services;

namespace StudyENEM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(AuthService auth) : ControllerBase
{
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var response = await auth.LoginAsync(dto);
        if (response is null) return Unauthorized(new { message = "E-mail ou senha inválidos." });
        return Ok(response);
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        var (response, error) = await auth.RegisterAsync(dto);
        if (error is not null) return BadRequest(new { message = error });
        return Ok(response);
    }
}
