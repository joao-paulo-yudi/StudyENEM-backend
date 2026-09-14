using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using StudyENEM.API.Models;

namespace StudyENEM.API.Services;

public class JwtOptions
{
    public const string Section = "Jwt";

    /// <summary>Chave HMAC-SHA256 (mínimo de 32 caracteres). Configure por Jwt__Key.</summary>
    public string Key { get; set; } = string.Empty;
    public string Issuer { get; set; } = "StudyENEM";
    public string Audience { get; set; } = "StudyENEM";
    public int ExpirationHours { get; set; } = 8;
}

/// <summary>Emite os tokens JWT usados na autenticação (RNF03).</summary>
public class TokenService(IOptions<JwtOptions> options)
{
    public (string Token, DateTime ExpiresAt) Create(User user)
    {
        var jwt = options.Value;
        var expiresAt = DateTime.UtcNow.AddHours(jwt.ExpirationHours);
        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Key)), SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: jwt.Issuer,
            audience: jwt.Audience,
            claims:
            [
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Name, user.Name),
            ],
            expires: expiresAt,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }
}
