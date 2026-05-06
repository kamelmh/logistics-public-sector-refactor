VERSION 5.00
Begin VB.Form frmStockEntry 
   BackColor       =   &H8000000F&
   BorderColor     =   &H80000012&
   Caption         =   "نموذج إدخال بيانات المخزون - Directorate of Education El Bayadh"
   ClientHeight    =   6540
   ClientLeft      =   120
   ClientTop       =   456
   ClientWidth     =   9420
   LinkTopic       =   "forms.001"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6540
   ScaleWidth      =   9420
   StartUpPosition =   1  'CenterOwner

   Begin VB.ComboBox cboArticle 
      Height          =   315
      Left            =   240
      TabIndex        =   1
      Top             =   840
      Width           =   5055
      BackColor       =   &H80000005&
      Style           =   2  'Dropdown List
      Caption         =   "اختر الصنف (Article)"
   End

   Begin VB.TextBox txtQuantity 
      Height          =   315
      Left            =   240
      TabIndex        =   2
      Top             =   1560
      Width           =   5055
      BackColor       =   &H80000005&
      Text            =   ""
   End

   Begin VB.TextBox txtSupplier 
      Height          =   315
      Left            =   240
      TabIndex        =   3
      Top             =   2280
      Width           =   5055
      BackColor       =   &H80000005&
      Text            =   ""
   End

   Begin VB.ComboBox cboTransactionType 
      Height          =   315
      Left            =   240
      TabIndex        =   4
      Top             =   3000
      Width           =   5055
      BackColor       =   &H80000005&
      Style           =   2  'Dropdown List
      List            =   "Bon de Réception (استلام)", "Bon de Sortie (إخراج)", "Bon de Retour (مرتجع)"
   End

   Begin VB.TextBox txtDate 
      Height          =   315
      Left            =   240
      TabIndex        =   5
      Top             =   3720
      Width           =   5055
      BackColor       =   &H80000005&
      Text            =   ""
   End

   Begin VB.CommandButton cmdSubmit 
      Height          =   855
      Left            =   240
      TabIndex        =   6
      Top             =   4440
      Width           =   2415
      BackColor       =   &H8000000F&
      Caption         =   "تأكيد الإدخال (Submit)"
      Default         =   -1  'True
   End

   Begin VB.CommandButton cmdCancel 
      Height          =   855
      Left            =   2880
      TabIndex        =   7
      Top             =   4440
      Width           =   2415
      BackColor       =   &H8000000F&
      Caption         =   "إلغاء (Cancel)"
   End

   Begin VB.Label lblTitle 
      Caption         =   "نموذج إدخال بيانات المخزون - مديرية التربية لولاية البيض"
      Height          =   495
      Left            =   240
      TabIndex        =   8
      Top             =   240
      Width           =   5055
      FontBold        =   -1  'True
      FontSize        =   12
   End

   Begin VB.Label lblArticle 
      Caption         =   "الصنف (Article):"
      Height          =   255
      Left            =   240
      TabIndex        =   9
      Top             =   600
      Width           =   5055
   End

   Begin VB.Label lblQuantity 
      Caption         =   "الكمية (Quantity):"
      Height          =   255
      Left            =   240
      TabIndex        =   10
      Top             =   1320
      Width           =   5055
   End

   Begin VB.Label lblSupplier 
      Caption         =   "المورد (Supplier):"
      Height          =   255
      Left            =   240
      TabIndex        =   11
      Top             =   2040
      Width           =   5055
   End

   Begin VB.Label lblTransactionType 
      Caption         =   "نوع الحركة (Transaction Type):"
      Height          =   255
      Left            =   240
      TabIndex        =   12
      Top             =   2760
      Width           =   5055
   End

   Begin VB.Label lblDate 
      Caption         =   "التاريخ (Date):"
      Height          =   255
      Left            =   240
      TabIndex        =   13
      Top             =   3480
      Width           =   5055
   End
End
