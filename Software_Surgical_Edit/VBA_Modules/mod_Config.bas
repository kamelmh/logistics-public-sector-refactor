Option Explicit

' =======================================================================================
' MODULE: mod_Config.bas
' DESCRIPTION: Centralized constants for the entire ERP system.
' =======================================================================================

' --- System Titles ---
Public Const SYS_TITLE As String = "ERP Académie"

' --- Sheet Names ---
Public Const SHEET_MOUVEMENTS As String = "MOUVEMENTS"
Public Const SHEET_ARTICLES As String = "ARTICLES"
Public Const SHEET_SYS_STRINGS As String = "SYS_STRINGS"
Public Const SHEET_AUDIT_LOG As String = "AUDIT_LOG"
Public Const SHEET_STAGING As String = "STAGING" ' For VBA-based staging if needed

' --- Security ---
Public Const MASTER_PWD As String = "erp_secure_pwd_2026"

' --- Logistics & Calculations ---
Public Const WORKING_DAYS_PER_YEAR As Integer = 250
Public Const OBSERVATION_DAYS As Integer = 38

' --- Other Constants ---
Public Const VERSION As String = "v13.2"
