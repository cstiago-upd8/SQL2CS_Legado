using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SQL2CS.Modernized.Models;

namespace SQL2CS.Modernized.Data.Configurations;

/// <summary>
/// Fluent configuration for <see cref="HistoricoChamado"/>.
/// </summary>
/// <remarks>
/// Mirrors the constraints declared in the legacy DDL: column types, nullability,
/// defaults, and the foreign keys.
/// </remarks>
public sealed class HistoricoChamadoConfiguration : IEntityTypeConfiguration<HistoricoChamado>
{
    public void Configure(EntityTypeBuilder<HistoricoChamado> builder)
    {
        builder.ToTable("historicochamados");

        builder.HasKey(e => e.HistoricoId);

        builder.Property(e => e.HistoricoId)
            .HasColumnName("historicoid")
            .HasColumnType("SERIAL")
            .ValueGeneratedOnAdd()
            .IsRequired(true);

        builder.Property(e => e.ChamadoId)
            .HasColumnName("chamadoid")
            .HasColumnType("INT")
            .IsRequired(true);

        builder.Property(e => e.Status)
            .HasColumnName("status")
            .HasColumnType("VARCHAR(50)")
            .HasMaxLength(50)
            .IsRequired(false);

        builder.Property(e => e.TecnicoResp)
            .HasColumnName("tecnicoresp")
            .HasColumnType("VARCHAR(200)")
            .HasMaxLength(200)
            .IsRequired(false);

        builder.Property(e => e.DataRegistro)
            .HasColumnName("dataregistro")
            .HasColumnType("TIMESTAMP")
            .HasDefaultValueSql("NOW()")
            .IsRequired(true);

        // historicochamados.chamadoid references chamados.chamadoid.
        builder.HasOne(e => e.Chamado)
            .WithMany(t => t.HistoricoChamados)
            .HasForeignKey(e => e.ChamadoId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
