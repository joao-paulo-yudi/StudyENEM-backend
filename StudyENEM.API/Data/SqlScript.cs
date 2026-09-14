using System.Reflection;
using System.Text;

namespace StudyENEM.API.Data;

/// <summary>Lê os scripts SQL embutidos no assembly (pasta Data/Migrations/Sql), usados pelas migrations.</summary>
public static class SqlScript
{
    public static string Load(string fileName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        var resource = assembly.GetManifestResourceNames()
            .SingleOrDefault(name => name.EndsWith("." + fileName, StringComparison.Ordinal))
            ?? throw new FileNotFoundException($"Script SQL embutido não encontrado: {fileName}");

        using var stream = assembly.GetManifestResourceStream(resource)!;
        using var reader = new StreamReader(stream, Encoding.UTF8);
        return reader.ReadToEnd();
    }
}
