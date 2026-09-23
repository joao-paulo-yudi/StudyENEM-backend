using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace StudyENEM.API.Data.Migrations
{
    /// <summary>
    /// Catálogo de fontes de estudo do plano (RF06): tabela <c>recurso</c> e a curadoria
    /// inicial de canais do YouTube, bancos de exercícios e materiais de apoio, por
    /// disciplina. O script fica em Data/Migrations/Sql/recursos_estudo.sql, embutido no
    /// assembly.
    /// </summary>
    public partial class RecursosDeEstudo : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "recurso",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    disciplina_id = table.Column<int>(type: "integer", nullable: true),
                    conteudo_id = table.Column<int>(type: "integer", nullable: true),
                    tipo = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    titulo = table.Column<string>(type: "text", nullable: false),
                    fonte = table.Column<string>(type: "text", nullable: false),
                    url_modelo = table.Column<string>(type: "text", nullable: false),
                    descricao = table.Column<string>(type: "text", nullable: true),
                    ordem = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_recurso", x => x.id);
                    table.ForeignKey(
                        name: "FK_recurso_conteudo_conteudo_id",
                        column: x => x.conteudo_id,
                        principalTable: "conteudo",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_recurso_disciplina_disciplina_id",
                        column: x => x.disciplina_id,
                        principalTable: "disciplina",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_recurso_conteudo_id",
                table: "recurso",
                column: "conteudo_id");

            migrationBuilder.CreateIndex(
                name: "IX_recurso_disciplina_id_conteudo_id_tipo",
                table: "recurso",
                columns: new[] { "disciplina_id", "conteudo_id", "tipo" });

            migrationBuilder.CreateIndex(
                name: "IX_recurso_disciplina_id_conteudo_id_url_modelo",
                table: "recurso",
                columns: new[] { "disciplina_id", "conteudo_id", "url_modelo" },
                unique: true)
                .Annotation("Npgsql:NullsDistinct", false);

            migrationBuilder.Sql(SqlScript.Load("recursos_estudo.sql"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "recurso");
        }
    }
}
