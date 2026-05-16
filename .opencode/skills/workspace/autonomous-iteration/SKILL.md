# Autonomous Iteration Skill

Based on the `autoresearch` pattern by Andrej Karpathy. This skill enables the agent to enter a high-frequency "Hypothesize $\rightarrow$ Implement $\rightarrow$ Measure $\rightarrow$ Learn" loop to optimize a specific target in the Academix v13.2 project.

## Core Philosophy
Stop manually reviewing every single change. Instead, define a clear success metric and let the agent iterate autonomously until that metric is improved.

## Applicable Targets
1. **VBA Logic**: Optimizing a specific `.bas` file.
   - **Metric**: `verify.ps1` (Pass/Fail count or specific test cases).
2. **Thesis Quality**: Refining a specific section.
   - **Metric**: Alignment with the "Surgical Edit" guidelines or critic agent score.
3. **Build Speed**: Optimizing `build.ps1` or `verify.ps1`.
   - **Metric**: Execution time (wall clock).

## The Autonomous Loop Workflow

### Step 1: Setup (The "Research Org")
- **Define Target**: Identify the exact file or section to modify.
- **Define Metric**: Establish the baseline measurement (e.g., "Current verify.ps1 fails on 5 tests in mod_Stock").
- **Set Budget**: Determine the maximum number of iterations or time limit.

### Step 2: The Loop (Sandboxed)
Repeat the following until the budget is exhausted or the target metric is reached:

1. **Hypothesize**: Analyze the current failure/bottleneck and propose a specific, atomic change.
2. **Isolate**: Initialize a sandbox for the iteration.
   - Command: `powershell -File scripts\sandbox-iterate.ps1 -Action Init -IterationId "iter-X"`
3. **Implement**: Apply the change directly to the sandbox path (found in `.opencode\sandboxes\iter-X`).
4. **Measure**: Run the metric in the sandbox.
   - Command: `powershell -File scripts\sandbox-iterate.ps1 -Action Test -IterationId "iter-X"`
5. **Evaluate**: 
   - **Improved**: Promote the changes to main.
     - Command: `powershell -File scripts\sandbox-iterate.ps1 -Action Promote -IterationId "iter-X"`
   - **Regressed/No Change**: Abort and clean up.
     - Command: `powershell -File scripts\sandbox-iterate.ps1 -Action Abort -IterationId "iter-X"`
6. **Learn**: Update the internal "research log" in `notepad.md` with what worked and what didn't.

## Constraints & Safety
- **Atomic Changes**: Only one hypothesis per iteration to ensure causality between the change and the metric.
- **Zero-Regression**: Any change that breaks existing "Golden" tests is automatically discarded.
- **Logging**: Every iteration must be logged in `notepad.md` as:
  `Iter X: [Hypothesis] -> [Result: Improved/Failed] -> [Metric: X -> Y]`

## Trigger Commands
- `/auto-iterate <target> <metric>`
