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

Dim conn
Dim sChamadoID

sChamadoID = Trim(Request.QueryString("id"))

If sChamadoID = "" Or Not IsNumeric(sChamadoID) Then
    Response.Redirect "pesquisa_chamados.asp"
End If

On Error Resume Next

Set conn = Server.CreateObject("ADODB.Connection")
conn.Open DB_CONNECTION_STRING

If Err.Number = 0 Then
    conn.Execute "SELECT sp_excluir_chamado(" & CLng(sChamadoID) & ")"

    If Err.Number <> 0 Then
        conn.Close
        Set conn = Nothing
        Response.Redirect "pesquisa_chamados.asp?msg=erro_excluir"
    Else
        conn.Close
        Set conn = Nothing
        Response.Redirect "pesquisa_chamados.asp?msg=excluido"
    End If
Else
    Response.Redirect "pesquisa_chamados.asp?msg=erro_excluir"
End If

On Error GoTo 0
%>
