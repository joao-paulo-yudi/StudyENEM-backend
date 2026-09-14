namespace StudyENEM.API.Models;

/// <summary>
/// Transformação linear da proficiência θ (métrica dos parâmetros publicados pelo INEP)
/// para a escala de notas do ENEM, por área e ano: nota = intercepto + inclinação·θ
/// (tabela <c>escala_tri</c>). As constantes são calibradas pelo importador de dados
/// contra as notas oficiais dos microdados.
/// </summary>
public class TriScale
{
    public int Id { get; set; }
    public int AreaId { get; set; }
    public Area Area { get; set; } = null!;
    public int Year { get; set; }
    public double Intercept { get; set; }
    public double Slope { get; set; }
    public int CalibrationSampleSize { get; set; }
    public double CalibrationRmse { get; set; }
    public double CalibrationMaxError { get; set; }
}
