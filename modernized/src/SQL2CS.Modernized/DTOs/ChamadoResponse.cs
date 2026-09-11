using System.ComponentModel.DataAnnotations;

namespace SQL2CS.Modernized.DTOs;

/// <summary>
/// Full representation of a Chamado.
/// </summary>
/// <remarks>Derived from chamados.asp, excluir_chamado.asp, pesquisa_chamados.asp, sp_excluir_chamado, sp_salvar_chamado.</remarks>
public sealed class ChamadoResponse
{
    /// <summary>Maps to chamados.chamadoid.</summary>
    public int ChamadoId { get; set; }

    /// <summary>Maps to chamados.titulo.</summary>
    public string Titulo { get; set; } = string.Empty;

    /// <summary>Maps to chamados.descricao.</summary>
    public string? Descricao { get; set; }

    /// <summary>Maps to chamados.prioridade.</summary>
    public string? Prioridade { get; set; }

    /// <summary>Maps to chamados.status.</summary>
    public string? Status { get; set; }

    /// <summary>Maps to chamados.tecnicoresp.</summary>
    public string? TecnicoResp { get; set; }

    /// <summary>Maps to chamados.solucaotecnica.</summary>
    public string? SolucaoTecnica { get; set; }

    /// <summary>Maps to chamados.datacriacao.</summary>
    public DateTime DataCriacao { get; set; }

    /// <summary>Maps to chamados.dataatualizacao.</summary>
    public DateTime? DataAtualizacao { get; set; }
}
