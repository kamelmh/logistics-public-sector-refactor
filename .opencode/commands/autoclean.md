# autoclean

Purge old logs, verify results, and temp files older than 30 days.

## Usage
```
OpenCode autoclean
```

## What it cleans
- `logs/` — OpenCode session logs older than 30 days
- `vbe-auto/results/` — verify result JSON files older than 30 days
- `vbe-auto/verify_results_*.json` — legacy root results older than 30 days
- `*.tmp`, `*.temp` — temp files older than 30 days
- Memory session files — keeps only the 5 most recent

## Implementation
`:autoclean` label in `OpenCode.bat`
