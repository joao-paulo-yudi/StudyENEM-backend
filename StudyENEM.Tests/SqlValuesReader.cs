using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace StudyENEM.Tests;

/// <summary>
/// Lê as linhas de um bloco <c>INSERT INTO tabela ... FROM (VALUES ...) AS v(colunas)</c> dos scripts de carga
/// das migrations. Assim os testes usam os mesmos dados que vão para o banco, sem manter uma cópia deles.
/// Entende apenas os literais gerados pelo importador: textos entre aspas simples, números e NULL.
/// </summary>
internal static partial class SqlValuesReader
{
    public static List<Dictionary<string, object?>> ReadRows(string script, string table)
    {
        int insert = script.IndexOf($"INSERT INTO {table} (", StringComparison.Ordinal);
        int values = insert < 0 ? -1 : script.IndexOf("FROM (VALUES", insert, StringComparison.Ordinal);
        if (values < 0) throw new InvalidDataException($"Bloco VALUES da tabela {table} não encontrado.");

        int pos = values + "FROM (VALUES".Length;
        var rows = new List<List<object?>>();
        while (true)
        {
            pos = SkipSpacesAndComments(script, pos);
            if (script[pos] == ')') break;
            if (script[pos] == ',') { pos++; continue; }

            Expect(script, pos++, '(');
            var row = new List<object?>();
            do
            {
                pos = SkipSpacesAndComments(script, pos);
                row.Add(ReadLiteral(script, ref pos));
                pos = SkipSpacesAndComments(script, pos);
            } while (script[pos++] == ',');
            Expect(script, pos - 1, ')');
            rows.Add(row);
        }

        var alias = ColumnAlias().Match(script, pos);
        if (!alias.Success) throw new InvalidDataException($"Nomes das colunas da tabela {table} não encontrados.");
        string[] columns = alias.Groups[1].Value.Split(',', StringSplitOptions.TrimEntries);

        return rows.Select(row => row.Count == columns.Length
            ? columns.Zip(row).ToDictionary(c => c.First, c => c.Second)
            : throw new InvalidDataException($"Linha da tabela {table} com {row.Count} valores; esperados {columns.Length}."))
            .ToList();
    }

    private static int SkipSpacesAndComments(string s, int pos)
    {
        while (true)
        {
            while (char.IsWhiteSpace(s[pos])) pos++;
            if (s[pos] != '-' || s[pos + 1] != '-') return pos;
            pos = s.IndexOf('\n', pos);
        }
    }

    private static object? ReadLiteral(string s, ref int pos)
    {
        if (s[pos] == '\'')
        {
            var text = new StringBuilder();
            for (pos++; ; pos++)
            {
                if (s[pos] != '\'') text.Append(s[pos]);
                else if (s[pos + 1] == '\'') text.Append(s[++pos]); // '' representa uma aspa
                else { pos++; return text.ToString(); }
            }
        }

        if (string.CompareOrdinal(s, pos, "NULL", 0, 4) == 0)
        {
            pos += 4;
            return null;
        }

        int start = pos;
        while ("+-.0123456789eE".Contains(s[pos])) pos++;
        if (pos == start) throw new InvalidDataException($"Literal inesperado na posição {pos}: '{s[pos]}'.");
        return double.Parse(s.AsSpan(start, pos - start), CultureInfo.InvariantCulture);
    }

    private static void Expect(string s, int pos, char expected)
    {
        if (s[pos] != expected)
            throw new InvalidDataException($"Esperado '{expected}' na posição {pos}; encontrado '{s[pos]}'.");
    }

    [GeneratedRegex(@"\G\)\s*AS v\(([^)]*)\)")]
    private static partial Regex ColumnAlias();
}
