using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using StudyENEM.API.Data;
using StudyENEM.API.Infrastructure;
using StudyENEM.API.Services;

var builder = WebApplication.CreateBuilder(args);

// A string de conexão padrão aponta para localhost (uso local); no Docker é
// sobrescrita por ConnectionStrings__Default apontando para o serviço "postgres".
var connectionString = builder.Configuration.GetConnectionString("Default") ?? AppDbContextFactory.DefaultConnectionString;
builder.Services.AddDbContext<AppDbContext>(opt => opt.UseNpgsql(connectionString));
// O script de carga das questões tem centenas de KB: o texto dos comandos SQL executados
// não é registrado no log.
builder.Logging.AddFilter("Microsoft.EntityFrameworkCore.Database.Command", LogLevel.Warning);

// Autenticação por JWT (RNF03). Em produção, defina Jwt__Key com ao menos 32 caracteres.
var jwt = builder.Configuration.GetSection(JwtOptions.Section).Get<JwtOptions>() ?? new JwtOptions();
bool usingDevelopmentKey = string.IsNullOrWhiteSpace(jwt.Key);
if (usingDevelopmentKey) jwt.Key = "studyenem-chave-de-desenvolvimento-nao-usar-em-producao";
builder.Services.Configure<JwtOptions>(o =>
{
    o.Key = jwt.Key;
    o.Issuer = jwt.Issuer;
    o.Audience = jwt.Audience;
    o.ExpirationHours = jwt.ExpirationHours;
});
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.MapInboundClaims = false;
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwt.Issuer,
            ValidateAudience = true,
            ValidAudience = jwt.Audience,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Key)),
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1),
        };
    });
builder.Services.AddAuthorization();

builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<QuestionService>();
builder.Services.AddScoped<ExamService>();
builder.Services.AddScoped<DashboardService>();
builder.Services.AddControllers(o => o.Filters.Add<ApiExceptionFilter>());
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "StudyENEM API", Version = "v1" });
    var bearer = new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Token obtido em POST /api/auth/login",
        Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" },
    };
    c.AddSecurityDefinition("Bearer", bearer);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement { [bearer] = [] });
});
builder.Services.AddHealthChecks();
builder.Services.AddCors(opt =>
    opt.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    if (usingDevelopmentKey)
        logger.LogWarning("Jwt:Key não configurada: usando a chave de desenvolvimento. Defina Jwt__Key em produção.");

    // Aplica as migrations (esquema + banco de questões) e cria os dados de demonstração.
    DatabaseInitializer.Initialize(scope.ServiceProvider.GetRequiredService<AppDbContext>(), logger);
}

app.UseCors();
app.UseStaticFiles(); // wwwroot/midia: imagens das questões
app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health");
app.MapControllers();
app.Run();
