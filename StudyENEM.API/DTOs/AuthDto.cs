namespace StudyENEM.API.DTOs;

public record LoginDto(string Identifier, string Password);

public record RegisterDto(string Name, string Email, string Password);

public record AuthUserDto(int Id, string Name, string Email);

/// <summary>Resposta de login/cadastro: token JWT (Bearer) e dados do usuário.</summary>
public record AuthResponseDto(string Token, DateTime ExpiresAt, AuthUserDto User);
