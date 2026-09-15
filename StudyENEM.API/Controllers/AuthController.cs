using Microsoft.AspNetCore.Mvc;
using StudyENEM.API.DTOs;
using StudyENEM.API.Services;

namespace StudyENEM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(AuthService auth, GoogleAuthService google) : ControllerBase
{
    /// <summary>Provedores de login habilitados; a tela de login usa o ID do cliente do Google.</summary>
    [HttpGet("config")]
    public IActionResult Config() => Ok(new AuthConfigDto(google.ClientId));

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

    /// <summary>Login com a conta Google: recebe o ID token do Google Identity Services.</summary>
    [HttpPost("google")]
    public async Task<IActionResult> LoginWithGoogle([FromBody] GoogleLoginDto dto)
    {
        if (!google.Enabled)
            return StatusCode(StatusCodes.Status503ServiceUnavailable,
                new { message = "O login com Google não está configurado neste servidor." });

        var (response, error) = await auth.LoginWithGoogleAsync(dto);
        if (error is not null) return Unauthorized(new { message = error });
        return Ok(response);
    }
}
