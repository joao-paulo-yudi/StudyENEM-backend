using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Data;
using StudyENEM.API.DTOs;
using StudyENEM.API.Models;

namespace StudyENEM.API.Services;

public class AuthService(AppDbContext db, TokenService tokens, GoogleAuthService google)
{
    public async Task<AuthResponseDto?> LoginAsync(LoginDto dto)
    {
        var identifier = (dto.Identifier ?? string.Empty).Trim().ToLower();
        if (string.IsNullOrEmpty(identifier) || string.IsNullOrEmpty(dto.Password)) return null;

        var user = await db.Users.FirstOrDefaultAsync(u =>
            u.Email.ToLower() == identifier || u.Name.ToLower() == identifier);

        if (user is null) return null;
        if (!PasswordHasher.Verify(dto.Password, user.PasswordHash, user.PasswordSalt)) return null;

        return CreateResponse(user);
    }

    public async Task<(AuthResponseDto? Response, string? Error)> RegisterAsync(RegisterDto dto)
    {
        var name = (dto.Name ?? string.Empty).Trim();
        var email = (dto.Email ?? string.Empty).Trim().ToLower();

        if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(dto.Password))
            return (null, "Nome, e-mail e senha são obrigatórios.");

        var existing = await db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == email);
        if (existing is not null)
        {
            return existing.PasswordHash is null
                ? (null, "Este e-mail já está vinculado a uma conta Google. Use \"Continuar com Google\".")
                : (null, "Já existe uma conta com este e-mail.");
        }

        var (hash, salt) = PasswordHasher.Hash(dto.Password);
        var user = new User { Name = name, Email = email, PasswordHash = hash, PasswordSalt = salt };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        return (CreateResponse(user), null);
    }

    /// <summary>
    /// Login com Google: valida o ID token, reaproveita a conta com o mesmo e-mail (vinculando-a
    /// ao Google) e, na primeira vez, cria o cadastro do estudante sem senha local.
    /// </summary>
    public async Task<(AuthResponseDto? Response, string? Error)> LoginWithGoogleAsync(GoogleLoginDto dto)
    {
        if (!google.Enabled)
            return (null, "O login com Google não está configurado neste servidor.");

        var payload = await google.ValidateAsync(dto.Credential);
        if (payload is null || string.IsNullOrWhiteSpace(payload.Subject))
            return (null, "Não foi possível validar sua conta Google. Tente novamente.");

        if (string.IsNullOrWhiteSpace(payload.Email) || payload.EmailVerified != true)
            return (null, "A conta Google precisa ter um e-mail verificado.");

        var googleId = payload.Subject;
        var email = payload.Email.Trim().ToLower();

        var user = await db.Users.FirstOrDefaultAsync(u => u.GoogleId == googleId)
                ?? await db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == email);

        if (user is null)
        {
            // O Google nem sempre devolve o nome; nesse caso usa-se a parte local do e-mail.
            var name = payload.Name?.Trim();
            if (string.IsNullOrEmpty(name)) name = email.Split('@')[0];

            user = new User { Name = name, Email = email, GoogleId = googleId };
            db.Users.Add(user);
        }
        else if (user.GoogleId is null)
        {
            // Conta criada por e-mail e senha: o Google confirmou a posse do e-mail, então vincula.
            user.GoogleId = googleId;
        }
        else if (user.GoogleId != googleId)
        {
            return (null, "Este e-mail já está vinculado a outra conta Google.");
        }

        await db.SaveChangesAsync();
        return (CreateResponse(user), null);
    }

    private AuthResponseDto CreateResponse(User user)
    {
        var (token, expiresAt) = tokens.Create(user);
        return new AuthResponseDto(token, expiresAt, new AuthUserDto(user.Id, user.Name, user.Email));
    }
}
