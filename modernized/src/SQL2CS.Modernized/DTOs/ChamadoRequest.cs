using System.ComponentModel.DataAnnotations;

namespace SQL2CS.Modernized.DTOs;

/// <summary>
/// Request payload for creating or updating a Chamado.
/// </summary>
/// <remarks>Derived from chamados.asp, excluir_chamado.asp, pesquisa_chamados.asp, sp_excluir_chamado, sp_salvar_chamado.</remarks>
public sealed class ChamadoRequest
{
    /// <summary>Maps to chamados.chamadoid. Leave null to insert.</summary>
    public int? ChamadoId { get; set; }

    /// <summary>Maps to chamados.titulo.</summary>
    [Required(ErrorMessage = "Titulo is required.")]
    [StringLength(200)]
    public string Titulo { get; set; } = string.Empty;

    /// <summary>Maps to chamados.descricao.</summary>
    [StringLength(4000)]
    public string? Descricao { get; set; }

    /// <summary>Maps to chamados.prioridade.</summary>
    [StringLength(50)]
    public string? Prioridade { get; set; }

    /// <summary>Maps to chamados.status.</summary>
    [StringLength(50)]
    public string? Status { get; set; }

    /// <summary>Maps to chamados.tecnicoresp.</summary>
    [StringLength(200)]
    public string? TecnicoResp { get; set; }

    /// <summary>Maps to chamados.solucaotecnica.</summary>
    [StringLength(4000)]
    public string? SolucaoTecnica { get; set; }
}
