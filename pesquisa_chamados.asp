<%@ Language="VBScript" %>
<%
Option Explicit
Response.CharSet = "UTF-8"
%>
<!-- #include file="config.asp" -->
<%

' ============================================================
' Pesquisa de Chamados/OS - ASP Classico
' Padrao Visual UPD8 (www.upd8.com.br)
' ============================================================

Dim conn, rs, sSQL
Dim sBusca, sStatusFiltro
Dim bTemResultado
Dim sMsgSucesso

' --- Capturar filtros ---
sBusca = Trim(Request.QueryString("busca"))
sStatusFiltro = Trim(Request.QueryString("status"))

' --- Mensagem de sucesso (redirect apos salvar) ---
If Request.QueryString("msg") = "salvo" Then
    sMsgSucesso = "Chamado salvo com sucesso!"
ElseIf Request.QueryString("msg") = "excluido" Then
    sMsgSucesso = "Chamado excluido com sucesso!"
ElseIf Request.QueryString("msg") = "erro_excluir" Then
    sMsgSucesso = ""
Else
    sMsgSucesso = ""
End If

' --- Montar consulta ---
sSQL = "SELECT chamadoid, titulo, prioridade, status, tecnicoresp, datacriacao FROM chamados WHERE 1=1"

If sBusca <> "" Then
    sSQL = sSQL & " AND (titulo ILIKE '%" & Replace(sBusca, "'", "''") & "%' OR tecnicoresp ILIKE '%" & Replace(sBusca, "'", "''") & "%')"
End If

If sStatusFiltro <> "" And sStatusFiltro <> "Todos" Then
    sSQL = sSQL & " AND status = '" & Replace(sStatusFiltro, "'", "''") & "'"
End If

sSQL = sSQL & " ORDER BY datacriacao DESC"

' --- Conectar e executar ---
On Error Resume Next

Set conn = Server.CreateObject("ADODB.Connection")
conn.Open DB_CONNECTION_STRING

If Err.Number = 0 Then
    Set rs = conn.Execute(sSQL)
End If

