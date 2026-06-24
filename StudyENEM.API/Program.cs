using Microsoft.EntityFrameworkCore;
using StudyENEM.API.Data;
using StudyENEM.API.Services;

var builder = WebApplication.CreateBuilder(args);

// A string de conexão padrão aponta para localhost (uso local); no Docker é
// sobrescrita por ConnectionStrings__Default apontando para o serviço "postgres".
var connectionString = builder.Configuration.GetConnectionString("Default")
    ?? "Host=localhost;Port=5432;Database=studyenem;Username=studyenem;Password=studyenem";
builder.Services.AddDbContext<AppDbContext>(opt => opt.UseNpgsql(connectionString));

builder.Services.AddScoped<ExamService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
builder.Services.AddCors(opt =>
    opt.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    // O PostgreSQL pode levar alguns segundos para aceitar conexões na 1ª subida.
    for (var attempt = 1; ; attempt++)
    {
        try
        {
            db.Database.EnsureCreated();
            Seed.Apply(db);
            break;
        }
        catch (Exception ex) when (attempt < 10)
        {
            logger.LogWarning("Banco indisponível (tentativa {Attempt}/10): {Message}. Nova tentativa em 3s...", attempt, ex.Message);
            Thread.Sleep(3000);
        }
    }
}

app.UseCors();
app.UseSwagger();
app.UseSwaggerUI();
app.MapHealthChecks("/health");
app.MapControllers();
app.Run();
