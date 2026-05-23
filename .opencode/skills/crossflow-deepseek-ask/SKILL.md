---
name: crossflow-deepseek-ask
description: Use CrossFlow sync to ask the DeepSeek V4 Flash model for priority assessment of system-model crossflow analogy and capture the response back to the user. The skill wraps an OMC ask invocation so that the communication flows through the CrossFlow topology.
level: 3
---
# CrossFlow DeepSeek Ask

**Purpose**
This skill routes a query to the DeepSeek V4 Flash model through the OMC `ask` wrapper, ensuring the request travels via the CrossFlow sync topology and the response is persisted as an ask artifact.

**Usage**
```bash
/crossflow-deepseek-ask <question>
```

**Implementation**
The skill executes the following command:

```bash
omc ask /ask opencode "<question>"
```

The request is dispatched through the CrossFlow sync topology; the response is stored under `.opencode/state/artifacts/ask/...` and will be returned to the caller automatically.

**Example**
```bash
/crossflow-deepseek-ask "Please assess the priority of using DeepSeek V4 Flash for cross‑flow communication and report the findings."
```
