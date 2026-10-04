using System.Net;
using Microsoft.AspNetCore.HttpOverrides;
using IPNetwork = Microsoft.AspNetCore.HttpOverrides.IPNetwork;

namespace StudyENEM.API.Infrastructure;

/// <summary>
/// Cabeçalhos X-Forwarded-* repassados pelo proxy reverso: o nginx do frontend e, na avaliação
/// remota, o cloudflared antes dele. Sem isto a API veria todo acesso como HTTP vindo do IP do
/// container do nginx, e não como HTTPS vindo do navegador.
/// </summary>
public static class ForwardedHeadersSetup
{
    /// <summary>Redes privadas (RFC 1918), onde ficam os containers do Docker Compose.</summary>
    private static readonly IPNetwork[] PrivateNetworks =
    [
        new(IPAddress.Parse("10.0.0.0"), 8),
        new(IPAddress.Parse("172.16.0.0"), 12),
        new(IPAddress.Parse("192.168.0.0"), 16),
    ];

    public static void Configure(ForwardedHeadersOptions options)
    {
        options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;

        // Por padrão só o loopback é confiável; o nginx e o cloudflared chegam pela rede do Compose.
        foreach (var network in PrivateNetworks)
            options.KnownNetworks.Add(network);

        // Na avaliação a cadeia é navegador → Cloudflare → cloudflared → nginx → API: são dois
        // saltos confiáveis (nginx e cloudflared) até o IP do cliente informado pela Cloudflare.
        options.ForwardLimit = 2;
    }
}
