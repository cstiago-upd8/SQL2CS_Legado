using System.ComponentModel.DataAnnotations;

namespace SQL2CS.Modernized.DTOs;

/// <summary>
/// Row projection used by the Chamado listing.
/// </summary>
/// <remarks>Derived from chamados.asp, excluir_chamado.asp, pesquisa_chamados.asp, sp_excluir_chamado, sp_salvar_chamado.</remarks>
public sealed class ChamadoListItem
{
    public int ChamadoId { get; set; }

    public string Titulo { get; set; } = string.Empty;

    public string? Prioridade { get; set; }

    public string? Status { get; set; }

    public string? TecnicoResp { get; set; }

    public DateTime DataCriacao { get; set; }

    public DateTime? DataAtualizacao { get; set; }
}
