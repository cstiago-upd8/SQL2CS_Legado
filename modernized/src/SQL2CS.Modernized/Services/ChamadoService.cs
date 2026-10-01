using Microsoft.EntityFrameworkCore;
using SQL2CS.Modernized.Data;
using SQL2CS.Modernized.DTOs;
using SQL2CS.Modernized.Exceptions;
using SQL2CS.Modernized.Services.Interfaces;
using SQL2CS.Modernized.Models;

namespace SQL2CS.Modernized.Services;

/// <summary>
/// Implements <see cref="IChamadoService"/> over EF Core.
/// </summary>
/// <remarks>
/// Converted from the legacy PL/pgSQL routines. Every business rule the routines
/// enforced with <c>RAISE EXCEPTION</c> is preserved as a
/// <see cref="DomainException"/>.
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
public sealed class ChamadoService : IChamadoService
{
    private readonly AppDbContext _context;

    public ChamadoService(AppDbContext context)
    {
        _context = context;
    }

    /// <inheritdoc />
    /// <remarks>
    /// Business rules enforced here:
    /// <list type="bullet">
    ///   <item><description>Chamado nao encontrado.</description></item>
    /// </list>
    /// </remarks>
    /// <exception cref="DomainException">Raised when a business rule rejects the operation.</exception>
    public async Task ExcluirAsync(int chamadoId)
    {
        await using var transaction = await _context.Database.BeginTransactionAsync();

        // Business rule: Chamado nao encontrado.
        var entity = await _context.Chamados
            .FirstOrDefaultAsync(e => e.ChamadoId == chamadoId);

        if (entity is null)
        {
            throw new DomainException("Chamado nao encontrado.");
        }

        // The legacy routine removed the history rows before the parent.
        var history = await _context.HistoricoChamados
            .Where(h => h.ChamadoId == chamadoId)
            .ToListAsync();

        _context.HistoricoChamados.RemoveRange(history);

        _context.Chamados.Remove(entity);

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();
    }

    /// <inheritdoc />
    public async Task<IReadOnlyList<ChamadoListItem>> ListarAsync(string? busca = null, string? status = null)
    {
        // Composed IQueryable instead of the legacy concatenated WHERE 1=1.
        // Filters are parameterised, so the manual quote escaping is gone.
        var query = _context.Chamados.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(busca))
        {
            query = query.Where(e => (e.TecnicoResp != null && EF.Functions.ILike(e.TecnicoResp, $"%{busca}%")) || (e.Titulo != null && EF.Functions.ILike(e.Titulo, $"%{busca}%")));
        }

        if (!string.IsNullOrWhiteSpace(status) && status != "Todos")
        {
            query = query.Where(e => e.Status == status);
        }

        return await query
            .OrderByDescending(e => e.DataCriacao)
            .Select(e => new ChamadoListItem
            {
                ChamadoId = e.ChamadoId,
                Titulo = e.Titulo,
                Prioridade = e.Prioridade,
                Status = e.Status,
                TecnicoResp = e.TecnicoResp,
                DataCriacao = e.DataCriacao,
                DataAtualizacao = e.DataAtualizacao,
            })
            .ToListAsync();
    }

    /// <inheritdoc />
    public async Task<ChamadoResponse?> ObterAsync(int id)
    {
        return await _context.Chamados
            .AsNoTracking()
            .Where(e => e.ChamadoId == id)
            .Select(e => new ChamadoResponse
            {
                ChamadoId = e.ChamadoId,
                Titulo = e.Titulo,
                Descricao = e.Descricao,
                Prioridade = e.Prioridade,
                Status = e.Status,
                TecnicoResp = e.TecnicoResp,
                SolucaoTecnica = e.SolucaoTecnica,
                DataCriacao = e.DataCriacao,
                DataAtualizacao = e.DataAtualizacao,
            })
            .FirstOrDefaultAsync();
    }

    /// <inheritdoc />
    /// <remarks>
    /// Business rules enforced here:
    /// <list type="bullet">
    ///   <item><description>A solucao tecnica deve ser preenchida para resolver ou fechar o chamado.</description></item>
    /// </list>
    /// </remarks>
    /// <exception cref="DomainException">Raised when a business rule rejects the operation.</exception>
    public async Task<int> SalvarAsync(ChamadoRequest request)
    {
        // Business rule: A solucao tecnica deve ser preenchida para resolver ou fechar o chamado.
        var terminalStatuses = new[] { "Resolvido", "Fechado" };

        if (terminalStatuses.Contains(request.Status, StringComparer.OrdinalIgnoreCase)
            && string.IsNullOrWhiteSpace(request.SolucaoTecnica))
        {
            throw new DomainException("A solucao tecnica deve ser preenchida para resolver ou fechar o chamado.");
        }

        // One transaction: the legacy routine wrote the row and its audit
        // entry atomically, and losing the history on a partial failure
        // would break the audit trail.
        await using var transaction = await _context.Database.BeginTransactionAsync();

        Chamado entity;

        if (request.ChamadoId is null)
        {
            entity = new Chamado();
            entity.DataCriacao = DateTime.UtcNow;
            _context.Chamados.Add(entity);
        }
        else
        {
            entity = await _context.Chamados
                .FirstOrDefaultAsync(e => e.ChamadoId == request.ChamadoId.Value)
                ?? throw new DomainException($"Chamado {request.ChamadoId} nao encontrado.");
            entity.DataAtualizacao = DateTime.UtcNow;
        }

        entity.Titulo = request.Titulo;
        entity.Descricao = request.Descricao;
        entity.Prioridade = request.Prioridade;
        entity.Status = request.Status;
        entity.TecnicoResp = request.TecnicoResp;
        entity.SolucaoTecnica = request.SolucaoTecnica;

        await _context.SaveChangesAsync();

        // Audit trail, as the legacy routine wrote it.
        _context.HistoricoChamados.Add(new HistoricoChamado
        {
            ChamadoId = entity.ChamadoId,
            Status = entity.Status,
            TecnicoResp = entity.TecnicoResp,
            DataRegistro = DateTime.UtcNow,
        });

        await _context.SaveChangesAsync();

        await transaction.CommitAsync();

        return entity.ChamadoId;
    }
}
