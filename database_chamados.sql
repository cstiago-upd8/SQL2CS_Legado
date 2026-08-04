-- ============================================================
-- Script SQL Server - Tabela e Stored Procedure para Chamados/OS
-- ============================================================

-- Criar tabela de Chamados
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Chamados]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Chamados] (
        ChamadoID       INT IDENTITY(1,1) PRIMARY KEY,
        Titulo          VARCHAR(200)  NOT NULL,
        Descricao       VARCHAR(4000) NULL,
        Prioridade      VARCHAR(50)   NULL DEFAULT 'Baixa',
        Status          VARCHAR(50)   NULL DEFAULT 'Aberto',
        TecnicoResp     VARCHAR(200)  NULL,
        SolucaoTecnica  VARCHAR(4000) NULL,
        DataCriacao     DATETIME      NOT NULL DEFAULT GETDATE(),
        DataAtualizacao DATETIME      NULL
    );
END
GO

-- Criar Stored Procedure sp_salvar_chamado
-- Insere se @ChamadoID for NULL, atualiza caso contrario
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_salvar_chamado]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[sp_salvar_chamado];
GO

CREATE PROCEDURE [dbo].[sp_salvar_chamado]
    @ChamadoID      INT           = NULL,
    @Titulo         VARCHAR(200),
    @Descricao      VARCHAR(4000) = NULL,
    @Prioridade     VARCHAR(50)   = 'Baixa',
    @Status         VARCHAR(50)   = 'Aberto',
    @TecnicoResp    VARCHAR(200)  = NULL,
    @SolucaoTecnica VARCHAR(4000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ChamadoID IS NULL
    BEGIN
        -- INSERT (novo chamado)
        INSERT INTO [dbo].[Chamados] (Titulo, Descricao, Prioridade, Status, TecnicoResp, SolucaoTecnica, DataCriacao)
        VALUES (@Titulo, @Descricao, @Prioridade, @Status, @TecnicoResp, @SolucaoTecnica, GETDATE());

        -- Retorna o ID gerado
        SELECT SCOPE_IDENTITY() AS NovoChamadoID;
    END
    ELSE
    BEGIN
        -- UPDATE (chamado existente)
        UPDATE [dbo].[Chamados]
        SET Titulo          = @Titulo,
            Descricao       = @Descricao,
            Prioridade      = @Prioridade,
            Status          = @Status,
            TecnicoResp     = @TecnicoResp,
            SolucaoTecnica  = @SolucaoTecnica,
            DataAtualizacao = GETDATE()
        WHERE ChamadoID = @ChamadoID;

        SELECT @ChamadoID AS NovoChamadoID;
    END
END
GO
