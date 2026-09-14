using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;

namespace StudyENEM.API.Data;

/// <summary>
/// Prepara o banco na subida da API: aplica as migrations pendentes (esquema e carga do
/// banco de questões) e cria os dados de demonstração.
/// </summary>
public static class DatabaseInitializer
{
    public static void Initialize(AppDbContext db, ILogger logger)
    {
        // O PostgreSQL pode levar alguns segundos para aceitar conexões na 1ª subida.
        for (var attempt = 1; ; attempt++)
        {
            try
            {
                ApplyMigrations(db, logger);
                break;
            }
            catch (IncompatibleDatabaseException)
            {
                throw;
            }
            catch (Exception ex) when (attempt < 10)
            {
                logger.LogWarning("Banco indisponível (tentativa {Attempt}/10): {Message}. Nova tentativa em 3s...", attempt, ex.Message);
                Thread.Sleep(3000);
            }
        }

        DemoSeed.Apply(db, logger);
    }

    private static void ApplyMigrations(AppDbContext db, ILogger logger)
    {
        // Se o banco ainda não existe, Migrate() o cria.
        if (db.GetService<IRelationalDatabaseCreator>().Exists())
        {
            EnsureNotLegacySchema(db);
            var pending = db.Database.GetPendingMigrations().ToList();
            if (pending.Count > 0)
                logger.LogInformation("Aplicando migrations: {Migrations}", string.Join(", ", pending));
        }

        db.Database.Migrate();
    }

    /// <summary>
    /// Um banco com tabelas mas sem o histórico de migrations foi criado por uma versão anterior
    /// do StudyENEM (EnsureCreated) e não pode ser atualizado automaticamente.
    /// </summary>
    private static void EnsureNotLegacySchema(AppDbContext db)
    {
        int tables = db.Database.SqlQuery<int>($"""
            SELECT COUNT(*)::int AS "Value" FROM information_schema.tables
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            """).Single();
        int migrationHistory = db.Database.SqlQuery<int>($"""
            SELECT COUNT(*)::int AS "Value" FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = '__EFMigrationsHistory'
            """).Single();

        if (tables > 0 && migrationHistory == 0)
        {
            throw new IncompatibleDatabaseException(
                "O banco de dados foi criado por uma versão anterior do StudyENEM, sem migrations. " +
                "Recrie o volume do PostgreSQL: docker compose down -v && docker compose up --build");
        }
    }
}

public class IncompatibleDatabaseException(string message) : Exception(message);
