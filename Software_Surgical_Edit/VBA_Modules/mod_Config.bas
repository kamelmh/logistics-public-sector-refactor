Attribute VB_Name = "mod_Config"
Option Explicit

Public Property Get SYS_TITLE() As String
    SYS_TITLE = "ERP Acad" & Chr(233) & "mie"
End Property

Public Const SHEET_MOUVEMENTS As String = "MOUVEMENTS"
Public Const SHEET_ARTICLES As String = "ARTICLES"
Public Const SHEET_SYS_STRINGS As String = "SYS_STRINGS"
Public Const SHEET_AUDIT_LOG As String = "AUDIT_LOG"
Public Const SHEET_STAGING As String = "STAGING_BUFFER"

Public Const DOC_TYPE_BS As String = "Bon de Sortie"

Public Property Get DOC_TYPE_BR() As String
    DOC_TYPE_BR = "Bon de R" & Chr(201) & "ception"
End Property

Public Const DOC_TYPE_DA As String = "Demande d'Achat"

Public Const MASTER_PWD As String = "erp_secure_pwd_2026"
Public Const WORKING_DAYS_PER_YEAR As Integer = 250
Public Const OBSERVATION_DAYS As Integer = 38
Public Const VERSION As String = "v13.2"