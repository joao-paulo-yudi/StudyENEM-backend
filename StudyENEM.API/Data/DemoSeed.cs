using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Models;
using StudyENEM.API.Services;

namespace StudyENEM.API.Data;

/// <summary>Contas de demonstração. Configure por Demo__Accounts e Demo__Password.</summary>
public class DemoOptions
{
    public const string Section = "Demo";

    /// <summary>
    /// Quantidade de contas demo01..demoNN, todas com o mesmo histórico (ambiente de avaliação).
    /// Zero, o padrão, cria só a conta joao@studyenem.com do desenvolvimento.
    /// </summary>
    public int Accounts { get; set; }

    /// <summary>Senha comum às contas demoNN.</summary>
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Dados de demonstração: contas com um histórico de simulados para que os dashboards e o plano de
/// estudos tenham conteúdo. O banco de questões não é criado aqui, e sim pela migration CargaEnem2022.
/// </summary>
public static class DemoSeed
{
    public const int MaxAccounts = 99;

    private record DemoAccount(string Name, string Email, string Password);

    private static readonly DemoAccount DevelopmentAccount = new("João Teste", "joao@studyenem.com", "1234");

    private static IReadOnlyList<DemoAccount> Accounts(DemoOptions options) => options.Accounts > 0
        ? Enumerable.Range(1, options.Accounts)
            .Select(i => new DemoAccount($"Estudante Demo {i:00}", $"demo{i:00}@studyenem.com", options.Password))
            .ToList()
        : [DevelopmentAccount];

    /// <summary>
    /// Cria as contas que faltam e o histórico de cada conta que ainda não tem simulados.
    /// Idempotente: contas e históricos existentes não são alterados.
    /// </summary>
    public static void Apply(AppDbContext db, DemoOptions options, ILogger logger)
    {
        Validate(options);

        foreach (var account in Accounts(options))
        {
            var user = db.Users.FirstOrDefault(u => u.Email == account.Email);
            if (user is null)
            {
                user = NewUser(account);
                db.Users.Add(user);
                db.SaveChanges();
            }

            if (!db.Attempts.Any(a => a.UserId == user.Id) && SeedHistory(db, user))
                logger.LogInformation("Histórico de demonstração criado para {Email}.", account.Email);
        }
    }

    /// <summary>
    /// Volta o banco ao estado inicial da avaliação: apaga todos os simulados e todas as contas que não
    /// são demoNN (inclusive as criadas pelos avaliadores), restaura nome e senha das contas demoNN e
    /// recria os históricos. As contas demoNN mantêm o id, então quem já estava logado continua na
    /// mesma conta; os ids das contas apagadas nunca são reaproveitados.
    /// </summary>
    public static void Reset(AppDbContext db, DemoOptions options, ILogger logger)
    {
        Validate(options);
        // Sem contas demoNN, o reset apagaria as contas reais do desenvolvimento.
        if (options.Accounts == 0)
            throw new InvalidOperationException("O reset só existe no ambiente de avaliação (Demo__Accounts maior que zero).");

        var accounts = Accounts(options).ToDictionary(a => a.Email);
        var emails = accounts.Keys.ToList();

        using (var transaction = db.Database.BeginTransaction())
        {
            // simulado → resposta/resultado e usuario → simulado são apagados em cascata.
            int attempts = db.Attempts.ExecuteDelete();
            int users = db.Users.Where(u => !emails.Contains(u.Email)).ExecuteDelete();

            foreach (var user in db.Users.Where(u => emails.Contains(u.Email)).ToList())
            {
                var fresh = NewUser(accounts[user.Email]);
                user.Name = fresh.Name;
                user.PasswordHash = fresh.PasswordHash;
                user.PasswordSalt = fresh.PasswordSalt;
                user.GoogleId = null;
            }
            db.SaveChanges();
            transaction.Commit();

            logger.LogInformation("Reset: {Attempts} simulados e {Users} contas fora da lista demoNN apagados.", attempts, users);
        }

        db.ChangeTracker.Clear();
        Apply(db, options, logger);
    }

    private static void Validate(DemoOptions options)
    {
        if (options.Accounts is < 0 or > MaxAccounts)
            throw new InvalidOperationException($"Demo:Accounts precisa estar entre 0 e {MaxAccounts}.");
        if (options.Accounts > 0 && string.IsNullOrWhiteSpace(options.Password))
            throw new InvalidOperationException("Defina Demo:Password, a senha das contas demoNN.");
    }

