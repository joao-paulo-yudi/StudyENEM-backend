using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace StudyENEM.API.Infrastructure;

public static class ClaimsPrincipalExtensions
{
    /// <summary>Id do usuário autenticado (claim "sub" do token JWT).</summary>
    public static int GetUserId(this ClaimsPrincipal user) =>
        int.TryParse(user.FindFirstValue(JwtRegisteredClaimNames.Sub), out var id)
            ? id
            : throw new UnauthorizedAccessException("Token sem identificação do usuário.");
}