On Error GoTo 0
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pesquisa de Chamados/OS</title>
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
            --amarelo: #d97706;
            --amarelo-bg: #fffbeb;
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

        /* ========== CONTAINER ========== */
        .container {
            max-width: 1100px;
            margin: 30px auto;
            padding: 0 20px;
        }

        /* ========== CARD ========== */
        .card {
            background: var(--branco);
            border-radius: var(--radius);
            box-shadow: var(--sombra-card);
            padding: 28px 32px;
            margin-bottom: 24px;
        }

        .card-header {
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
        }

        .card-header h2 {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--azul-marinho);
        }

        /* ========== FILTROS ========== */
        .filtros-form {
            display: flex;
            align-items: flex-end;
            gap: 14px;
            flex-wrap: wrap;
        }

        .filtro-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .filtro-group label {
            font-size: 0.8rem;
            font-weight: 600;
            color: #374151;
        }

        .form-control {
            padding: 9px 14px;
            font-size: 0.9rem;
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

        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
            padding-right: 32px;
        }

        .input-busca {
            min-width: 260px;
        }

        /* ========== BOTOES ========== */
        .btn {
            padding: 9px 20px;
            font-size: 0.875rem;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
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

        .btn-secondary {
            background: #e5e7eb;
            color: #374151;
        }

        .btn-secondary:hover {
            background: #d1d5db;
        }

        .btn-success {
            background: var(--verde-sucesso);
            color: var(--branco);
            box-shadow: 0 2px 8px rgba(5, 150, 105, 0.3);
        }

        .btn-success:hover {
            background: #047857;
            transform: translateY(-1px);
        }

        .btn-sm {
            padding: 6px 14px;
            font-size: 0.8rem;
        }

        .btn-danger {
            background: var(--vermelho-erro);
            color: var(--branco);
            box-shadow: 0 2px 8px rgba(220, 38, 38, 0.3);
        }

        .btn-danger:hover {
            background: #b91c1c;
            transform: translateY(-1px);
        }

        /* ========== TABELA ========== */
        .tabela-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }

        thead {
            background: #f9fafb;
        }

        thead th {
            padding: 12px 14px;
            text-align: left;
            font-weight: 600;
            color: #374151;
            border-bottom: 2px solid #e5e7eb;
            white-space: nowrap;
        }

        tbody tr {
            border-bottom: 1px solid #f3f4f6;
            transition: background-color 0.15s ease;
        }

        tbody tr:hover {
            background-color: #f9fafb;
        }

        tbody td {
            padding: 12px 14px;
            color: #4b5563;
            vertical-align: middle;
        }

        /* ========== BADGES ========== */
        .badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            white-space: nowrap;
        }

        /* Status badges */
        .badge-aberto {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .badge-em-andamento {
            background: var(--amarelo-bg);
            color: var(--amarelo);
        }

        .badge-aguardando {
            background: #f3f4f6;
            color: #6b7280;
        }

        .badge-resolvido {
            background: var(--verde-bg);
            color: var(--verde-sucesso);
        }

        .badge-fechado {
            background: #f1f5f9;
            color: #475569;
        }

        /* Prioridade badges */
        .badge-baixa {
            background: #ecfdf5;
            color: #059669;
        }

        .badge-media {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .badge-alta {
            background: #fff7ed;
            color: #ea580c;
        }

        .badge-critica {
            background: var(--vermelho-bg);
            color: var(--vermelho-erro);
        }

        /* ========== MENSAGEM SUCESSO ========== */
        .mensagem {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .mensagem.sucesso {
            background: var(--verde-bg);
            color: var(--verde-sucesso);
            border: 1px solid #a7f3d0;
        }

        /* ========== MENSAGEM VAZIA ========== */
        .msg-vazia {
            text-align: center;
            padding: 48px 20px;
            color: var(--cinza-texto);
        }

        .msg-vazia .icone {
            font-size: 2.5rem;
            margin-bottom: 12px;
            opacity: 0.5;
        }

        .msg-vazia p {
            font-size: 1rem;
            font-weight: 500;
        }

        .msg-vazia .subtexto {
            font-size: 0.85rem;
            font-weight: 400;
            margin-top: 4px;
        }

        /* ========== TOOLBAR ========== */
        .toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .toolbar .total {
            font-size: 0.85rem;
            color: var(--cinza-texto);
        }

        /* ========== FOOTER ========== */
        .footer {
            text-align: center;
            padding: 24px;
            font-size: 0.8rem;
            color: var(--cinza-texto);
        }

        /* ========== RESPONSIVO ========== */
        @media (max-width: 768px) {
            .filtros-form {
                flex-direction: column;
                align-items: stretch;
            }
            .input-busca {
                min-width: 100%;
            }
            .card {
                padding: 20px 16px;
            }
            .toolbar {
                flex-direction: column;
                align-items: flex-start;
            }
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

        <% If sMsgSucesso <> "" Then %>
        <div class="mensagem sucesso" role="alert">
            <%= Server.HTMLEncode(sMsgSucesso) %>
        </div>
        <% End If %>

        <!-- CARD DE FILTROS -->
        <div class="card">
            <form method="GET" action="pesquisa_chamados.asp" class="filtros-form">
                <div class="filtro-group">
                    <label for="txtBusca">Buscar por Titulo ou Tecnico</label>
                    <input type="text" id="txtBusca" name="busca" class="form-control input-busca"
                           placeholder="Digite para buscar..."
                           value="<%= Server.HTMLEncode(sBusca) %>">
                </div>
                <div class="filtro-group">
                    <label for="selStatus">Status</label>
                    <select id="selStatus" name="status" class="form-control">
                        <option value="Todos" <% If sStatusFiltro = "" Or sStatusFiltro = "Todos" Then Response.Write "selected" %>>Todos</option>
                        <option value="Aberto" <% If sStatusFiltro = "Aberto" Then Response.Write "selected" %>>Aberto</option>
                        <option value="Em Andamento" <% If sStatusFiltro = "Em Andamento" Then Response.Write "selected" %>>Em Andamento</option>
                        <option value="Aguardando" <% If sStatusFiltro = "Aguardando" Then Response.Write "selected" %>>Aguardando</option>
                        <option value="Resolvido" <% If sStatusFiltro = "Resolvido" Then Response.Write "selected" %>>Resolvido</option>
                        <option value="Fechado" <% If sStatusFiltro = "Fechado" Then Response.Write "selected" %>>Fechado</option>
                    </select>
                </div>
                <div class="filtro-group" style="justify-content: flex-end;">
                    <label>&nbsp;</label>
                    <div style="display:flex; gap:8px;">
                        <button type="submit" class="btn btn-primary">Pesquisar</button>
                        <a href="pesquisa_chamados.asp" class="btn btn-secondary">Limpar Filtros</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- CARD DE RESULTADOS -->
        <div class="card">
            <div class="toolbar">
                <div class="total">
                    <%
                    Dim iCount
                    iCount = 0
                    If Not rs Is Nothing Then
                        If Not rs.EOF Then
                            ' Contar registros (moveFirst depois)
                            Do While Not rs.EOF
                                iCount = iCount + 1
                                rs.MoveNext
                            Loop
                            rs.MoveFirst
                        End If
                    End If
                    %>
                    <strong><%= iCount %></strong> chamado(s) encontrado(s)
                </div>
                <a href="chamados.asp" class="btn btn-success">+ Novo Chamado</a>
            </div>

            <% If iCount > 0 Then %>
            <div class="tabela-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Titulo</th>
                            <th>Prioridade</th>
                            <th>Status</th>
                            <th>Tecnico</th>
                            <th>Data Criacao</th>
                            <th>Acoes</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    Dim sPrioridadeClass, sStatusClass, sDataFormatada

                    Do While Not rs.EOF
                        ' Classe CSS para prioridade
                        Select Case LCase(rs("prioridade") & "")
                            Case "baixa"   : sPrioridadeClass = "badge-baixa"
                            Case "media"   : sPrioridadeClass = "badge-media"
                            Case "alta"    : sPrioridadeClass = "badge-alta"
                            Case "critica" : sPrioridadeClass = "badge-critica"
                            Case Else      : sPrioridadeClass = "badge-baixa"
                        End Select

                        ' Classe CSS para status
                        Select Case LCase(rs("status") & "")
                            Case "aberto"        : sStatusClass = "badge-aberto"
                            Case "em andamento"  : sStatusClass = "badge-em-andamento"
                            Case "aguardando"    : sStatusClass = "badge-aguardando"
                            Case "resolvido"     : sStatusClass = "badge-resolvido"
                            Case "fechado"       : sStatusClass = "badge-fechado"
                            Case Else            : sStatusClass = "badge-aberto"
                        End Select

                        ' Formatar data
                        If Not IsNull(rs("datacriacao")) Then
                            sDataFormatada = Day(rs("datacriacao")) & "/" & Right("0" & Month(rs("datacriacao")), 2) & "/" & Year(rs("datacriacao")) & " " & Right("0" & Hour(rs("datacriacao")), 2) & ":" & Right("0" & Minute(rs("datacriacao")), 2)
                        Else
                            sDataFormatada = "-"
                        End If
                    %>
                        <tr>
                            <td><strong>#<%= rs("chamadoid") %></strong></td>
                            <td><%= Server.HTMLEncode(rs("titulo") & "") %></td>
                            <td><span class="badge <%= sPrioridadeClass %>"><%= Server.HTMLEncode(rs("prioridade") & "") %></span></td>
                            <td><span class="badge <%= sStatusClass %>"><%= Server.HTMLEncode(rs("status") & "") %></span></td>
                            <td><%= Server.HTMLEncode(rs("tecnicoresp") & "") %></td>
                            <td><%= sDataFormatada %></td>
                            <td>
                                <a href="chamados.asp?id=<%= rs("chamadoid") %>" class="btn btn-primary btn-sm">Editar</a>
                                <a href="excluir_chamado.asp?id=<%= rs("chamadoid") %>" class="btn btn-danger btn-sm" onclick="return confirm('Deseja realmente excluir o chamado #<%= rs("chamadoid") %>?');">Excluir</a>
                            </td>
                        </tr>
                    <%
                        rs.MoveNext
                    Loop
                    %>
                    </tbody>
                </table>
            </div>
            <% Else %>
            <div class="msg-vazia">
                <div class="icone">&#128269;</div>
                <p>Nenhum chamado encontrado</p>
                <p class="subtexto">Tente ajustar os filtros ou cadastre um novo chamado.</p>
            </div>
            <% End If %>
        </div>

    </main>

    <!-- FOOTER -->
    <footer class="footer">
        &copy; 2026 &mdash; Sistema de Chamados/OS &bull; Padrao Visual UPD8
    </footer>

<%
' --- Limpar objetos ---
If Not rs Is Nothing Then
    If rs.State = 1 Then rs.Close
    Set rs = Nothing
End If
If Not conn Is Nothing Then
    If conn.State = 1 Then conn.Close
    Set conn = Nothing
End If
%>

</body>
</html>
