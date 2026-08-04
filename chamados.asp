<%@ Language="VBScript" %>
<%
Option Explicit
Response.CharSet = "UTF-8"
%>
<!-- #include file="config.asp" -->
<%

' ============================================================
' Gerenciamento de Chamados/OS - ASP Classico
' Padrao Visual UPD8 (www.upd8.com.br)
' ============================================================

Dim conn, cmd, rs
Dim sChamadoID, sTitulo, sDescricao, sPrioridade, sStatus, sTecnico, sSolucao
Dim sMensagem, sMsgTipo

sMensagem = ""
sMsgTipo = ""

' --- Processar POST (salvar chamado) ---
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    sChamadoID  = Trim(Request.Form("ChamadoID"))
    sTitulo     = Trim(Request.Form("Titulo"))
    sDescricao  = Trim(Request.Form("Descricao"))
    sPrioridade = Trim(Request.Form("Prioridade"))
    sStatus     = Trim(Request.Form("Status"))
    sTecnico    = Trim(Request.Form("TecnicoResp"))
    sSolucao    = Trim(Request.Form("SolucaoTecnica"))

    On Error Resume Next

    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open DB_CONNECTION_STRING

    If Err.Number <> 0 Then
        sMensagem = "Erro ao conectar no banco: " & Err.Description
        sMsgTipo = "erro"
        Err.Clear
    Else
        Set cmd = Server.CreateObject("ADODB.Command")
        Set cmd.ActiveConnection = conn
        cmd.CommandType = 4 ' adCmdStoredProc
        cmd.CommandText = "sp_salvar_chamado"

        ' Parametros da Stored Procedure
        If sChamadoID = "" Then
            cmd.Parameters.Append cmd.CreateParameter("@ChamadoID", 3, 1, , Null) ' adInteger, adParamInput
        Else
            cmd.Parameters.Append cmd.CreateParameter("@ChamadoID", 3, 1, , CLng(sChamadoID))
        End If
        cmd.Parameters.Append cmd.CreateParameter("@Titulo", 200, 1, 200, sTitulo)         ' adVarChar
        cmd.Parameters.Append cmd.CreateParameter("@Descricao", 200, 1, 4000, sDescricao)  ' adVarChar
        cmd.Parameters.Append cmd.CreateParameter("@Prioridade", 200, 1, 50, sPrioridade)
        cmd.Parameters.Append cmd.CreateParameter("@Status", 200, 1, 50, sStatus)
        cmd.Parameters.Append cmd.CreateParameter("@TecnicoResp", 200, 1, 200, sTecnico)
        cmd.Parameters.Append cmd.CreateParameter("@SolucaoTecnica", 200, 1, 4000, sSolucao)

        cmd.Execute

        If Err.Number <> 0 Then
            sMensagem = "Erro ao salvar chamado: " & Err.Description
            sMsgTipo = "erro"
            Err.Clear
        Else
            ' Redirecionar para pesquisa apos salvar com sucesso
            Set cmd = Nothing
            conn.Close
            Set conn = Nothing
            Response.Redirect "pesquisa_chamados.asp?msg=salvo"
        End If

        Set cmd = Nothing
        conn.Close
        Set conn = Nothing
    End If

    On Error GoTo 0
End If

' --- Carregar chamado para edicao (via QueryString) ---
If Request.QueryString("id") <> "" And sMensagem = "" Then
    On Error Resume Next

    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open DB_CONNECTION_STRING

    If Err.Number = 0 Then
        Set rs = conn.Execute("SELECT ChamadoID, Titulo, Descricao, Prioridade, Status, TecnicoResp, SolucaoTecnica FROM Chamados WHERE ChamadoID = " & CLng(Request.QueryString("id")))
        If Not rs.EOF Then
            sChamadoID  = rs("ChamadoID")
            sTitulo     = rs("Titulo") & ""
            sDescricao  = rs("Descricao") & ""
            sPrioridade = rs("Prioridade") & ""
            sStatus     = rs("Status") & ""
            sTecnico    = rs("TecnicoResp") & ""
            sSolucao    = rs("SolucaoTecnica") & ""
        End If
        rs.Close
        Set rs = Nothing
        conn.Close
    End If

    Set conn = Nothing
    On Error GoTo 0
