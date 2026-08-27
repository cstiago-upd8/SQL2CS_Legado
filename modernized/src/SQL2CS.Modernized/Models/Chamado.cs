using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SQL2CS.Modernized.Models;

/// <summary>
/// Maps the <c>chamados</c> table.
/// </summary>
/// <remarks>Generated from database_chamados_postgres.sql.</remarks>
[Table("chamados")]
public class Chamado
{
    /// <summary>Maps <c>chamados.chamadoid</c> (SERIAL).</summary>
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    [Column("chamadoid")]
    [Required]
    public int ChamadoId { get; set; }

    /// <summary>Maps <c>chamados.titulo</c> (VARCHAR(200)).</summary>
    [Column("titulo")]
    [Required]
    [MaxLength(200)]
    public string Titulo { get; set; } = string.Empty;

    /// <summary>Maps <c>chamados.descricao</c> (VARCHAR(4000)).</summary>
    [Column("descricao")]
    [MaxLength(4000)]
    public string? Descricao { get; set; }

    /// <summary>Maps <c>chamados.prioridade</c> (VARCHAR(50)).</summary>
    [Column("prioridade")]
    [MaxLength(50)]
    public string? Prioridade { get; set; }

    /// <summary>Maps <c>chamados.status</c> (VARCHAR(50)).</summary>
    [Column("status")]
    [MaxLength(50)]
    public string? Status { get; set; }

    /// <summary>Maps <c>chamados.tecnicoresp</c> (VARCHAR(200)).</summary>
    [Column("tecnicoresp")]
    [MaxLength(200)]
    public string? TecnicoResp { get; set; }

    /// <summary>Maps <c>chamados.solucaotecnica</c> (VARCHAR(4000)).</summary>
    [Column("solucaotecnica")]
    [MaxLength(4000)]
    public string? SolucaoTecnica { get; set; }

    /// <summary>Maps <c>chamados.datacriacao</c> (TIMESTAMP).</summary>
    [Column("datacriacao")]
    [Required]
    public DateTime DataCriacao { get; set; }

    /// <summary>Maps <c>chamados.dataatualizacao</c> (TIMESTAMP).</summary>
    [Column("dataatualizacao")]
    public DateTime? DataAtualizacao { get; set; }

    /// <summary>HistoricoChamado rows that reference this one.</summary>
    public ICollection<HistoricoChamado> HistoricoChamados { get; set; } = new List<HistoricoChamado>();

}
