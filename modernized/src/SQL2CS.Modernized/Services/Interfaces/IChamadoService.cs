using SQL2CS.Modernized.DTOs;

namespace SQL2CS.Modernized.Services.Interfaces;

/// <summary>
/// Service contract for the Chamado resource.
/// </summary>
/// <remarks>
/// Generated from the legacy PL/pgSQL routines and the inline queries of the
/// converted ASP pages. The implementation lives in <c>ChamadoService</c>.
///
/// Legacy sources:
/// <list type="bullet">
///   <item><description>chamados.asp</description></item>
///   <item><description>excluir_chamado.asp</description></item>
///   <item><description>pesquisa_chamados.asp</description></item>
///   <item><description>sp_excluir_chamado</description></item>
///   <item><description>sp_salvar_chamado</description></item>
/// </list>
/// </remarks>
public interface IChamadoService
{
    /// <summary>Converted from sp_excluir_chamado.</summary>
    /// <remarks>
    /// Business rules preserved from the legacy routine:
    /// <list type="bullet">
    ///   <item><description>Chamado nao encontrado.</description></item>
    /// </list>
    /// </remarks>
    /// <param name="chamadoId">Maps to <c>p_chamadoid</c>.</param>
    Task ExcluirAsync(int chamadoId);

    /// <summary>Replaces the inline filtered SELECT on the listing page.</summary>
    /// <param name="busca">The busca value.</param>
    /// <param name="status">The status value.</param>
    Task<IReadOnlyList<ChamadoListItem>> ListarAsync(string? busca = null, string? status = null);

    /// <summary>Replaces the inline SELECT by primary key on the form page.</summary>
    /// <param name="id">The id value.</param>
    Task<ChamadoResponse?> ObterAsync(int id);

    /// <summary>Converted from sp_salvar_chamado.</summary>
    /// <remarks>
    /// Business rules preserved from the legacy routine:
    /// <list type="bullet">
    ///   <item><description>A solucao tecnica deve ser preenchida para resolver ou fechar o chamado.</description></item>
    /// </list>
    /// </remarks>
    /// <param name="request">The request value.</param>
    Task<int> SalvarAsync(ChamadoRequest request);
}
