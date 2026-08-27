using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using SQL2CS.Modernized.Data;
using SQL2CS.Modernized.DTOs;
using SQL2CS.Modernized.Exceptions;
using SQL2CS.Modernized.Models;
using SQL2CS.Modernized.Services;
using Xunit;

namespace SQL2CS.Modernized.Tests.Services;

/// <summary>
/// Tests for <see cref="ChamadoService"/>.
/// </summary>
/// <remarks>
/// Each business rule the legacy PL/pgSQL routine enforced gets a test, so a
/// regression in the converted logic fails the build rather than reaching
/// production.
/// </remarks>
public sealed class ChamadoServiceTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly ChamadoService _service;

    public ChamadoServiceTests()
    {
        // In-memory provider: these tests cover the converted logic, not the
        // PostgreSQL dialect.
        //
        // The service opens a real transaction because the legacy routine was
        // atomic, and the in-memory store ignores transactions and escalates
        // that to an error by default. The warning is downgraded here rather
        // than dropping the transaction: atomicity is behaviour worth keeping,
        // and it is the test double that cannot honour it.
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase($"Chamado-{Guid.NewGuid()}")
            .ConfigureWarnings(w => w.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .Options;

        _context = new AppDbContext(options);
        _service = new ChamadoService(_context);
    }

    public void Dispose()
    {
        _context.Dispose();
    }

    [Fact]
    public async Task SalvarAsync_WithNullKey_InsertsANewRow()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Aberto",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "SolucaoTecnica de teste",
        };

        var id = await _service.SalvarAsync(request);

        Assert.True(id > 0);
        Assert.Equal(1, await _context.Chamados.CountAsync());
    }

    [Fact]
    public async Task SalvarAsync_WithExistingKey_UpdatesInPlace()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Aberto",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "SolucaoTecnica de teste",
        };

        var id = await _service.SalvarAsync(request);

        request.ChamadoId = id;
        request.Titulo = "Alterado";

        var updatedId = await _service.SalvarAsync(request);

        Assert.Equal(id, updatedId);
        Assert.Equal(1, await _context.Chamados.CountAsync());
        Assert.Equal("Alterado", (await _context.Chamados.SingleAsync()).Titulo);
    }

    [Fact]
    public async Task SalvarAsync_WithResolvidoStatusAndNoSolution_Throws()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Resolvido",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "",
        };

        // The legacy routine raised this rule before touching the table.
        var exception = await Assert.ThrowsAsync<DomainException>(
            () => _service.SalvarAsync(request));

        Assert.Equal("A solucao tecnica deve ser preenchida para resolver ou fechar o chamado.", exception.Message);
        Assert.Equal(0, await _context.Chamados.CountAsync());
    }

    [Fact]
    public async Task SalvarAsync_WithFechadoStatusAndNoSolution_Throws()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Fechado",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "",
        };

        // The legacy routine raised this rule before touching the table.
        var exception = await Assert.ThrowsAsync<DomainException>(
            () => _service.SalvarAsync(request));

        Assert.Equal("A solucao tecnica deve ser preenchida para resolver ou fechar o chamado.", exception.Message);
        Assert.Equal(0, await _context.Chamados.CountAsync());
    }

    [Fact]
    public async Task SalvarAsync_WithResolvidoStatusAndASolution_Succeeds()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Resolvido",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "Reiniciado o servico.",
        };

        var id = await _service.SalvarAsync(request);

        Assert.True(id > 0);
    }

    [Fact]
    public async Task SalvarAsync_AlwaysWritesAnAuditRow()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Aberto",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "SolucaoTecnica de teste",
        };

        var id = await _service.SalvarAsync(request);

        // The legacy routine inserted a history row on every save.
        var history = await _context.HistoricoChamados
            .Where(h => h.ChamadoId == id)
            .ToListAsync();

        Assert.Single(history);
    }

    [Fact]
    public async Task ExcluirAsync_WithUnknownKey_Throws()
    {
        // The legacy routine guarded existence before deleting.
        var exception = await Assert.ThrowsAsync<DomainException>(
            () => _service.ExcluirAsync(9999));

        Assert.Equal("Chamado nao encontrado.", exception.Message);
    }

    [Fact]
    public async Task ExcluirAsync_RemovesTheRowAndItsHistory()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Aberto",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "SolucaoTecnica de teste",
        };

        var id = await _service.SalvarAsync(request);

        await _service.ExcluirAsync(id);

        Assert.Equal(0, await _context.Chamados.CountAsync());
        Assert.Equal(0, await _context.HistoricoChamados.CountAsync());
        // The legacy routine removed history rows before the parent.
    }

    [Fact]
    public async Task ListarAsync_WithoutFilters_ReturnsEveryRow()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Aberto",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "SolucaoTecnica de teste",
        };

        await _service.SalvarAsync(request);

        var all = await _service.ListarAsync();

        Assert.Single(all);
    }

    [Fact]
    public async Task ListarAsync_FiltersByStatus()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Aberto",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "SolucaoTecnica de teste",
        };

        await _service.SalvarAsync(request);

        var matching = await _service.ListarAsync(status: "Aberto");
        var other = await _service.ListarAsync(status: "Fechado");

        Assert.Single(matching);
        Assert.Empty(other);
    }

    [Fact]
    public async Task ObterAsync_WithAKnownKey_ReturnsTheRow()
    {
        var request = new ChamadoRequest
        {
            Titulo = "Titulo de teste",
            Descricao = "Descricao de teste",
            Prioridade = "Baixa",
            Status = "Aberto",
            TecnicoResp = "TecnicoResp de teste",
            SolucaoTecnica = "SolucaoTecnica de teste",
        };

        var id = await _service.SalvarAsync(request);

        var found = await _service.ObterAsync(id);

        Assert.NotNull(found);
    }

    [Fact]
    public async Task ObterAsync_WithAnUnknownKey_ReturnsNull()
    {
        var found = await _service.ObterAsync(9999);

        Assert.Null(found);
    }
}