End If
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gerenciamento de Chamados/OS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* ========== RESET & BASE ========== */
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: #f4f6f9;
            color: #333;
            line-height: 1.6;
            min-height: 100vh;
        }

        /* ========== PALETA UPD8 ========== */
        :root {
            --azul-primario: #1a56db;
            --azul-marinho: #0f2b5b;
            --azul-hover: #1443b0;
            --azul-focus: rgba(26, 86, 219, 0.25);
            --cinza-fundo: #f4f6f9;
            --branco: #ffffff;
            --cinza-borda: #d1d5db;
            --cinza-texto: #6b7280;
            --verde-sucesso: #059669;
            --verde-bg: #ecfdf5;
            --vermelho-erro: #dc2626;
            --vermelho-bg: #fef2f2;
            --sombra-card: 0 4px 24px rgba(0, 0, 0, 0.08);
            --radius: 8px;
        }

        /* ========== NAVBAR ========== */
        .navbar {
            background: linear-gradient(135deg, var(--azul-marinho), var(--azul-primario));
            padding: 16px 32px;
            display: flex;
            align-items: center;
            gap: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        }

        .navbar-logo {
            width: 36px;
            height: 36px;
            background: var(--branco);
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: var(--azul-primario);
            font-size: 14px;
        }

        .navbar-title {
            color: var(--branco);
            font-size: 1.25rem;
            font-weight: 600;
            letter-spacing: -0.3px;
        }

        .navbar-subtitle {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.85rem;
            margin-left: auto;
        }

        /* ========== CONTAINER PRINCIPAL ========== */
        .container {
            max-width: 720px;
            margin: 40px auto;
            padding: 0 20px;
        }

        /* ========== CARD DO FORMULARIO ========== */
        .card {
            background: var(--branco);
            border-radius: var(--radius);
            box-shadow: var(--sombra-card);
            padding: 36px 40px;
        }

        .card-header {
            margin-bottom: 28px;
            padding-bottom: 16px;
            border-bottom: 1px solid #e5e7eb;
        }

        .card-header h2 {
            font-size: 1.35rem;
            font-weight: 700;
            color: var(--azul-marinho);
        }

        .card-header p {
            font-size: 0.875rem;
            color: var(--cinza-texto);
            margin-top: 4px;
        }

        /* ========== MENSAGENS ========== */
        .mensagem {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 24px;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .mensagem.sucesso {
            background: var(--verde-bg);
            color: var(--verde-sucesso);
            border: 1px solid #a7f3d0;
        }

        .mensagem.erro {
            background: var(--vermelho-bg);
            color: var(--vermelho-erro);
            border: 1px solid #fecaca;
        }

        /* ========== FORMULARIO ========== */
        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 0.875rem;
            font-weight: 600;
            color: #374151;
            margin-bottom: 6px;
        }

        .form-group label .obrigatorio {
            color: var(--vermelho-erro);
            margin-left: 2px;
        }

        .form-control {
            width: 100%;
            padding: 10px 14px;
            font-size: 0.925rem;
            font-family: 'Inter', sans-serif;
            border: 1px solid var(--cinza-borda);
            border-radius: 6px;
            background: var(--branco);
            color: #1f2937;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
            outline: none;
        }

        .form-control:focus {
            border-color: var(--azul-primario);
            box-shadow: 0 0 0 3px var(--azul-focus);
        }

        .form-control::placeholder {
            color: #9ca3af;
        }

        textarea.form-control {
            resize: vertical;
            min-height: 100px;
        }

        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 14px center;
            padding-right: 36px;
        }

        /* ========== GRID DE 2 COLUNAS ========== */
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        @media (max-width: 600px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            .card {
                padding: 24px 20px;
            }
        }

        /* ========== BOTOES ========== */
        .btn-group {
            margin-top: 28px;
            display: flex;
            gap: 12px;
        }

        .btn {
            padding: 12px 28px;
            font-size: 0.925rem;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.2s ease, transform 0.1s ease, box-shadow 0.2s ease;
        }

        .btn-primary {
            background: var(--azul-primario);
            color: var(--branco);
            box-shadow: 0 2px 8px rgba(26, 86, 219, 0.3);
        }

        .btn-primary:hover {
            background: var(--azul-hover);
            box-shadow: 0 4px 12px rgba(26, 86, 219, 0.4);
            transform: translateY(-1px);
        }

        .btn-primary:active {
            transform: translateY(0);
        }

        .btn-secondary {
            background: #e5e7eb;
            color: #374151;
        }

        .btn-secondary:hover {
            background: #d1d5db;
        }

        /* ========== FOOTER ========== */
        .footer {
            text-align: center;
            padding: 24px;
            font-size: 0.8rem;
            color: var(--cinza-texto);
        }
    </style>
