using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Data;
using StudyENEM.API.DTOs;
using StudyENEM.API.Models;

namespace StudyENEM.API.Services;

public class AuthService(AppDbContext db)
{
    public async Task<AuthUserDto?> LoginAsync(LoginDto dto)
    {
        var identifier = (dto.Identifier ?? string.Empty).Trim().ToLower();
        if (string.IsNullOrEmpty(identifier) || string.IsNullOrEmpty(dto.Password)) return null;

        var user = await db.Users.FirstOrDefaultAsync(u =>
            u.Email.ToLower() == identifier || u.Name.ToLower() == identifier);

        if (user is null) return null;
        if (!PasswordHasher.Verify(dto.Password, user.PasswordHash, user.PasswordSalt)) return null;

        return new AuthUserDto(user.Id, user.Name, user.Email);
    }

    public async Task<(AuthUserDto? User, string? Error)> RegisterAsync(RegisterDto dto)
    {
        var name = (dto.Name ?? string.Empty).Trim();
        var email = (dto.Email ?? string.Empty).Trim().ToLower();

        if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(dto.Password))
            return (null, "Nome, e-mail e senha são obrigatórios.");

        if (await db.Users.AnyAsync(u => u.Email.ToLower() == email))
            return (null, "Já existe uma conta com este e-mail.");

        var (hash, salt) = PasswordHasher.Hash(dto.Password);
        var user = new User { Name = name, Email = email, PasswordHash = hash, PasswordSalt = salt };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        return (new AuthUserDto(user.Id, user.Name, user.Email), null);
    }
}
