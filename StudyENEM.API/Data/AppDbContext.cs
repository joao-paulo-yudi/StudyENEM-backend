using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Models;

namespace StudyENEM.API.Data;

/// <summary>
/// Contexto do banco. As classes seguem a nomenclatura em inglês do código, mas as
/// tabelas e colunas são mapeadas com os nomes do Diagrama Entidade-Relacionamento
/// do relatório (usuario, simulado, resposta, questao, alternativa, resultado,
/// area, disciplina, conteudo), acrescido de habilidade e escala_tri.
/// O esquema e o banco de questões são criados pelas migrations em Data/Migrations.
/// </summary>
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Area> Areas => Set<Area>();
    public DbSet<Subject> Subjects => Set<Subject>();
    public DbSet<Topic> Topics => Set<Topic>();
    public DbSet<Skill> Skills => Set<Skill>();
    public DbSet<Question> Questions => Set<Question>();
    public DbSet<Alternative> Alternatives => Set<Alternative>();
    public DbSet<Attempt> Attempts => Set<Attempt>();
    public DbSet<AttemptAnswer> AttemptAnswers => Set<AttemptAnswer>();
    public DbSet<AttemptResult> AttemptResults => Set<AttemptResult>();
    public DbSet<TriScale> TriScales => Set<TriScale>();

    protected override void OnModelCreating(ModelBuilder mb)
    {
        mb.Entity<User>(e =>
        {
            e.ToTable("usuario");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.Name).HasColumnName("nome");
            e.Property(x => x.Email).HasColumnName("email");
            e.Property(x => x.PasswordHash).HasColumnName("senha_hash");
            e.Property(x => x.PasswordSalt).HasColumnName("senha_salt");
            e.Property(x => x.CreatedAt).HasColumnName("data_cadastro");
            e.HasIndex(x => x.Email).IsUnique();
        });

        mb.Entity<Area>(e =>
        {
            e.ToTable("area");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.Code).HasColumnName("sigla").HasMaxLength(2);
            e.Property(x => x.Name).HasColumnName("nome");
            e.Property(x => x.Order).HasColumnName("ordem");
            e.HasIndex(x => x.Code).IsUnique();
        });

        mb.Entity<Subject>(e =>
        {
            e.ToTable("disciplina");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.AreaId).HasColumnName("area_id");
            e.Property(x => x.Name).HasColumnName("nome");
            e.HasOne(x => x.Area).WithMany(a => a.Subjects).HasForeignKey(x => x.AreaId);
            e.HasIndex(x => new { x.AreaId, x.Name }).IsUnique();
        });

        mb.Entity<Topic>(e =>
        {
            e.ToTable("conteudo");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.SubjectId).HasColumnName("disciplina_id");
            e.Property(x => x.Name).HasColumnName("nome");
            e.HasOne(x => x.Subject).WithMany(s => s.Topics).HasForeignKey(x => x.SubjectId);
            e.HasIndex(x => new { x.SubjectId, x.Name }).IsUnique();
        });

        mb.Entity<Skill>(e =>
        {
            e.ToTable("habilidade");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.AreaId).HasColumnName("area_id");
            e.Property(x => x.Code).HasColumnName("codigo");
            e.Property(x => x.Competency).HasColumnName("competencia");
            e.Property(x => x.Description).HasColumnName("descricao");
            e.HasOne(x => x.Area).WithMany().HasForeignKey(x => x.AreaId);
            e.HasIndex(x => new { x.AreaId, x.Code }).IsUnique();
        });

        mb.Entity<Question>(e =>
        {
            e.ToTable("questao");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.AreaId).HasColumnName("area_id");
            e.Property(x => x.SubjectId).HasColumnName("disciplina_id");
            e.Property(x => x.TopicId).HasColumnName("conteudo_id");
            e.Property(x => x.SkillId).HasColumnName("habilidade_id");
            e.Property(x => x.Year).HasColumnName("ano");
            e.Property(x => x.Number).HasColumnName("numero");
            e.Property(x => x.Day).HasColumnName("dia");
            e.Property(x => x.ForeignLanguage).HasColumnName("lingua_estrangeira");
            e.Property(x => x.InepItemCode).HasColumnName("codigo_item_inep");
            e.Property(x => x.Statement).HasColumnName("enunciado");
            e.Property(x => x.CorrectOption).HasColumnName("gabarito");
            e.Property(x => x.TriA).HasColumnName("tri_a");
            e.Property(x => x.TriB).HasColumnName("tri_b");
            e.Property(x => x.TriC).HasColumnName("tri_c");
            e.Property(x => x.TriExclusionReason).HasColumnName("motivo_exclusao_tri");
            e.Property(x => x.ClassificationMethod).HasColumnName("metodo_classificacao");
            e.HasOne(x => x.Area).WithMany().HasForeignKey(x => x.AreaId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(x => x.Subject).WithMany().HasForeignKey(x => x.SubjectId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(x => x.Topic).WithMany().HasForeignKey(x => x.TopicId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(x => x.Skill).WithMany().HasForeignKey(x => x.SkillId).OnDelete(DeleteBehavior.Restrict);
            // Uma questão por número, ano e língua estrangeira (NULLS NOT DISTINCT: PostgreSQL 15+).
            e.HasIndex(x => new { x.Year, x.Number, x.ForeignLanguage }).IsUnique().AreNullsDistinct(false);
        });

        mb.Entity<Alternative>(e =>
        {
            e.ToTable("alternativa");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.QuestionId).HasColumnName("questao_id");
            e.Property(x => x.Letter).HasColumnName("letra");
            e.Property(x => x.Text).HasColumnName("texto");
            e.HasOne(x => x.Question).WithMany(q => q.Alternatives).HasForeignKey(x => x.QuestionId);
            e.HasIndex(x => new { x.QuestionId, x.Letter }).IsUnique();
        });

        mb.Entity<Attempt>(e =>
        {
            e.ToTable("simulado");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.UserId).HasColumnName("usuario_id");
            e.Property(x => x.Mode).HasColumnName("tipo");
            e.Property(x => x.AreaId).HasColumnName("area_id");
            e.Property(x => x.TopicId).HasColumnName("conteudo_id");
            e.Property(x => x.ForeignLanguage).HasColumnName("lingua_estrangeira");
            e.Property(x => x.StartedAt).HasColumnName("data_inicio");
            e.Property(x => x.FinishedAt).HasColumnName("data_fim");
            e.Property(x => x.TimeLimitSeconds).HasColumnName("tempo_limite_segundos");
            e.Property(x => x.TimeTakenSeconds).HasColumnName("tempo_total_segundos");
            e.HasOne(x => x.User).WithMany(u => u.Attempts).HasForeignKey(x => x.UserId);
            e.HasOne(x => x.Area).WithMany().HasForeignKey(x => x.AreaId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(x => x.Topic).WithMany().HasForeignKey(x => x.TopicId).OnDelete(DeleteBehavior.Restrict);
        });

        mb.Entity<AttemptAnswer>(e =>
        {
            e.ToTable("resposta");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.AttemptId).HasColumnName("simulado_id");
            e.Property(x => x.QuestionId).HasColumnName("questao_id");
            e.Property(x => x.Order).HasColumnName("ordem");
            e.Property(x => x.SelectedOption).HasColumnName("alternativa_selecionada");
            e.Property(x => x.IsCorrect).HasColumnName("correta");
            e.Property(x => x.TimeSpentSeconds).HasColumnName("tempo_resposta_segundos");
            e.HasOne(x => x.Attempt).WithMany(a => a.Answers).HasForeignKey(x => x.AttemptId);
            e.HasOne(x => x.Question).WithMany(q => q.Answers).HasForeignKey(x => x.QuestionId).OnDelete(DeleteBehavior.Restrict);
        });

        mb.Entity<AttemptResult>(e =>
        {
            e.ToTable("resultado");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.AttemptId).HasColumnName("simulado_id");
            e.Property(x => x.AreaId).HasColumnName("area_id");
            e.Property(x => x.TotalQuestions).HasColumnName("total_questoes");
            e.Property(x => x.TotalCorrect).HasColumnName("total_acertos");
            e.Property(x => x.Percentage).HasColumnName("percentual_acerto");
            e.Property(x => x.TriScore).HasColumnName("nota_tri");
            e.Property(x => x.TriStandardError).HasColumnName("erro_padrao_tri");
            e.Property(x => x.TriItems).HasColumnName("itens_tri");
            e.Property(x => x.AverageTimeSeconds).HasColumnName("tempo_medio_segundos");
            e.HasOne(x => x.Attempt).WithMany(a => a.Results).HasForeignKey(x => x.AttemptId);
            e.HasOne(x => x.Area).WithMany().HasForeignKey(x => x.AreaId).OnDelete(DeleteBehavior.Restrict);
        });

        mb.Entity<TriScale>(e =>
        {
            e.ToTable("escala_tri");
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.AreaId).HasColumnName("area_id");
            e.Property(x => x.Year).HasColumnName("ano");
            e.Property(x => x.Intercept).HasColumnName("intercepto");
            e.Property(x => x.Slope).HasColumnName("inclinacao");
            e.Property(x => x.CalibrationSampleSize).HasColumnName("calibracao_participantes");
            e.Property(x => x.CalibrationRmse).HasColumnName("calibracao_rmse");
            e.Property(x => x.CalibrationMaxError).HasColumnName("calibracao_erro_maximo");
            e.HasOne(x => x.Area).WithMany().HasForeignKey(x => x.AreaId);
            e.HasIndex(x => new { x.AreaId, x.Year }).IsUnique();
        });
    }
}
