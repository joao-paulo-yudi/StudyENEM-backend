using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace StudyENEM.API.Data.Migrations
{
    /// <inheritdoc />
    public partial class CriacaoInicial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "area",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    sigla = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: false),
                    nome = table.Column<string>(type: "text", nullable: false),
                    ordem = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_area", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "usuario",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    nome = table.Column<string>(type: "text", nullable: false),
                    email = table.Column<string>(type: "text", nullable: false),
                    senha_hash = table.Column<string>(type: "text", nullable: false),
                    senha_salt = table.Column<string>(type: "text", nullable: false),
                    data_cadastro = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_usuario", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "disciplina",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    area_id = table.Column<int>(type: "integer", nullable: false),
                    nome = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_disciplina", x => x.id);
                    table.ForeignKey(
                        name: "FK_disciplina_area_area_id",
                        column: x => x.area_id,
                        principalTable: "area",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "escala_tri",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    area_id = table.Column<int>(type: "integer", nullable: false),
                    ano = table.Column<int>(type: "integer", nullable: false),
                    intercepto = table.Column<double>(type: "double precision", nullable: false),
                    inclinacao = table.Column<double>(type: "double precision", nullable: false),
                    calibracao_participantes = table.Column<int>(type: "integer", nullable: false),
                    calibracao_rmse = table.Column<double>(type: "double precision", nullable: false),
                    calibracao_erro_maximo = table.Column<double>(type: "double precision", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_escala_tri", x => x.id);
                    table.ForeignKey(
                        name: "FK_escala_tri_area_area_id",
                        column: x => x.area_id,
                        principalTable: "area",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "habilidade",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    area_id = table.Column<int>(type: "integer", nullable: false),
                    codigo = table.Column<int>(type: "integer", nullable: false),
                    competencia = table.Column<int>(type: "integer", nullable: false),
                    descricao = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_habilidade", x => x.id);
                    table.ForeignKey(
                        name: "FK_habilidade_area_area_id",
                        column: x => x.area_id,
                        principalTable: "area",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "conteudo",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    disciplina_id = table.Column<int>(type: "integer", nullable: false),
                    nome = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_conteudo", x => x.id);
                    table.ForeignKey(
                        name: "FK_conteudo_disciplina_disciplina_id",
                        column: x => x.disciplina_id,
                        principalTable: "disciplina",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "questao",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    area_id = table.Column<int>(type: "integer", nullable: false),
                    disciplina_id = table.Column<int>(type: "integer", nullable: false),
                    conteudo_id = table.Column<int>(type: "integer", nullable: false),
                    habilidade_id = table.Column<int>(type: "integer", nullable: false),
                    ano = table.Column<int>(type: "integer", nullable: false),
                    numero = table.Column<int>(type: "integer", nullable: false),
                    dia = table.Column<int>(type: "integer", nullable: false),
                    lingua_estrangeira = table.Column<string>(type: "text", nullable: true),
                    codigo_item_inep = table.Column<int>(type: "integer", nullable: false),
                    enunciado = table.Column<string>(type: "text", nullable: false),
                    gabarito = table.Column<char>(type: "character(1)", nullable: true),
                    tri_a = table.Column<double>(type: "double precision", nullable: true),
                    tri_b = table.Column<double>(type: "double precision", nullable: true),
                    tri_c = table.Column<double>(type: "double precision", nullable: true),
                    motivo_exclusao_tri = table.Column<string>(type: "text", nullable: true),
                    metodo_classificacao = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_questao", x => x.id);
                    table.ForeignKey(
                        name: "FK_questao_area_area_id",
                        column: x => x.area_id,
                        principalTable: "area",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_questao_conteudo_conteudo_id",
                        column: x => x.conteudo_id,
                        principalTable: "conteudo",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_questao_disciplina_disciplina_id",
                        column: x => x.disciplina_id,
                        principalTable: "disciplina",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_questao_habilidade_habilidade_id",
                        column: x => x.habilidade_id,
                        principalTable: "habilidade",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "simulado",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    usuario_id = table.Column<int>(type: "integer", nullable: false),
                    tipo = table.Column<string>(type: "text", nullable: false),
                    area_id = table.Column<int>(type: "integer", nullable: true),
                    conteudo_id = table.Column<int>(type: "integer", nullable: true),
                    lingua_estrangeira = table.Column<string>(type: "text", nullable: true),
                    data_inicio = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    data_fim = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    tempo_limite_segundos = table.Column<int>(type: "integer", nullable: true),
                    tempo_total_segundos = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_simulado", x => x.id);
                    table.ForeignKey(
                        name: "FK_simulado_area_area_id",
                        column: x => x.area_id,
                        principalTable: "area",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_simulado_conteudo_conteudo_id",
                        column: x => x.conteudo_id,
                        principalTable: "conteudo",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_simulado_usuario_usuario_id",
                        column: x => x.usuario_id,
                        principalTable: "usuario",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "alternativa",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    questao_id = table.Column<int>(type: "integer", nullable: false),
                    letra = table.Column<char>(type: "character(1)", nullable: false),
                    texto = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_alternativa", x => x.id);
                    table.ForeignKey(
                        name: "FK_alternativa_questao_questao_id",
                        column: x => x.questao_id,
                        principalTable: "questao",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "resposta",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    simulado_id = table.Column<int>(type: "integer", nullable: false),
                    questao_id = table.Column<int>(type: "integer", nullable: false),
                    ordem = table.Column<int>(type: "integer", nullable: false),
                    alternativa_selecionada = table.Column<char>(type: "character(1)", nullable: true),
                    correta = table.Column<bool>(type: "boolean", nullable: false),
                    tempo_resposta_segundos = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_resposta", x => x.id);
                    table.ForeignKey(
                        name: "FK_resposta_questao_questao_id",
                        column: x => x.questao_id,
                        principalTable: "questao",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_resposta_simulado_simulado_id",
                        column: x => x.simulado_id,
                        principalTable: "simulado",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "resultado",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    simulado_id = table.Column<int>(type: "integer", nullable: false),
                    area_id = table.Column<int>(type: "integer", nullable: false),
                    total_questoes = table.Column<int>(type: "integer", nullable: false),
                    total_acertos = table.Column<int>(type: "integer", nullable: false),
                    percentual_acerto = table.Column<double>(type: "double precision", nullable: false),
                    nota_tri = table.Column<double>(type: "double precision", nullable: true),
                    erro_padrao_tri = table.Column<double>(type: "double precision", nullable: true),
                    itens_tri = table.Column<int>(type: "integer", nullable: false),
                    tempo_medio_segundos = table.Column<double>(type: "double precision", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_resultado", x => x.id);
                    table.ForeignKey(
                        name: "FK_resultado_area_area_id",
                        column: x => x.area_id,
                        principalTable: "area",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_resultado_simulado_simulado_id",
                        column: x => x.simulado_id,
                        principalTable: "simulado",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_alternativa_questao_id_letra",
                table: "alternativa",
                columns: new[] { "questao_id", "letra" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_area_sigla",
                table: "area",
                column: "sigla",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_conteudo_disciplina_id_nome",
                table: "conteudo",
                columns: new[] { "disciplina_id", "nome" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_disciplina_area_id_nome",
                table: "disciplina",
                columns: new[] { "area_id", "nome" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_escala_tri_area_id_ano",
                table: "escala_tri",
                columns: new[] { "area_id", "ano" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_habilidade_area_id_codigo",
                table: "habilidade",
                columns: new[] { "area_id", "codigo" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_questao_ano_numero_lingua_estrangeira",
                table: "questao",
                columns: new[] { "ano", "numero", "lingua_estrangeira" },
                unique: true)
                .Annotation("Npgsql:NullsDistinct", false);

            migrationBuilder.CreateIndex(
                name: "IX_questao_area_id",
                table: "questao",
                column: "area_id");

            migrationBuilder.CreateIndex(
                name: "IX_questao_conteudo_id",
                table: "questao",
                column: "conteudo_id");

            migrationBuilder.CreateIndex(
                name: "IX_questao_disciplina_id",
                table: "questao",
                column: "disciplina_id");

            migrationBuilder.CreateIndex(
                name: "IX_questao_habilidade_id",
                table: "questao",
                column: "habilidade_id");

            migrationBuilder.CreateIndex(
                name: "IX_resposta_questao_id",
                table: "resposta",
                column: "questao_id");

            migrationBuilder.CreateIndex(
                name: "IX_resposta_simulado_id",
                table: "resposta",
                column: "simulado_id");

            migrationBuilder.CreateIndex(
                name: "IX_resultado_area_id",
                table: "resultado",
                column: "area_id");

            migrationBuilder.CreateIndex(
                name: "IX_resultado_simulado_id",
                table: "resultado",
                column: "simulado_id");

            migrationBuilder.CreateIndex(
                name: "IX_simulado_area_id",
                table: "simulado",
                column: "area_id");

            migrationBuilder.CreateIndex(
                name: "IX_simulado_conteudo_id",
                table: "simulado",
                column: "conteudo_id");

            migrationBuilder.CreateIndex(
                name: "IX_simulado_usuario_id",
                table: "simulado",
                column: "usuario_id");

            migrationBuilder.CreateIndex(
                name: "IX_usuario_email",
                table: "usuario",
                column: "email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "alternativa");

            migrationBuilder.DropTable(
                name: "escala_tri");

            migrationBuilder.DropTable(
                name: "resposta");

            migrationBuilder.DropTable(
                name: "resultado");

            migrationBuilder.DropTable(
                name: "questao");

            migrationBuilder.DropTable(
                name: "simulado");

            migrationBuilder.DropTable(
                name: "habilidade");

            migrationBuilder.DropTable(
                name: "conteudo");

            migrationBuilder.DropTable(
                name: "usuario");

            migrationBuilder.DropTable(
                name: "disciplina");

            migrationBuilder.DropTable(
                name: "area");
        }
    }
}
