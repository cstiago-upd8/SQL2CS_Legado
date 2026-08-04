<%@ Language="VBScript" %>
<%
Option Explicit
Response.CharSet = "UTF-8"
%>
<!-- #include file="config.asp" -->
<%

' ============================================================
' Excluir Chamado - ASP Classico
' ============================================================

Dim conn, cmd
Dim sChamadoID

sChamadoID = Trim(Request.QueryString("id"))

If sChamadoID = "" Or Not IsNumeric(sChamadoID) Then
    Response.Redirect "pesquisa_chamados.asp"
End If

On Error Resume Next

Set conn = Server.CreateObject("ADODB.Connection")
conn.Open DB_CONNECTION_STRING

If Err.Number = 0 Then
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandType = 4 ' adCmdStoredProc
    cmd.CommandText = "sp_excluir_chamado"
    cmd.Parameters.Append cmd.CreateParameter("@ChamadoID", 3, 1, , CLng(sChamadoID))
    cmd.Execute

    If Err.Number <> 0 Then
        Set cmd = Nothing
        conn.Close
        Set conn = Nothing
        Response.Redirect "pesquisa_chamados.asp?msg=erro_excluir"
    Else
        Set cmd = Nothing
        conn.Close
        Set conn = Nothing
        Response.Redirect "pesquisa_chamados.asp?msg=excluido"
    End If
Else
    Response.Redirect "pesquisa_chamados.asp?msg=erro_excluir"
End If

On Error GoTo 0
%>
