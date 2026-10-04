using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using StudyENEM.API.Data;
using StudyENEM.API.Infrastructure;
using StudyENEM.API.Services;

// Comandos de manutenção dos dados de demonstração, que rodam e encerram sem subir o servidor HTTP.
// No ambiente de avaliação: docker compose ... exec backend dotnet StudyENEM.API.dll demo reset
//   demo seed   aplica as migrations e cria as contas e os históricos que faltam (idempotente)
//   demo reset  volta ao estado inicial da avaliação (só com Demo__Accounts > 0)
string? demoCommand = args is ["demo", var command, ..] ? command : null;
if (demoCommand is not null and not ("seed" or "reset"))
{
    Console.Error.WriteLine("Uso: dotnet StudyENEM.API.dll demo seed|reset");
    Environment.ExitCode = 2;
    return;
}

var builder = WebApplication.CreateBuilder(demoCommand is null ? args : args[2..]);

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
// HMAC-SHA256 exige chave de 256 bits: uma chave curta só falharia no primeiro login (erro 500).
if (Encoding.UTF8.GetByteCount(jwt.Key) < 32)
    throw new InvalidOperationException("Jwt:Key precisa ter ao menos 32 caracteres. Gere uma com: openssl rand -hex 32");
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

// Login com Google (opcional): defina Google__ClientId com o ID do cliente OAuth 2.0 do
// Google Cloud Console. Sem ele, a API responde apenas ao login por e-mail e senha.
builder.Services.Configure<GoogleAuthOptions>(builder.Configuration.GetSection(GoogleAuthOptions.Section));

// Contas de demonstração: demo01..demoNN no ambiente de avaliação (Demo__Accounts e Demo__Password);
// sem configuração, só a conta joao@studyenem.com do desenvolvimento.
builder.Services.Configure<DemoOptions>(builder.Configuration.GetSection(DemoOptions.Section));

builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<GoogleAuthService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<QuestionService>();
builder.Services.AddScoped<ExamService>();
builder.Services.AddScoped<DashboardService>();
builder.Services.AddScoped<StudyPlanService>();
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
builder.Services.AddHealthChecks().AddCheck<DatabaseHealthCheck>("database");
builder.Services.Configure<ForwardedHeadersOptions>(ForwardedHeadersSetup.Configure);

// CORS só existe no desenvolvimento, quando o ng serve (porta 4200) chama a API na porta 8080.
// No Docker e na avaliação o nginx serve o frontend e a API na mesma origem, sem CORS.
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddCors(opt => opt.AddDefaultPolicy(p => p
        .WithOrigins("http://localhost:4200", "http://127.0.0.1:4200")
        .AllowAnyHeader()
        .AllowAnyMethod()));
}

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    if (usingDevelopmentKey)
        logger.LogWarning("Jwt:Key não configurada: usando a chave de desenvolvimento. Defina Jwt__Key em produção.");
    if (!scope.ServiceProvider.GetRequiredService<GoogleAuthService>().Enabled)
        logger.LogInformation("Google:ClientId não configurada: o login com Google fica indisponível na tela de login.");

    // Aplica as migrations (esquema + banco de questões) e cria os dados de demonstração.
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var demo = scope.ServiceProvider.GetRequiredService<IOptions<DemoOptions>>().Value;
    DatabaseInitializer.Initialize(db, demo, logger);
    if (demoCommand == "reset") DemoSeed.Reset(db, demo, logger);
}

if (demoCommand is not null) return;

// Primeiro do pipeline: esquema e IP do cliente vêm do proxy (X-Forwarded-Proto/For).
app.UseForwardedHeaders();

// Não há UseHttpsRedirection: o TLS termina na Cloudflare, e a API só recebe HTTP do nginx.
if (app.Environment.IsDevelopment())
{
    app.UseCors();
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseStaticFiles(); // wwwroot/midia: imagens das questões
app.UseAuthentication();
app.UseAuthorization();
app.MapHealthChecks("/health");
app.MapControllers();
app.Run();
