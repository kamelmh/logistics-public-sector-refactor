
VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmSystemLog 
   Caption         =   "Console Log - ERP Academie v13.2"
   ClientHeight    =   6000
   ClientLeft      =   100
   ClientTop       =   100
   ClientWidth     =   9000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmSystemLog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private Sub UserForm_Initialize()
    ' Load the last 50 lines of the log
    Me.txtLog.Text = mod_LogViewer.GetLastLogEntries(50)
    
    ' Styling the text box
    Me.txtLog.Font.Name = "Courier New"
    Me.txtLog.Font.Size = 9
    Me.txtLog.BackColor = RGB(30, 30, 30)
    Me.txtLog.ForeColor = RGB(0, 255, 0) ' Matrix Green
End Sub

Private Sub btnRefresh_Click()
    Me.txtLog.Text = mod_LogViewer.GetLastLogEntries(50)
End Sub
