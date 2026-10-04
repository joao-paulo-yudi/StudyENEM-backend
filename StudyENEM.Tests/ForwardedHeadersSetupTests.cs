using System.Net;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using StudyENEM.API.Infrastructure;

namespace StudyENEM.Tests;

/// <summary>
/// API atrás do proxy, como na avaliação remota: navegador → Cloudflare → cloudflared → nginx → API.
/// O esquema e o IP precisam ser os do navegador; cabeçalhos vindos de fora das redes do Docker,
/// ignorados.
/// </summary>
public class ForwardedHeadersSetupTests
{
    private static async Task<HttpContext> SendAsync(string remoteIp, string forwardedFor, string forwardedProto)
    {
        var options = new ForwardedHeadersOptions();
        ForwardedHeadersSetup.Configure(options);
        var middleware = new ForwardedHeadersMiddleware(_ => Task.CompletedTask, NullLoggerFactory.Instance, Options.Create(options));

        var context = new DefaultHttpContext();
        context.Request.Scheme = "http";
        context.Connection.RemoteIpAddress = IPAddress.Parse(remoteIp);
        context.Request.Headers["X-Forwarded-For"] = forwardedFor;
        context.Request.Headers["X-Forwarded-Proto"] = forwardedProto;
        await middleware.Invoke(context);
        return context;
    }

    [Fact]
    public async Task PeloTunelValemOEsquemaEOIpDoNavegador()
    {
        // O nginx (172.18.0.4) acrescenta o IP do cloudflared (172.18.0.5) ao do cliente, vindo da Cloudflare.
        var context = await SendAsync("172.18.0.4", "203.0.113.7, 172.18.0.5", "https");

        Assert.Equal("https", context.Request.Scheme);
        Assert.Equal(IPAddress.Parse("203.0.113.7"), context.Connection.RemoteIpAddress);
    }

    [Fact]
    public async Task EnderecoIPv4MapeadoEmIPv6DoKestrelEhReconhecidoComoProxy()
    {
        // Escutando em http://+:8080, o Kestrel informa o nginx como ::ffff:172.18.0.4.
        var context = await SendAsync("::ffff:172.18.0.4", "172.18.0.1", "https");

        Assert.Equal("https", context.Request.Scheme);
        Assert.Equal(IPAddress.Parse("172.18.0.1"), context.Connection.RemoteIpAddress);
    }

    [Fact]
    public async Task CabecalhosDeOrigemForaDaRedeDoDockerSaoIgnorados()
    {
        var context = await SendAsync("203.0.113.50", "198.51.100.1", "https");

        Assert.Equal("http", context.Request.Scheme);
        Assert.Equal(IPAddress.Parse("203.0.113.50"), context.Connection.RemoteIpAddress);
    }
}
