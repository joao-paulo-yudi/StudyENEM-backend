using Google.Apis.Auth;
using Microsoft.Extensions.Options;

namespace StudyENEM.API.Services;

public class GoogleAuthOptions
{
    public const string Section = "Google";

    /// <summary>
    /// ID do cliente OAuth 2.0 criado no Google Cloud Console. Configure por Google__ClientId;
    /// vazio desabilita o login com Google.
    /// </summary>
    public string ClientId { get; set; } = string.Empty;
}

/// <summary>
/// Valida o ID token (JWT) emitido pelo Google Identity Services no navegador. A biblioteca
/// oficial confere assinatura, emissor, validade e o ID do cliente (audience).
/// </summary>
public class GoogleAuthService(IOptions<GoogleAuthOptions> options, ILogger<GoogleAuthService> logger)
{
    /// <summary>ID do cliente configurado, ou nulo quando o login com Google está desabilitado.</summary>
    public string? ClientId
    {
        get
        {
            var id = options.Value.ClientId?.Trim();
            return string.IsNullOrEmpty(id) ? null : id;
        }
    }

    public bool Enabled => ClientId is not null;

    /// <summary>Dados da conta Google, ou nulo quando o token é inválido.</summary>
    public async Task<GoogleJsonWebSignature.Payload?> ValidateAsync(string? credential)
    {
        var clientId = ClientId;
        if (clientId is null || string.IsNullOrWhiteSpace(credential)) return null;

        try
        {
            return await GoogleJsonWebSignature.ValidateAsync(credential, new GoogleJsonWebSignature.ValidationSettings
            {
                Audience = [clientId],
            });
        }
        catch (InvalidJwtException ex)
        {
            logger.LogWarning("ID token do Google recusado: {Message}", ex.Message);
            return null;
        }
    }
}
