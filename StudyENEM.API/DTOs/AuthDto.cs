namespace StudyENEM.API.DTOs;

public record LoginDto(string Identifier, string Password);

public record RegisterDto(string Name, string Email, string Password);

/// <summary>ID token devolvido pelo Google Identity Services no navegador.</summary>
public record GoogleLoginDto(string Credential);

/// <summary>Provedores de login habilitados no servidor, consultados pela tela de login.</summary>
public record AuthConfigDto(string? GoogleClientId);

public record AuthUserDto(int Id, string Name, string Email);

/// <summary>Resposta de login/cadastro: token JWT (Bearer) e dados do usuário.</summary>
public record AuthResponseDto(string Token, DateTime ExpiresAt, AuthUserDto User);
