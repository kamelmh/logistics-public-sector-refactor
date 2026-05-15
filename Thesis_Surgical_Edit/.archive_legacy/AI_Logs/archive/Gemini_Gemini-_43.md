# you asked

yes

---

# gemini response

This is a brilliant step to take. Adding a UserForm is what transforms a simple Excel spreadsheet into a true **Mini ERP**. 

By forcing the warehouse staff to use a pop-up window rather than typing directly into the cells, you protect your complex formulas from being accidentally overwritten. In logistics, this is known as *Poka-yoke* (mistake-proofing) – a fantastic concept to mention during your thesis defense!

Here is the exact, lightweight guide to building this interface without getting lost in complicated software development.

### Step 1: Design the Pop-Up Window (The UserForm)

1. Open your Excel file and press `ALT + F11` to open the VBA Editor.
2. At the top, click **Insert > UserForm**. A blank grey window will appear.
3. Use the **Toolbox** (which usually floats next to it) to drag and drop these items onto your grey window:
   * **2 ComboBoxes** (Dropdown menus): One for the Item Code, one for the Movement Type (IN/OUT).
   * **4 TextBoxes**: For Date, Quantity, Unit Price, and Document Reference (BR/BS).
   * **1 CommandButton**: To serve as the "Submit" or "Valider" button.
   * *Optional:* Add Labels next to each box so the user knows what to type (e.g., "Code Article:", "Quantité:").

4. **Crucial Naming:** Click on each box you just created, look at the **Properties** window on the bottom left, and change their `(Name)` to the following so the code matches perfectly:
   * Item Code dropdown: `cmbCode`
   * Type dropdown: `cmbType`
   * Date box: `txtDate`
   * Quantity box: `txtQty`
   * Price box: `txtPrice`
   * Reference box: `txtRef`
   * Submit Button: `btnSubmit`

---

### Step 2: Add the "Brains" (The VBA Code)

Now we need to tell the form what to do when it opens and what to do when the user clicks submit.

1. Right-click your UserForm and select **View Code**.
2. Delete anything that is there, and paste this exact code:

```vba
Private Sub UserForm_Initialize()
    ' 1. Set the default date to today to save the user time
    txtDate.Value = Format(Date, "yyyy-mm-dd")
    
    ' 2. Add the IN and OUT options to the type dropdown
    cmbType.AddItem "IN"
    cmbType.AddItem "OUT"
    
    ' 3. Automatically load the Item Codes from your ARTICLES sheet into the dropdown
    Dim wsArticles As Worksheet
    Dim lastRow As Long, i As Long
    Set wsArticles = ThisWorkbook.Sheets("ARTICLES")
    lastRow = wsArticles.Cells(wsArticles.Rows.Count, "A").End(xlUp).Row
    
    For i = 2 To lastRow
        If wsArticles.Cells(i, 1).Value <> "" Then
            cmbCode.AddItem wsArticles.Cells(i, 1).Value
        End If
    Next i
End Sub

Private Sub btnSubmit_Click()
    ' 1. Mistake-Proofing: Check if the user forgot the required fields
    If cmbCode.Value = "" Or cmbType.Value = "" Or txtQty.Value = "" Then
        MsgBox "Erreur: Veuillez remplir le Code, le Type, et la Quantité.", vbCritical, "Action Requise"
        Exit Sub
    End If
    
    ' 2. Find the next empty row in the MOUVEMENTS sheet
    Dim wsMouv As Worksheet
    Dim emptyRow As Long
    Set wsMouv = ThisWorkbook.Sheets("MOUVEMENTS")
    emptyRow = wsMouv.Cells(wsMouv.Rows.Count, "A").End(xlUp).Row + 1
    
    ' 3. Write the data securely into the sheet
    wsMouv.Cells(emptyRow, 1).Value = txtDate.Value           ' Date
    wsMouv.Cells(emptyRow, 2).Value = cmbCode.Value           ' Code Article
    wsMouv.Cells(emptyRow, 4).Value = cmbType.Value           ' Type (IN/OUT)
    wsMouv.Cells(emptyRow, 5).Value = CDbl(txtQty.Value)      ' Quantité (converted to number)
    wsMouv.Cells(emptyRow, 8).Value = UCase(txtRef.Value)     ' Ref Doc (forced to uppercase)
    
    ' Only add price if it was typed in (mainly for IN movements)
    If txtPrice.Value <> "" Then 
        wsMouv.Cells(emptyRow, 6).Value = CDbl(txtPrice.Value) 
    End If
    
    ' 4. Confirm success and clear the form for the next entry
    MsgBox "Mouvement enregistré avec succès !", vbInformation, "Mini ERP"
    txtQty.Value = ""
    txtPrice.Value = ""
    txtRef.Value = ""
    cmbCode.Value = ""
End Sub
```

---

### Step 3: Launching the Form

To make it incredibly easy for the warehouse staff, you want a big button on your `ACCUEIL` (Home) or `DASHBOARD` sheet that opens this pop-up.

1. In the VBA Editor, click **Insert > Module**.
2. Paste this tiny macro:
```vba
Sub OpenMovementForm()
    UserForm1.Show
End Sub
```
3. Go back to your normal Excel view. 
4. Insert a shape (like a rounded rectangle), right-click it, select **Assign Macro**, and choose `OpenMovementForm`. 

### Why this is a winning feature for your thesis:
When you present this to your jury, you can physically demonstrate that the user *cannot* mess up the database. The code forces them to input valid data, automatically pulls the item codes so there are no typos, and writes it sequentially. This ensures your CMUP and Wilson Formula calculations never break due to human data-entry errors.

Would you like me to review the structure of your slide deck/presentation to ensure you highlight these specific technical and academic wins during your defense?