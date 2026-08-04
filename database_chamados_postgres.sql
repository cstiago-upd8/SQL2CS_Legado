-- ============================================================
-- Script PostgreSQL - Tabelas e Funcoes para Chamados/OS
-- Banco: sql2cs | Host: 3.81.116.88
-- ============================================================

-- Criar tabela de Chamados
CREATE TABLE IF NOT EXISTS chamados (
    chamadoid       SERIAL PRIMARY KEY,
    titulo          VARCHAR(200) NOT NULL,
    descricao       VARCHAR(4000),
    prioridade      VARCHAR(50) DEFAULT 'Baixa',
    status          VARCHAR(50) DEFAULT 'Aberto',
    tecnicoresp     VARCHAR(200),
    solucaotecnica  VARCHAR(4000),
    datacriacao     TIMESTAMP NOT NULL DEFAULT NOW(),
    dataatualizacao TIMESTAMP
);

-- Criar tabela de Historico
CREATE TABLE IF NOT EXISTS historicochamados (
    historicoid     SERIAL PRIMARY KEY,
    chamadoid       INT NOT NULL REFERENCES chamados(chamadoid),
    status          VARCHAR(50),
    tecnicoresp     VARCHAR(200),
    dataregistro    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Funcao: sp_salvar_chamado (equivalente a stored procedure)
-- Retorna o ID do chamado (inserido ou atualizado)
-- ============================================================
CREATE OR REPLACE FUNCTION sp_salvar_chamado(
    p_chamadoid      INT DEFAULT NULL,
    p_titulo         VARCHAR DEFAULT NULL,
    p_descricao      VARCHAR DEFAULT NULL,
    p_prioridade     VARCHAR DEFAULT 'Baixa',
    p_status         VARCHAR DEFAULT 'Aberto',
    p_tecnicoresp    VARCHAR DEFAULT NULL,
    p_solucaotecnica VARCHAR DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_chamadoid INT;
BEGIN
    -- Regra de negocio: solucao obrigatoria para Resolvido/Fechado
    IF p_status IN ('Resolvido', 'Fechado') AND (COALESCE(TRIM(p_solucaotecnica), '') = '') THEN
        RAISE EXCEPTION 'A solucao tecnica deve ser preenchida para resolver ou fechar o chamado.';
    END IF;

    IF p_chamadoid IS NULL THEN
        -- INSERT
        INSERT INTO chamados (titulo, descricao, prioridade, status, tecnicoresp, solucaotecnica, datacriacao)
        VALUES (p_titulo, p_descricao, p_prioridade, p_status, p_tecnicoresp, p_solucaotecnica, NOW())
        RETURNING chamadoid INTO v_chamadoid;
    ELSE
        -- UPDATE
        UPDATE chamados
        SET titulo          = p_titulo,
            descricao       = p_descricao,
            prioridade      = p_prioridade,
            status          = p_status,
            tecnicoresp     = p_tecnicoresp,
            solucaotecnica  = p_solucaotecnica,
            dataatualizacao = NOW()
        WHERE chamadoid = p_chamadoid;

        v_chamadoid := p_chamadoid;
    END IF;

    -- Historico/Auditoria
    INSERT INTO historicochamados (chamadoid, status, tecnicoresp, dataregistro)
    VALUES (v_chamadoid, p_status, p_tecnicoresp, NOW());

    RETURN v_chamadoid;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Funcao: sp_excluir_chamado
-- ============================================================
CREATE OR REPLACE FUNCTION sp_excluir_chamado(p_chamadoid INT)
RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM chamados WHERE chamadoid = p_chamadoid) THEN
        RAISE EXCEPTION 'Chamado nao encontrado.';
    END IF;

    DELETE FROM historicochamados WHERE chamadoid = p_chamadoid;
    DELETE FROM chamados WHERE chamadoid = p_chamadoid;
END;
$$ LANGUAGE plpgsql;
