using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StudyENEM.API.Data.Migrations
{
    /// <inheritdoc />
    public partial class LoginComGoogle : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "senha_salt",
                table: "usuario",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "senha_hash",
                table: "usuario",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<string>(
                name: "google_id",
                table: "usuario",
                type: "text",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_usuario_google_id",
                table: "usuario",
                column: "google_id",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_usuario_google_id",
                table: "usuario");

            migrationBuilder.DropColumn(
                name: "google_id",
                table: "usuario");

            migrationBuilder.AlterColumn<string>(
                name: "senha_salt",
                table: "usuario",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "senha_hash",
                table: "usuario",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);
        }
    }
}
