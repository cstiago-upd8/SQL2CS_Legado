using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SQL2CS.Modernized.Models;

namespace SQL2CS.Modernized.Data.Configurations;

/// <summary>
/// Fluent configuration for <see cref="Chamado"/>.
/// </summary>
/// <remarks>
/// Mirrors the constraints declared in the legacy DDL: column types, nullability,
/// defaults, and the foreign keys.
/// </remarks>
public sealed class ChamadoConfiguration : IEntityTypeConfiguration<Chamado>
{
    public void Configure(EntityTypeBuilder<Chamado> builder)
    {
        builder.ToTable("chamados");

        builder.HasKey(e => e.ChamadoId);

        builder.Property(e => e.ChamadoId)
            .HasColumnName("chamadoid")
            .HasColumnType("SERIAL")
            .ValueGeneratedOnAdd()
            .IsRequired(true);

        builder.Property(e => e.Titulo)
            .HasColumnName("titulo")
            .HasColumnType("VARCHAR(200)")
            .HasMaxLength(200)
            .IsRequired(true);

        builder.Property(e => e.Descricao)
            .HasColumnName("descricao")
            .HasColumnType("VARCHAR(4000)")
            .HasMaxLength(4000)
            .IsRequired(false);

        builder.Property(e => e.Prioridade)
            .HasColumnName("prioridade")
            .HasColumnType("VARCHAR(50)")
            .HasMaxLength(50)
            .HasDefaultValueSql("'Baixa'")
            .IsRequired(false);

        builder.Property(e => e.Status)
            .HasColumnName("status")
            .HasColumnType("VARCHAR(50)")
            .HasMaxLength(50)
            .HasDefaultValueSql("'Aberto'")
            .IsRequired(false);

        builder.Property(e => e.TecnicoResp)
            .HasColumnName("tecnicoresp")
            .HasColumnType("VARCHAR(200)")
            .HasMaxLength(200)
            .IsRequired(false);

        builder.Property(e => e.SolucaoTecnica)
            .HasColumnName("solucaotecnica")
            .HasColumnType("VARCHAR(4000)")
            .HasMaxLength(4000)
            .IsRequired(false);

        builder.Property(e => e.DataCriacao)
            .HasColumnName("datacriacao")
            .HasColumnType("TIMESTAMP")
            .HasDefaultValueSql("NOW()")
            .IsRequired(true);

        builder.Property(e => e.DataAtualizacao)
            .HasColumnName("dataatualizacao")
            .HasColumnType("TIMESTAMP")
            .IsRequired(false);
    }
}
