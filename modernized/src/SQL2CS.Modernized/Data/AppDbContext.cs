using Microsoft.EntityFrameworkCore;
using SQL2CS.Modernized.Models;

namespace SQL2CS.Modernized.Data;

/// <summary>
/// EF Core context for the converted schema.
/// </summary>
/// <remarks>
/// Replaces the <c>ADODB.Connection</c> the legacy pages opened directly. The
/// PostgreSQL schema is unchanged; only the access path is modernised.
/// </remarks>
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    /// <summary>Rows of <c>chamados</c>.</summary>
    public DbSet<Chamado> Chamados => Set<Chamado>();

    /// <summary>Rows of <c>historicochamados</c>.</summary>
    public DbSet<HistoricoChamado> HistoricoChamados => Set<HistoricoChamado>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configurations live beside the entities so each table's constraints
        // stay next to the shape they describe.
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}
