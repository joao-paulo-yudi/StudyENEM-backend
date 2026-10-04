using Microsoft.Extensions.Diagnostics.HealthChecks;
using StudyENEM.API.Data;

namespace StudyENEM.API.Infrastructure;

/// <summary>
/// GET /health responde "Healthy" só quando o banco aceita conexões: sem ele nenhuma tela funciona.
/// Usado pelo healthcheck do Docker e, na avaliação remota, pelo monitor externo, que chega aqui pelo
/// túnel e pelo nginx e assim confere o caminho inteiro até o PostgreSQL.
/// </summary>
public class DatabaseHealthCheck(AppDbContext db) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default) =>
        await db.Database.CanConnectAsync(cancellationToken)
            ? HealthCheckResult.Healthy()
            : HealthCheckResult.Unhealthy("Banco de dados indisponível.");
}
