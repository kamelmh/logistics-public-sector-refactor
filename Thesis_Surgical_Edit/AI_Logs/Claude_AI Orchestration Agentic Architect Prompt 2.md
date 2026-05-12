Option 3: The "Meta-Prompt" (The Orchestrator of AI)
Use this if: You want Claude to help you manage the relationship between Gemini and Claude to ensure no data is lost and the quality remains "Premium."
Persona: Act as a Meta-Prompt Engineer and AI Workflow Orchestrator.
Context: I am using a multi-model pipeline (Gemini for heavy drafting/ideation 
→
→
 Claude for auditing/coding/formatting). I am building a high-stakes Logistics ERP.
Objective: Optimize the "Context Handover" between these two models to prevent "Model Drift" (where the AI forgets constraints or introduces bugs during the transfer).
Task:
Protocol Design: Create a "Context Bridge" template I can use when moving a task from Gemini to Claude. What specific metadata (System State, Constraint List, Version History) must be included to ensure 100% alignment?
Audit Framework: Design a "Cross-Check" prompt that I can use to ask Claude to audit Gemini's logic, and vice-versa, to find edge-case bugs in my ERP's VBA/JS logic.
Memory Optimization: Suggest a method for maintaining a "Project Truth File" (like a .json or .md memory state) that I can feed into any AI model to instantly bring it up to speed on the current state of v12.