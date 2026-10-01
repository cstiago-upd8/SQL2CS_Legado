using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SQL2CS.Modernized.Models;

/// <summary>
/// Maps the <c>historicochamados</c> table.
/// </summary>
/// <remarks>Generated from database_chamados_postgres.sql.</remarks>
[Table("historicochamados")]
public class HistoricoChamado
{
    /// <summary>Maps <c>historicochamados.historicoid</c> (SERIAL).</summary>
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    [Column("historicoid")]
    [Required]
    public int HistoricoId { get; set; }

    /// <summary>Maps <c>historicochamados.chamadoid</c> (INT).</summary>
    [Column("chamadoid")]
    [Required]
    public int ChamadoId { get; set; }

    /// <summary>Maps <c>historicochamados.status</c> (VARCHAR(50)).</summary>
    [Column("status")]
    [MaxLength(50)]
    public string? Status { get; set; }

    /// <summary>Maps <c>historicochamados.tecnicoresp</c> (VARCHAR(200)).</summary>
    [Column("tecnicoresp")]
    [MaxLength(200)]
    public string? TecnicoResp { get; set; }

    /// <summary>Maps <c>historicochamados.dataregistro</c> (TIMESTAMP).</summary>
    [Column("dataregistro")]
    [Required]
    public DateTime DataRegistro { get; set; }

    /// <summary>The Chamado this row belongs to.</summary>
    [ForeignKey(nameof(ChamadoId))]
    public Chamado? Chamado { get; set; }

}
