namespace StudyENEM.API.DTOs;

public record LoginDto(string Identifier, string Password);

public record RegisterDto(string Name, string Email, string Password);

/// <summary>ID token devolvido pelo Google Identity Services no navegador.</summary>
public record GoogleLoginDto(string Credential);

/// <summary>
/// Provedores de login social habilitados no servidor, consultados pela tela de login: cada
/// provedor só aparece em <see cref="Providers"/> quando tem configuração própria (o Google,
/// com Google__ClientId). Hoje o único provedor integrado é o Google.
/// </summary>
public record AuthConfigDto(IReadOnlyList<string> Providers, string? GoogleClientId);

public record AuthUserDto(int Id, string Name, string Email);

/// <summary>Resposta de login/cadastro: token JWT (Bearer) e dados do usuário.</summary>
public record AuthResponseDto(string Token, DateTime ExpiresAt, AuthUserDto User);
