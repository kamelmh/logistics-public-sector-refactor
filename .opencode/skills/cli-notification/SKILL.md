# CLI Notification Skill

This skill provides guidelines and a standardized framework for sending notifications to the user within the Command Line Interface (CLI).

## Purpose
Ensure consistent, clear, and actionable communication between the agent and the user, reducing noise while highlighting critical information.

## Notification Levels

| Level | Prefix | Use Case | Example |
| :--- | :--- | :--- | :--- |
| **Success** | `[SUCCESS]` | Confirming a completed task or a successful fix. | `[SUCCESS] Tests passed: 12/12` |
| **Info** | `[INFO]` | General updates, progress reports, or neutral information. | `[INFO] Analyzing codebase for potential bottlenecks...` |
| **Warning** | `[WARN]` | Potential issues, non-critical errors, or deprecated patterns. | `[WARN] Found 3 unused imports in src/main.ts` |
| **Error** | `[ERROR]` | Critical failures, syntax errors, or blocked progress. | `[ERROR] Build failed: Missing dependency 'zod'` |

## Guidelines

1. **Be Concise**: Keep notifications to 1-2 lines. Avoid fluff.
2. **Be Actionable**: Errors should ideally suggest a fix or a next step.
3. **Avoid Noise**: Do not send notifications for trivial intermediate steps unless the task is long-running.
4. **Visual Hierarchy**: Use the prefixes to allow users to scan logs quickly.

## Suggested Configuration (YAML)

To avoid "YAML errors" during configuration, ensure the following schema is followed if implementing a settings file (e.g., `notifications.yaml`):

```yaml
notifications:
  enabled: true
  theme: "standard"
  levels:
    success:
      prefix: "[SUCCESS]"
      color: "green"
    info:
      prefix: "[INFO]"
      color: "blue"
    warning:
      prefix: "[WARN]"
      color: "yellow"
    error:
      prefix: "[ERROR]"
      color: "red"
  defaults:
    show_timestamp: false
    verbosity: "medium"
```

## Implementation Pattern

When notifying the user, use the following pattern:
`[LEVEL] <Message> (<Optional Action/Context>)`

Example:
`[ERROR] YAML syntax error in config.yaml: Line 12. (Suggested fix: Remove trailing colon)`