</head>
<body>

    <!-- NAVBAR -->
    <nav class="navbar" role="navigation" aria-label="Barra de navegacao principal">
        <div class="navbar-logo" aria-hidden="true">OS</div>
        <span class="navbar-title">Gerenciamento de Chamados</span>
        <span class="navbar-subtitle">Sistema de Ordens de Servico</span>
    </nav>

    <!-- CONTEUDO PRINCIPAL -->
    <main class="container">
        <div class="card">
            <div class="card-header">
                <h2><% If sChamadoID <> "" Then Response.Write "Editar Chamado #" & Server.HTMLEncode(sChamadoID) Else Response.Write "Novo Chamado" End If %></h2>
                <p>Preencha os campos abaixo para registrar ou atualizar um chamado tecnico.</p>
            </div>

            <% If sMensagem <> "" Then %>
            <div class="mensagem <%= sMsgTipo %>" role="alert">
                <%= Server.HTMLEncode(sMensagem) %>
            </div>
            <% End If %>

            <form method="POST" action="chamados.asp">
                <input type="hidden" name="ChamadoID" value="<%= Server.HTMLEncode(sChamadoID) %>">

                <!-- Titulo -->
                <div class="form-group">
                    <label for="txtTitulo">Titulo <span class="obrigatorio" aria-label="obrigatorio">*</span></label>
                    <input type="text" id="txtTitulo" name="Titulo" class="form-control"
                           placeholder="Ex: Falha no sistema de login"
                           value="<%= Server.HTMLEncode(sTitulo) %>" required>
                </div>

                <!-- Descricao -->
                <div class="form-group">
                    <label for="txtDescricao">Descricao <span class="obrigatorio" aria-label="obrigatorio">*</span></label>
                    <textarea id="txtDescricao" name="Descricao" class="form-control"
                              placeholder="Descreva o problema com detalhes..." required><%= Server.HTMLEncode(sDescricao) %></textarea>
                </div>

                <!-- Prioridade e Status (linha dupla) -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="selPrioridade">Prioridade</label>
                        <select id="selPrioridade" name="Prioridade" class="form-control">
                            <option value="Baixa" <% If sPrioridade = "Baixa" Then Response.Write "selected" %>>Baixa</option>
                            <option value="Media" <% If sPrioridade = "Media" Then Response.Write "selected" %>>Media</option>
                            <option value="Alta" <% If sPrioridade = "Alta" Then Response.Write "selected" %>>Alta</option>
                            <option value="Critica" <% If sPrioridade = "Critica" Then Response.Write "selected" %>>Critica</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="selStatus">Status</label>
                        <select id="selStatus" name="Status" class="form-control">
                            <option value="Aberto" <% If sStatus = "Aberto" Then Response.Write "selected" %>>Aberto</option>
                            <option value="Em Andamento" <% If sStatus = "Em Andamento" Then Response.Write "selected" %>>Em Andamento</option>
                            <option value="Aguardando" <% If sStatus = "Aguardando" Then Response.Write "selected" %>>Aguardando</option>
                            <option value="Resolvido" <% If sStatus = "Resolvido" Then Response.Write "selected" %>>Resolvido</option>
                            <option value="Fechado" <% If sStatus = "Fechado" Then Response.Write "selected" %>>Fechado</option>
                        </select>
                    </div>
                </div>

                <!-- Tecnico Responsavel -->
                <div class="form-group">
                    <label for="txtTecnico">Tecnico Responsavel</label>
                    <input type="text" id="txtTecnico" name="TecnicoResp" class="form-control"
                           placeholder="Nome do tecnico"
                           value="<%= Server.HTMLEncode(sTecnico) %>">
                </div>

                <!-- Solucao Tecnica -->
                <div class="form-group">
                    <label for="txtSolucao">Solucao Tecnica</label>
                    <textarea id="txtSolucao" name="SolucaoTecnica" class="form-control"
                              placeholder="Descreva a solucao aplicada (se houver)..."><%= Server.HTMLEncode(sSolucao) %></textarea>
                </div>

                <!-- Botoes -->
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary">
                        <% If sChamadoID <> "" Then Response.Write "Atualizar Chamado" Else Response.Write "Salvar Chamado" End If %>
                    </button>
                    <a href="chamados.asp" class="btn btn-secondary" style="text-decoration:none; text-align:center;">Limpar</a>
                </div>
            </form>
        </div>
    </main>

    <!-- FOOTER -->
    <footer class="footer">
        &copy; 2026 &mdash; Sistema de Chamados/OS &bull; Padrao Visual UPD8
    </footer>

</body>
</html>
