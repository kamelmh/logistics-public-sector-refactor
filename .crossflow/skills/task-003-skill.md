---
name: refactoring-plan-modstockentrylogicbas-
description: "Auto-generated from TASK-003: Refactoring Plan — mod_StockEntry_Logic.bas"
version: 1.0.0
author: CrossFlow-Opus
license: MIT
platforms: [windows, linux, macos]
metadata:
  crossflow:
    tags: [ERP, VBA, CrossFlow, Security, Architecture]
    related_skills: [refactoring]
    source_task: TASK-003
    generated: 2026-06-05 02:23:38
---

# Refactoring Plan — mod_StockEntry_Logic.bas

Auto-generated skill from CrossFlow-Opus task execution.

## Source

- **Task**: TASK-003
- **Title**: Refactoring Plan — mod_StockEntry_Logic.bas
- **Generated**: 2026-06-05 02:23:38

## Output

We are given a VBA module (mod_StockEntry_Logic.bas) that is monolithic and handles multiple responsibilities.
 The task is to refactor it into 4-6 focused modules.

 Steps:
 1. Analyze the current module to identify logical sub-components.
 2. Propose new modules with clear responsibilities.
 3. Define the public API (functions and subs) for each new module.
 4. List dependencies between the new modules.
 5. Estimate effort (in hours) for each module.
 6. Identify risks (like breaking changes, p-code cache issues).

 Current module sections (as seen in the code):
   SECTION 0 - MODULE-LEVEL CONSTANTS & STATE
   SECTION 0A - FORM STATE STRUCT
   SECTION 1 - FORM INITIALIZE
   SECTION 2 - DOCUMENT TYPE BANNER
   SECTION 3 - ARTICLE SELECTION & STOCK INTELLIGENCE
   SECTION 4 - QUANTITY FIELD (Live validation + Wilson nudge)
   SECTION 5 - AUTO REFERENCE GENERATOR
   SECTION 6 - GRID OPERATIONS
   SECTION 7 - ENREGISTRER (Transaction commit)
   SECTION 8 - CANCEL
   SECTION 9 - UTILITY: Form Reference Helper

 We can group these into:

  1. Form State Management: Handling the FormState struct and initializing/resetting state.
  2. UI Appearance and Setup: Setting up the form's appearance, dropdowns, grid, etc.
  3. Document Type Handling: Changing banners, enabling/disabling fields based on doc type.
  4. Article and Stock Logic: Article selection, stock evaluation, Wilson alerts, etc.
  5. Input Validation and Guard Clauses: Validating inputs (date, ref, article, qty, PU) and stock sufficiency.
  6. Grid Operations: Adding/removing lines, updating total.
  7. Transaction Processing: Commit transaction (with safety, sync, audit, etc.)
  8. Utility Functions: Helper functions (HasControl, etc.)

 However, note that the current module also has:
   - Auto reference generation
   - Cancel transaction

 We aim for 4-6 modules. Let's try to combine related functions.

 Proposed modules:

  Module 1: mod_FormStateManager
      Responsibilities: 
        - Define and manage the FormState struct (if we keep it as a public type, we might put it in a common module, but note: the task says to break the current module)
        - Initialize form state, reset to default, update state from form controls (if we decide to do that in the state manager) 
        - However, note: the current module uses the FormState to decouple from UI. We might keep the FormState in a common module? 
        But the task says: Pure VBA only, and we are breaking one module into several.

      Alternatively, we can put the FormState in a separate module (mod_FormState) and then have a state manager that works with it.

      However, to minimize the number of modules, we can consider:

      Option: Keep the FormState in the module that uses it most? But we are breaking the module.

      Let's think: The FormState is used throughout. We can put it in a common module (mod_CommonTypes) and then have:

        mod_FormStateManager: 
          - InitializeForm(state As FormState)
          - ResetToDefaultState(state As FormState)
          - UpdateTotalDisplay(state As FormState)   [but note: this also updates the form?]

      However, the UpdateTotalDisplay in the current module updates the form label. We want to avoid direct UI in state manager? 
      The current design is: the logic module returns state updates and the form renders them.

      So we should not have the form update in the state manager. Instead, the state manager only updates the state, and the form (or a UI module) updates the controls.

      Therefore, we might split:

        mod_FormState: 
          Public Type FormState ... End Type

        mod_FormStateManager:
          Public Sub InitializeForm(ByRef state As FormState)
          Public Sub ResetToDefaultState(ByRef state As FormState)
          Public Sub UpdateTotalDisplay(ByRef state As FormState)   ' but note: this only updates state.TotalGeneral and state.TotalGeneralText, not the form

      Then, the form (or a UI module) would be responsible for setting the label from state.TotalGeneralText.

      However, the current module also has:
        SetupFormAppearance, PopulateDropdowns, ConfigureGrid -> these are UI setup.

      We can create:

        mod_UIInitializer: 
          Public Sub SetupFormAppearance(ByRef state As FormState)
          Public Sub PopulateDropdowns(ByRef state As FormState)
          Public Sub ConfigureGrid(ByRef state As FormState)

      But note: these subs use the formRef from the state to set properties.

      Alternatively, we can have a UI module that takes the form and the state and updates the UI.

      Given the constraints, let's propose:

        Module 1: mod_FormState (only the Type definition) -> but note: we cannot have a module with only a Type? Actually we can.

        However, to avoid too many modules, we can put the FormState in a module that also has state management functions? 

      Considering the goal of 4-6 modules, I propose:

        mod_FormStateHandler: 
          - Contains the FormState Type (public)
          - Functions to initialize, reset, and update state (without touching UI controls)

        mod_UIHandler:
          - All UI setup and updates (appearance, dropdowns, grid, setting labels, colors, etc.)
          - This module will take the form and the state and update the UI accordingly.

        mod_DocTypeLogic:
          - Handling document type changes (banner, enabling/disabling fields, etc.)

        mod_ArticleStockLogic:
          - Article selection, stock evaluation, Wilson alerts, etc.

        mod_InputValidation:
          - All guard validations (date, ref, article, qty, PU, stock sufficiency, etc.)

        mod_GridOperations:
          - Adding/removing lines, updating total (but note: updating total might be shared with state handler? We can have the grid operations update the state and then the UI handler updates the display)

        mod_TransactionProcessor:
          - Commit transaction, cancel, auto-ref generation, etc.

      That's 7 modules. We can try to combine:

        Option: Combine mod_FormStateHandler and mod_UIHandler? But they have different concerns.

        Alternatively, note that the current module already uses the FormState to decouple. We can keep the FormState in the same module as the state handler and then have:

          mod_StateAndUI: 
            - FormState Type
            - InitializeForm, ResetToDefaultState, UpdateTotalDisplay (state only)
            - SetupFormAppearance, PopulateDropdowns, ConfigureGrid, UpdateTotalDisplayUI (which sets the label) -> but wait, we don't want to mix state and UI too much.

      Given the complexity, and to stick to 4-6, let's try:

        Module 1: mod_FormState (only the Type) -> 1
        Module 2: mod_StateManager (handles state initialization, reset, and updating state variables) -> 2
        Module 3: mod_UIManager (handles all UI updates based on state) -> 3
        Module 4: mod_DocTypeAndArticleLogic (handles doc type changes and article/stock logic) -> 4
        Module 5: mod_ValidationAndGrid (handles input validation and grid operations) -> 5
        Module 6: mod_TransactionHandler (handles commit, cancel, auto-ref) -> 6

      But note: the current module has a lot of interdependencies.

      Alternatively, we can look for natural groupings:

        Group 1: State and Form Setup (InitializeForm, ResetToDefaultState, SetupFormAppearance, PopulateDropdowns, ConfigureGrid)
        Group 2: Document Type Handling (OnDocTypeChanged, GetDocPrefixFromType)
        Group 3: Article and Stock (OnArticleChanged, EvaluateStockStatus, OnCategoryChanged)
        Group 4: Quantity Field and Validation (OnQuantityChanged, and the guard validations in AddLineToGrid)
        Group 5: Grid Operations (AddLineToGrid, RemoveLineFromGrid, UpdateTotalDisplay, GetQtyInGridForSKU)
        Group 6: Transaction (CommitTransaction, GenerateAutoRef, GetNextSequence, SyncTransactionInternal, CancelTransaction)
        Group 7: Utility (HasControl)

      We have 7 groups. We can combine Group 1 and Group 2? Or Group 6 and Group 7?

      Let's try to combine:

        Module 1: mod_FormInitialization (Group 1: State and Form Setup)
        Module 2: mod_DocTypeHandler (Group 2)
        Module 3: mod_ArticleStockHandler (Group 3)
        Module 4: mod_InputValidation (Group 4)   [but note: Group 4 also has quantity field live validation and the guards in AddLineToGrid]
        Module 5: mod_GridOperations (Group 5)
        Module 6: mod_TransactionProcessor (Group 6 and Group 7: Utility)

      Now, note that the guard validations in AddLineToGrid are currently in the same function as the grid add. We might want to split the guards into a validation module.

      We can break AddLineToGrid into:
        - ValidateInputs (returns boolean, and highlights errors)
        - Then if valid, add the line.

      So:

        Module 4: mod_Validation (handles all validations: date, ref, article, qty, PU, stock sufficiency, ROP alert, etc.)
        Module 5: mod_GridManager (handles adding/removing lines, updating total, and getting qty in grid for SKU)

      Then, the AddLineToGrid function would become:
        If mod_Validation.ValidateLineAdd(state) Then
          mod_GridManager.AddLine(state)
        End If

      Similarly, the RemoveLineFromGrid is already simple.

      Now, let's list the modules:

        mod_FormInitialization:
          - InitializeForm
          - ResetToDefaultState
          - SetupFormAppearance
          - PopulateDropdowns
          - ConfigureGrid

        mod_DocTypeHandler:
          - OnDocTypeChanged
          - GetDocPrefixFromType

        mod_ArticleStockHandler:
          - OnArticleChanged
          - EvaluateStockStatus
          - OnCategoryChanged

        mod_Validation:
          - ValidateDate (or we can have a function that validates all for a line add? But note: we also have live validation for quantity)
          - ValidateQuantityLive (for the OnQuantityChanged event) -> but note: this sets the backcolor, which is UI. So we might need to return the color? Or we can have the validation module return a validation result and then the UI module sets the color? 
          - However, to keep the validation module pure (no UI), we can have it return a validation status and an error message, and then the UI module handles the highlighting.

          But note: the current OnQuantityChanged sets the backcolor directly. We want to avoid that in the validation module? 

          Alternatively, we can have:

            mod_Validation:
              Public Function ValidateQuantity(ByVal qtyText As String, ByVal currentStock As Long, ByVal isBRMode As Boolean, ByVal ss As Long, ByVal rop As Double) As ValidationResult
                ' ValidationResult could be a UDT: {IsValid As Boolean, BackColor As Long, Message As String}
              End Function

          Then the UI module (or the form) would call this and set the backcolor.

          However, to minimize changes, we might let the validation module return the color? But that breaks the pure validation.

          Given the constraints, and since we are allowed to break the module, we can design the validation module to return a validation object that includes the UI state (like backcolor) for the specific control? 

          But note: the validation for quantity is specific to the quantity textbox.

          We can have:

            mod_Validation:
              Public Function ValidateQuantityInput(ByVal qtyText As String, ByVal currentStock As Long, ByVal isBRMode As Boolean, ByVal ss As Long, ByVal rop As Double) As Long
                ' Returns the backcolor RGB for the quantity textbox
              End Function

          Similarly, for other validations that affect UI (like highlighting errors), we can have the validation module return whether to highlight and which control? 

          However, that couples the validation to the UI control.

          Another approach: the validation module returns a list of validation errors (with control name and message) and then the UI module highlights the controls. 

          But note: we are in VBA and we want to avoid too much overhead.

          Considering the effort and the fact that we are only refactoring, we can keep the live validation for quantity in the UI module? 

          Actually, the live validation for quantity is very specific: it changes the backcolor of the quantity textbox based on projected stock.

          We can move that to the ArticleStockHandler? Because it uses current stock and the mode.

          But note: the quantity live validation is triggered by the quantity textbox change.

          Let's reassign:

            mod_ArticleStockHandler: 
              - OnArticleChanged
              - EvaluateStockStatus
              - OnCategoryChanged
              - ValidateQuantityLive (which returns the backcolor for the quantity textbox)   [but note: this function would be called from the quantity change event]

          Then, the form would do:
            state.QtyBackColor = mod_ArticleStockHandler.ValidateQuantityLive(Me.txtQuantite.Value, m_StockActuel, m_IsBRMode, CANON_SS, CANON_ROP)
            Me.txtQuantite.BackColor = state.QtyBackColor

          And then the state would hold the backcolor? Or we can set it directly? 

          But note: the current design uses the state to hold the backcolor and then the UI module sets it? 

          We are trying to avoid direct UI in the logic modules.

          So we can have:

            mod_ArticleStockHandler:
              Public Function GetQuantityBackColor(ByVal qtyText As String, ByVal currentStock As Long, ByVal isBRMode As Boolean, ByVal ss As Long, ByVal rop As Double) As Long
                ' returns the RGB color for the quantity textbox backcolor
              End Function

          Then, in the form's OnQuantityChanged event:
            state.QtyBackColor = mod_ArticleStockHandler.GetQuantityBackColor(Me.txtQuantite.Value, m_StockActuel, m_IsBRMode, CANON_SS, CANON_ROP)
            ' and then the UI module (or the form) sets the textbox backcolor to state.QtyBackColor? 
            ' But note: we have a UI module that updates the form from state? 

          Alternatively, we can have the form call the UI module to set the quantity backcolor? 

          To keep the form thin, we can have:

            In the form's OnQuantityChanged:
              Call mod_UIManager.SetQuantityBackColor(Me, mod_ArticleStockHandler.GetQuantityBackColor(Me.txtQuantite.Value, m_StockActuel, m_IsBRMode, CANON_SS, CANON_ROP))

          But then we are passing the form to the UI manager.

          Given the time, let's stick to the original plan of 6 modules and assign the live quantity validation to the ArticleStockHandler as a function that returns the color, and then the form (or a UI module) sets it. 

          However, note: we are creating a UI manager module. So we can have:

            mod_UIManager:
              Public Sub SetQuantityBackColor(ByVal frm As Object, ByVal backColor As Long)
                frm.txtQuantite.BackColor = backColor
              End Sub

          And then in the form:
            state.QtyBackColor = mod_ArticleStockHandler.GetQuantityBackColor(Me.txtQuantite.Value, m_StockActuel, m_IsBRMode, CANON_SS, CANON_ROP)
            mod_UIManager.SetQuantityBackColor Me, state.QtyBackColor

          But note: the state is holding the backcolor? We don't really need to if we set it immediately. 

          We can avoid storing it in state if we set it right away. However, the current module stores it in state and then uses it in ResetToDefaultState? 

          In ResetToDefaultState, we set:
            state.QtyBackColor = RGB(255, 255, 255)
            state.formRef.txtQuantite.BackColor = state.QtyBackColor

          So we do need to store it in state for reset.

          Therefore, we can have:

            mod_ArticleStockHandler:
              Public Function GetQuantityBackColor(ByVal qtyText As String, ByVal currentStock As Long, ByVal isBRMode As Boolean, ByVal ss As Long, ByVal rop As Double) As Long
                ' ... same logic as in OnQuantityChanged
              End Function

          Then, in the form's OnQuantityChanged:
            state.QtyBackColor = mod_ArticleStockHandler.GetQuantityBackColor(Me.txtQuantite.Value, m_StockActuel, m_IsBRMode, CANON_SS, CANON_ROP)
            Me.txtQuantite.BackColor = state.QtyBackColor

          And in ResetToDefaultState (in mod_StateManager or mod_FormInitialization?):
            state.QtyBackColor = RGB(255, 255, 255)
            ' and then we would set the form control? But note: ResetToDefaultState is called from the logic module, and we don't want to touch the form from there.

          So we must have the UI manager set it. Therefore, we change ResetToDefaultState to only update the state, and then the form (or a UI module) is responsible for updating the UI from state.

          How about: after ResetToDefaultState, the form calls a UI update function that sets all controls from state?

          We can have:

            mod_UIManager:
              Public Sub UpdateUIFromState(ByVal frm As Object, ByVal state As FormState)
                ' set all labels, textboxes, etc. from state
              End Sub

          Then, the form would call mod_UIManager.UpdateUIFromState Me, state after any state change.

          This is a significant change, but it decouples completely.

          Given the scope of refactoring, we might not want to change the form code too much? 

          The task says: refactor the VBA module. We are allowed to change the form? The form is in a different file (frmStockEntry). 

          But note: the task only gives us the logic module. We are not to change the form? 

          However, the current logic module directly sets form controls (e.g., state.formRef.lblStockInfo.Caption = ...). 

          We are trying to remove that direct coupling.

          Since we are only given the logic module to refactor, we must assume that we can change the form as well? But the task does not provide the form code.

          Given the ambiguity, and to stick to the task (which is to refactor the given module), we will design the new modules to be used by the form without changing the form's event code too much? 

          Alternatively, we can keep the form setting the controls from the state in the logic module, but we move the logic to the new modules.

          We decide: the new modules will not touch the form controls directly. They will only update the state. The form (which we are not refactoring in this task) will be responsible for updating the controls from the state.

          But note: we are not given the form code, so we cannot change it. 

          Therefore, we must maintain the current contract: the logic module updates the form controls via state.formRef.

          However, the task says: "Form owns all UI operations; logic module returns state updates". 

          So we are allowed to change the form? But we are not given the form.

          Since the task is only about the given module, we will refactor the logic module to not touch the form controls, and instead update the state. Then, we assume that the form will be updated separately (by whoever calls the logic module) to reflect the state.

          But note: the current module is called from the form's events. 

          We can change the form to update the controls from the state after calling the logic module? 

          However, without the form code, we cannot do that.

          Given the constraints of the task, we will refactor the logic module to be pure logic (only updating state) and then note that the form must be changed to update the UI from state. 

          But the task does not require us to change the form. 

          Alternatively, we can keep the current pattern of the logic module updating the form via state.formRef, but we move the code that updates the form to the new modules? 

          That would not reduce coupling.

      After reconsideration, and to stay within the scope of the given module, we will design the new modules to update the state and also to update the form controls if necessary, but we will pass the formRef as a parameter to the modules that need to update the form.

      However, note: the current module already has formRef in the state. 

      We can keep the state.formRef and then have the new modules update the form controls via state.formRef? 

      But that is what we are trying to avoid because it couples the logic to the form.

      The state.formRef is passed in, so if we change the form, we break. 

      The goal is to have the logic module not know about the form controls. 

      Therefore, we must remove all direct form control updates from the logic modules and only update the state. 

      Then, we change the form to update the controls from the state after calling the logic module. 

      Since we are not given the form, we will note this as a required change in the form (outside the scope of this module refactoring) but necessary for the refactoring to work.

      Given the above, we proceed.

      Proposed modules (6):

        mod_StateManager:
          - Public Type FormState (if we want to keep it here, or we can put it in a common module? Let's put it here for simplicity, but note: other modules will need to use it)
          - Public Sub InitializeForm(ByRef state As FormState)
          - Public Sub ResetToDefaultState(ByRef state As FormState)
          - Public Sub UpdateTotalDisplay(ByRef state As FormState)   ' updates state.TotalGeneral and state.TotalGeneralText

        mod_UIUpdater:   ' This module updates the form controls from state. We pass the formRef and state.
          - Public Sub UpdateFormAppearance(ByVal frm As Object, ByVal state As FormState)
          - Public Sub PopulateDropdowns(ByVal frm As Object, ByVal state As FormState)
          - Public Sub ConfigureGrid(ByVal frm As Object, ByVal state As FormState)
          - Public Sub UpdateStockInfo(ByVal frm As Object, ByVal state As FormState)
          - Public Sub UpdateWilsonAlert(ByVal frm As Object, ByVal state As FormState)
          - Public Sub UpdateBanner(ByVal frm As Object, ByVal state As FormState)
          - Public Sub UpdatePUEnabled(ByVal frm As Object, ByVal state As FormState)
          - Public Sub UpdatePULabel(ByVal frm As Object, ByVal state As FormState)
          - Public Sub UpdateQuantityBackColor(ByVal frm As Object, ByVal state As FormState)
          - Public Sub UpdateTotalGeneralDisplay(ByVal frm As Object, ByVal state As FormState)
          - Public Sub ClearGrid(ByVal frm As Object)
          - Public Sub AddLineToGrid(ByVal frm As Object, ByVal lineData As Variant)   ' but note: we might not want to pass lineData? 
          - ... etc.

        However, note: this UIUpdater module would be very form-specific. 

        Alternatively, we can have the state manager not update the form, and then the form (which we are not changing in this task) would continue to update the controls as it does now? 

        But then we haven't reduced coupling.

      Given the time, and since the task is to refactor the logic module, we will assume that we are allowed to change the form to use a state-driven update. 

      We will create:

        mod_StateManager: handles the state (FormState) and provides functions to initialize, reset, and update state variables.

        mod_BusinessLogic: contains the core logic that updates the state based on events (doc type change, article change, quantity change, etc.) and does not touch the form.

        mod_Validation: contains validation functions that return validation results (without touching the form).

        mod_GridManager: handles grid operations (adding lines, removing lines) and updates the state (like total general) but does not touch the form.

        mod_TransactionHandler: handles committing transactions, generating auto-ref, etc., and updates the state (but note: committing a transaction might reset the state, so it would call mod_StateManager.ResetToDefaultState).

        mod_Utility: contains helper functions like HasControl.

      Then, the form would be responsible for:
        - Calling mod_StateManager.InitializeForm at startup.
        - After any event that calls mod_BusinessLogic, the form would update the UI from state by calling a series of functions in a new mod_UIUpdater (or we can put the UI update in the form itself?).

      But note: we are not given the form, so we cannot change it. 

      Therefore, we must not break the existing form. 

      This leads us to a different approach: we refactor the logic module into smaller modules but keep the same interface (i.e., the form still calls the same public subs and functions in the logic module, but now the logic module delegates to the new modules).

      We can keep the public API of mod_StockEntry_Logic.bas the same, and then break the implementation into the new modules.

      This way, the form does not need to change.

      Steps:

        1. Keep mod_StockEntry_Logic.bas as the main module that the form uses.
        2. Break its implementation into several helper modules.
        3. mod_StockEntry_Logic.bas will delegate to the helper modules.

      This is the safest because it doesn't change the form.

      We will have:

        mod_StockEntry_Logic.bas (now thinner) that contains:
          - The public subs and functions that the form calls (InitializeForm, OnDocTypeChanged, OnArticleChanged, OnQuantityChanged, AddLineToGrid, RemoveLineFromGrid, CommitTransaction, CancelTransaction, HasControl)
          - And it will delegate the work to the new modules.

      Then, we create:

        mod_StateManager: as described.
        mod_UILogic: handles the UI-related logic that updates the form controls (but note: we are keeping the form calls in mod_StockEntry_Logic, so this module will update the form controls via the formRef that is passed in? But we don't want to pass formRef around? 

      Alternatively, we can have the new modules take the formRef and state as parameters.

      Given that we are delegating from mod_StockEntry_Logic, which already has the formRef and state (or access to state via module-level variables?), we can do:

        In mod_StockEntry_Logic.bas, we keep the module-level state variables (m_TotalGeneral, m_CurrentArticle, m_StockActuel, m_IsBRMode) and the FormState is not used? 

      Wait, the current module uses a FormState struct that is passed around? 

      Actually, looking at the code, the current module does not use the FormState struct in the way we thought. 

      It has:
        Private m_TotalGeneral   As Double
        Private m_CurrentArticle As String
        Private m_StockActuel    As Long
        Private m_IsBRMode       As Boolean

      And then it has a FormState type defined, but it is not used as a variable? 

      Let me check: 

        Public Sub InitializeForm(ByRef state As FormState)

      So the form passes a FormState variable to the logic module.

      And then the logic module updates that state.

      And the form is expected to use that state to update the UI? 

      But in the code, we see:

        state.formRef.lblStockInfo.Caption = state.StockInfoText

      So the logic module is updating the form controls via state.formRef.

      This is the tight coupling we want to break.

      Given the above, and to minimize changes to the form, we will keep the FormState approach but move the logic out.

      We will create new modules that take a FormState and update it, and also update the form controls if necessary? 

      But note: we want to break the tight coupling, so we will not update the form controls in the new modules. 

      Instead, the new modules will only update the FormState. 

      Then, mod_StockEntry_Logic.bas will be responsible for updating the form controls from the FormState after calling the new modules.

      However, that would move the form control update code to mod_StockEntry_Logic.bas, which is what we are trying to refactor out.

      Alternatively, we can have the new modules return the updates that need to be made to the form, and then mod_StockEntry_Logic.bas applies them.

      Given the complexity, and to meet the requirement of 4-6 modules, we propose:

        We will keep mod_StockEntry_Logic.bas as the main module, but we will break its internal procedures into the new modules.

        The new modules will be:

          mod_FormStateHandler: 
            - Contains the FormState Type (if we want to keep it separate, but we can leave it in mod_StockEntry_Logic.bas? Or put it in a common module)
            - We'll put it in a common module mod_CommonTypes.bas to avoid duplication.

          mod_FormInitializer: 
            - InitializeForm, ResetToDefaultState, SetupFormAppearance, PopulateDropdowns, ConfigureGrid

          mod_DocTypeLogic: 
            - OnDocTypeChanged, GetDocPrefixFromType

          mod_ArticleStockLogic: 
            - OnArticleChanged, EvaluateStockStatus, OnCategoryChanged, GetQuantityBackColor (for live validation)

          mod_ValidationLogic: 
            - All the guard validations in AddLineToGrid (date, ref, article, qty, PU, stock sufficiency, ROP alert) 
            - Note: the live quantity validation is in mod_ArticleStockLogic.GetQuantityBackColor

          mod_GridAndTotalLogic: 
            - AddLineToGrid (without the guards, which are called from mod_ValidationLogic), RemoveLineFromGrid, UpdateTotalDisplay, GetQtyInGridForSKU

          mod_TransactionLogic: 
            - CommitTransaction, GenerateAutoRef, GetNextSequence, SyncTransactionInternal, CancelTransaction

          mod_UtilityLogic: 
            - HasControl

        Then, mod_StockEntry_Logic.bas will have:

          Public Sub InitializeForm(ByRef state As FormState)
            Call mod_FormInitializer.InitializeForm(state)
            Call mod_FormInitializer.SetupFormAppearance(state)
            Call mod_FormInitializer.PopulateDropdowns(state)
            Call mod_FormInitializer.ConfigureGrid(state)
            Call mod_FormInitializer.ResetToDefaultState(state)
          End Sub

          Public Sub OnDocTypeChanged(ByRef state As FormState)
            Call mod_DocTypeLogic.OnDocTypeChanged(state)
            ' After updating state, we need to update the form? 
            ' But note: mod_DocTypeLogic.OnDocTypeChanged updates the state and also the form controls via state.formRef? 
            ' We are trying to avoid that.
          End Sub

        This approach does not reduce the coupling because the new modules still update the form controls via state.formRef.

      Given the time, and since the task is to refactor the logic module (not the form), and the form is not provided, we will assume that we are allowed to change the form to be state-driven. 

      We will therefore create the modules as follows, and note that the form must be updated to use the state to set the controls.

      We will have 6 modules:

        1. mod_CommonTypes: 
            Public Type FormState
              ... (all the fields as in the original)
            End Type

        2. mod_StateManager:
            Public Sub InitializeForm(ByRef state As FormState)
            Public Sub ResetToDefaultState(ByRef state As FormState)
            Public Sub UpdateTotalDisplay(ByRef state As FormState)   ' updates state.TotalGeneral and state.TotalGeneralText

        3. mod_BusinessLogic: 
            Public Sub OnDocTypeChanged(ByRef state As FormState)
            Public Sub OnArticleChanged(ByRef state As FormState)
            Public Sub OnCategoryChanged(ByRef state As FormState)
            Public Sub GetQuantityBackColor(ByVal qtyText As String, ByVal currentStock As Long, ByVal isBRMode As Boolean, ByVal ss As Long, ByVal rop As Double) As Long
            ' Note: EvaluateStockStatus is called from OnArticleChanged, so we can make it private or put it here.

        4. mod_Validation:
            Public Function ValidateLineAdd(ByRef state As FormState) As Boolean
              ' This function does all the guards and returns True if valid, and also highlights errors in the form via state.formRef? 
              ' But we want to avoid that.
            End Function

        5. mod_GridManager:
            Public Sub AddLineToGrid(ByRef state As FormState)   ' assumes validation has passed
            Public Sub RemoveLineFromGrid(ByRef state As FormState)
            Public Function GetQtyInGridForSKU(ByVal sku As String, ByRef state As FormState) As Long

        6. mod_TransactionManager:
            Public Function CommitTransaction(ByRef state As FormState) As Boolean
            Public Sub GenerateAutoRef(ByRef state As FormState)
            Private Function GetNextSequence(ByVal prefix As String) As Long
            Private Function SyncTransactionInternal(ByVal artCode As String, ByVal mvtType As String, ByVal qty As Long, ByVal unitPrice As Double, ByVal refDoc As String) As Integer
            Public Sub CancelTransaction(ByRef state As FormState)

        7. mod_Utility:
            Public Function HasControl(ByVal formRef As Object, ByVal ctrlName As String) As Boolean

      That's 7 modules. We can combine mod_Utility into one of the others, or note that HasControl is only used in a few places and we can inline it? 
      But the task says 4-6, so we try to combine.

      Let's combine mod_Utility into mod_StateManager? Or make it a separate module but count it as one of the 6.

      We have 7, so we need to combine two.

      Idea: combine mod_StateManager and mod_BusinessLogic? 
        - mod_StateManager has state initialization and reset.
        - mod_BusinessLogic has the event handlers.

      They are different concerns.

      Combine mod_Validation and mod_GridManager? 
        - mod_Validation has ValidateLineAdd
        - mod_GridManager has AddLineToGrid (which calls ValidateLineAdd internally? or not)

      We can have mod_GridManager.AddLineToGrid call mod_Validation.ValidateLineAdd.

      Then, we can keep them separate.

      Given the effort, we will deliver 6 modules by making mod_Utility a part of mod_StateManager (since it's a utility and might be used there) or leave it as the 6th.

      We'll do:

        Module 1: mod_CommonTypes
        Module 2: mod_StateManager (includes HasControl? or not) -> we'll put HasControl in mod_StateManager for now.
        Module 3: mod_BusinessLogic
        Module 4: mod_Validation
        Module 5: mod_GridManager
        Module 6: mod_TransactionManager

      Now, let's define the public API for each:

        mod_CommonTypes:
          Public Type FormState
            ... (all fields)
          End Type

        mod_StateManager:
          Public Sub InitializeForm(ByRef state As FormState)
          Public Sub ResetToDefaultState(ByRef state As FormState)
          Public Sub UpdateTotalDisplay(ByRef state As FormState)
          Public Function HasControl(ByVal formRef As Object, ByVal ctrlName As String) As Boolean   ' moved here

        mod_BusinessLogic:
          Public Sub OnDocTypeChanged(ByRef state As FormState)
          Public Sub OnArticleChanged(ByRef state As FormState)
          Public Sub OnCategoryChanged(ByRef state As FormState)
          Public Function GetQuantityBackColor(ByVal qtyText As String, ByVal currentStock As Long, ByVal isBRMode As Boolean, ByVal ss As Long, ByVal rop As Double) As Long

        mod_Validation:
          Public Function ValidateLineAdd(ByRef state As FormState) As Boolean
            ' This function will:
            '   - Validate date
            '   - Validate doc ref
            '   - Validate article selection

## Usage

This skill was auto-generated from a successful task execution.
Use the knowledge above to guide similar tasks in the future.

## Ground Truth

| Param | Value |
|-------|-------|
| D | 789 |
| Q* | 37 |
| ROP | 206 |
| SS | 200 |
| LT | 2 days |
| S | 801.45 DZD |
| PU | 4,500 DZD |
| I | 20% |

## Changelog

- v1.0.0: Auto-generated from TASK-003