    private static User NewUser(DemoAccount account)
    {
        var (hash, salt) = PasswordHasher.Hash(account.Password);
        return new User
        {
            Name = account.Name,
            Email = account.Email,
            PasswordHash = hash,
            PasswordSalt = salt,
            CreatedAt = DateTime.UtcNow.AddDays(-80),
        };
    }

    // As respostas são sorteadas pelo próprio modelo da TRI (3PL) com os parâmetros reais dos
    // itens e uma proficiência θ por área que cresce ao longo das semanas: aluno mais forte em
    // Linguagens, depois Humanas e Natureza, e claramente mais fraco em Matemática.
    private static readonly Dictionary<string, (double Start, double End)> DemoTheta = new()
    {
        ["LC"] = (0.70, 1.20),
        ["CH"] = (0.30, 0.80),
        ["CN"] = (-0.10, 0.40),
        ["MT"] = (-0.50, 0.00),
    };

    /// <summary>
    /// Conteúdo em que o aluno erra todas as questões. Fica fora de Matemática de propósito: a área
    /// mais fraca e o conteúdo prioritário exigem leituras diferentes do painel. O índice de
    /// dificuldade é a proporção de erros, sem ponderar o tamanho da amostra, então qualquer conteúdo
    /// com 1 erro em 1 questão também chega a 1,00: errar tudo num conteúdo com muitas respostas é o
    /// que o põe isolado no topo do plano, já que o empate é decidido pelo total de questões.
    /// </summary>
    private const string WeakTopic = "Eletricidade e magnetismo";

    private static readonly Dictionary<string, int> DemoSecondsPerQuestion = new()
    {
        ["LC"] = 140, ["CH"] = 150, ["CN"] = 200, ["MT"] = 215,
    };

    /// <summary>Semente fixa: toda conta recebe exatamente o mesmo histórico.</summary>
    private const int HistorySeed = 20260624;

    private static bool SeedHistory(AppDbContext db, User user)
    {
        // Ordenado por id: com a mesma semente, a mesma ordem do banco gera os mesmos sorteios.
        var pool = db.Questions
            .Include(q => q.Area)
            .Include(q => q.Topic)
            .Where(q => q.CorrectOption != null && (q.ForeignLanguage == null || q.ForeignLanguage == "ingles"))
            .OrderBy(q => q.Id)
            .ToList();
        if (pool.Count == 0) return false;

        var scales = PerformanceCalculator.ScaleLookup(db.TriScales.ToList());
        var rng = new Random(HistorySeed);

        // (dias atrás, modo, área em foco, conteúdo em foco, quantidade de questões)
        var specs = new (int DaysAgo, string Mode, string? Area, string? Topic, int Count)[]
        {
            (74, "geral", null, null, 20),
            (66, "foco", "MT", null, 10),
            (58, "geral", null, null, 30),
            (47, "foco", "CN", null, 15),
            (38, "geral", null, null, 45),
            (33, "foco", null, WeakTopic, 5),
            (27, "foco", "MT", null, 15),
            (21, "foco", null, WeakTopic, 5),
            (16, "geral", null, null, 30),
            (6,  "geral", null, null, 45),
        };

        for (int i = 0; i < specs.Length; i++)
        {
            var spec = specs[i];
            double progress = (double)i / (specs.Length - 1);
            var candidates = spec.Topic is not null ? pool.Where(q => q.Topic.Name == spec.Topic).ToList()
                : spec.Area is not null ? pool.Where(q => q.Area.Code == spec.Area).ToList()
                : pool;
            if (candidates.Count == 0) continue;
            var selected = QuestionSelector.Select(candidates, spec.Area is null && spec.Topic is null, spec.Count, rng);

            var startedAt = DateTime.UtcNow.AddDays(-spec.DaysAgo).AddHours(-rng.Next(1, 6));
            var attempt = new Attempt
            {
                UserId = user.Id,
                Mode = spec.Mode,
                AreaId = spec.Area is null ? null : selected[0].AreaId,
                TopicId = spec.Topic is null ? null : selected[0].TopicId,
                ForeignLanguage = "ingles",
                StartedAt = startedAt,
                TimeLimitSeconds = selected.Count * QuestionSelector.SecondsPerQuestion,
            };

            int order = 0;
            foreach (var q in selected)
            {
                var (start, end) = DemoTheta[q.Area.Code];
                double theta = start + (end - start) * progress;
                double pCorrect = q.Topic.Name == WeakTopic ? 0
                    : q.HasTriParameters ? TriScorer.Probability(q.TriA!.Value, q.TriB!.Value, q.TriC!.Value, theta)
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
