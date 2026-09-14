using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StudyENEM.API.Data.Migrations
{
    /// <summary>
    /// Carga do banco de questões do ENEM 2022 (1ª aplicação, caderno azul): áreas, habilidades da
    /// Matriz de Referência, disciplinas, conteúdos, escalas da TRI, 185 questões e suas alternativas.
    /// O script SQL (Data/Migrations/Sql/enem_2022.sql) é gerado por tools/enem-import/importar_enem.py
    /// e fica embutido no assembly.
    /// </summary>
    public partial class CargaEnem2022 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(SqlScript.Load("enem_2022.sql"));
        }

        /// <summary>
        /// Remove a carga. Falha (e a migration é desfeita) se alguma questão já tiver sido respondida em simulados.
        /// </summary>
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                DELETE FROM alternativa WHERE questao_id IN (SELECT id FROM questao WHERE ano = 2022);
                DELETE FROM questao WHERE ano = 2022;
                DELETE FROM escala_tri WHERE ano = 2022;
                DELETE FROM conteudo c
                 WHERE NOT EXISTS (SELECT 1 FROM questao q WHERE q.conteudo_id = c.id)
                   AND NOT EXISTS (SELECT 1 FROM simulado s WHERE s.conteudo_id = c.id);
                DELETE FROM disciplina d
                 WHERE NOT EXISTS (SELECT 1 FROM conteudo c WHERE c.disciplina_id = d.id)
                   AND NOT EXISTS (SELECT 1 FROM questao q WHERE q.disciplina_id = d.id);
                DELETE FROM habilidade h
                 WHERE NOT EXISTS (SELECT 1 FROM questao q WHERE q.habilidade_id = h.id);
                DELETE FROM area a
                 WHERE NOT EXISTS (SELECT 1 FROM disciplina d WHERE d.area_id = a.id)
                   AND NOT EXISTS (SELECT 1 FROM habilidade h WHERE h.area_id = a.id)
                   AND NOT EXISTS (SELECT 1 FROM escala_tri e WHERE e.area_id = a.id)
                   AND NOT EXISTS (SELECT 1 FROM questao q WHERE q.area_id = a.id)
                   AND NOT EXISTS (SELECT 1 FROM simulado s WHERE s.area_id = a.id)
                   AND NOT EXISTS (SELECT 1 FROM resultado r WHERE r.area_id = a.id);
                """);
        }
    }
}
