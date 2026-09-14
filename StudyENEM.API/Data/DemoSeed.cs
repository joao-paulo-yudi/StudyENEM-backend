using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Models;
using StudyENEM.API.Services;

namespace StudyENEM.API.Data;

/// <summary>
/// Dados de demonstração: um usuário e um histórico de simulados para que os dashboards
/// tenham conteúdo. O banco de questões não é criado aqui, e sim pela migration CargaEnem2022.
/// </summary>
public static class DemoSeed
{
    private const string DemoName = "João Teste";
    private const string DemoEmail = "joao@studyenem.com";

    public static void Apply(AppDbContext db, ILogger logger)
    {
        SeedDemoUser(db);
        if (SeedDemoAttempts(db))
            logger.LogInformation("Histórico de demonstração criado para {Email}.", DemoEmail);
    }

    private static void SeedDemoUser(AppDbContext db)
    {
        if (db.Users.Any()) return;

        var (hash, salt) = PasswordHasher.Hash("1234");
        db.Users.Add(new User
        {
            Name = DemoName,
            Email = DemoEmail,
            PasswordHash = hash,
            PasswordSalt = salt,
            CreatedAt = DateTime.UtcNow.AddDays(-80),
        });
        db.SaveChanges();
    }

    // As respostas são sorteadas pelo próprio modelo da TRI (3PL) com os parâmetros reais dos
    // itens e uma proficiência θ por área que cresce ao longo das semanas: aluno mais forte em
    // Linguagens/Humanas e mais fraco em Matemática. Semente fixa, dados determinísticos.
    private static readonly Dictionary<string, (double Start, double End)> DemoTheta = new()
    {
        ["LC"] = (0.55, 0.95),
        ["CH"] = (0.35, 0.80),
        ["CN"] = (-0.35, 0.25),
        ["MT"] = (-0.60, 0.10),
    };

    private static readonly Dictionary<string, int> DemoSecondsPerQuestion = new()
    {
        ["LC"] = 140, ["CH"] = 150, ["CN"] = 200, ["MT"] = 215,
    };

    private static bool SeedDemoAttempts(AppDbContext db)
    {
        if (db.Attempts.Any()) return false;
        var user = db.Users.FirstOrDefault(u => u.Email == DemoEmail);
        if (user is null) return false;

        var pool = db.Questions
            .Include(q => q.Area)
            .Include(q => q.Topic)
            .Where(q => q.CorrectOption != null && (q.ForeignLanguage == null || q.ForeignLanguage == "ingles"))
            .ToList();
        if (pool.Count == 0) return false;

        var scales = PerformanceCalculator.ScaleLookup(db.TriScales.ToList());
        var rng = new Random(20260624);

        // (dias atrás, modo, área em foco, quantidade de questões)
        var specs = new (int DaysAgo, string Mode, string? Area, int Count)[]
        {
            (74, "geral", null, 20),
            (66, "foco", "MT", 10),
            (58, "geral", null, 30),
            (47, "foco", "CN", 15),
            (38, "geral", null, 45),
            (27, "foco", "MT", 15),
            (16, "geral", null, 30),
            (6,  "geral", null, 45),
        };

        for (int i = 0; i < specs.Length; i++)
        {
            var spec = specs[i];
            double progress = (double)i / (specs.Length - 1);
            var candidates = spec.Area is null ? pool : pool.Where(q => q.Area.Code == spec.Area).ToList();
            var selected = QuestionSelector.Select(candidates, spec.Area is null, spec.Count, rng);

            var startedAt = DateTime.UtcNow.AddDays(-spec.DaysAgo).AddHours(-rng.Next(1, 6));
            var attempt = new Attempt
            {
                UserId = user.Id,
                Mode = spec.Mode,
                AreaId = spec.Area is null ? null : selected[0].AreaId,
                ForeignLanguage = "ingles",
                StartedAt = startedAt,
                TimeLimitSeconds = selected.Count * QuestionSelector.SecondsPerQuestion,
            };

            int order = 0;
            foreach (var q in selected)
            {
                var (start, end) = DemoTheta[q.Area.Code];
                double theta = start + (end - start) * progress;
                double pCorrect = q.HasTriParameters
                    ? TriScorer.Probability(q.TriA!.Value, q.TriB!.Value, q.TriC!.Value, theta)
                    : 0.5;
                bool correct = rng.NextDouble() < pCorrect;
                // Itens mais difíceis tendem a tomar mais tempo.
                double difficultyFactor = q.TriB.HasValue ? 1 + Math.Clamp(q.TriB.Value - theta, -1, 2) * 0.15 : 1;
                int seconds = (int)(DemoSecondsPerQuestion[q.Area.Code] * difficultyFactor * (0.7 + rng.NextDouble() * 0.6));

                attempt.Answers.Add(new AttemptAnswer
                {
                    Question = q,
                    QuestionId = q.Id,
                    Order = ++order,
                    SelectedOption = correct ? q.CorrectOption : WrongOption(q.CorrectOption!.Value, rng),
                    IsCorrect = correct,
                    TimeSpentSeconds = seconds,
                });
            }

            attempt.TimeTakenSeconds = attempt.Answers.Sum(a => a.TimeSpentSeconds ?? 0);
            attempt.FinishedAt = startedAt.AddSeconds(attempt.TimeTakenSeconds.Value);
            foreach (var result in PerformanceCalculator.BuildAttemptResults(attempt.Answers, scales))
                attempt.Results.Add(result);

            db.Attempts.Add(attempt);
        }

        db.SaveChanges();
        return true;
    }

    private static char WrongOption(char correct, Random rng)
    {
        char c;
        do { c = (char)('A' + rng.Next(5)); } while (c == correct);
        return c;
    }
}
