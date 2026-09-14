using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace StudyENEM.API.Data;

/// <summary>
/// Cria o contexto para as ferramentas do EF Core (<c>dotnet ef migrations add</c>,
/// <c>dotnet ef database update</c>) sem depender da inicialização da API.
/// Usa a variável de ambiente ConnectionStrings__Default quando definida.
/// </summary>
public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public const string DefaultConnectionString =
        "Host=localhost;Port=5432;Database=studyenem;Username=studyenem;Password=studyenem";

    public AppDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__Default") ?? DefaultConnectionString;
        return new AppDbContext(new DbContextOptionsBuilder<AppDbContext>().UseNpgsql(connectionString).Options);
    }
}
