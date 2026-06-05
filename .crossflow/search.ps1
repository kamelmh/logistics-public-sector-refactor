<#
.SYNOPSIS
    CrossFlow FTS5 Search — full-text search across task results and knowledge base.

.DESCRIPTION
    SQLite FTS5 full-text search across opus-results.md, knowledge-base.json,
    and skills directory. Enables cross-session recall.

.EXAMPLE
    .\search.ps1 -Query "EOQ formula"                    # Search all
    .\search.ps1 -Query "security" -Source results       # Search results only
    .\search.ps1 -Query "CMUP" -Source knowledge         # Search knowledge base
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,
    [ValidateSet("all", "results", "knowledge", "skills")]
    [string]$Source = "all",
    [int]$Limit = 10
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$CrossflowDir = $PSScriptRoot
$DbPath = Join-Path $CrossflowDir "search.db"

# ─── Initialize FTS5 Database ───────────────────────────────────
function Initialize-SearchDb {
    $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$DbPath;Version=3;")
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = @"
CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
    source,
    task_id,
    title,
    content,
    metadata,
    tokenize='porter unicode61'
);
"@
    $cmd.ExecuteNonQuery()
    
    return $conn
}

# ─── Index Content ──────────────────────────────────────────────
function Index-Content {
    param([System.Data.SQLite.SQLiteConnection]$Conn)
    
    # Clear existing index
    $cmd = $Conn.CreateCommand()
    $cmd.CommandText = "DELETE FROM search_index;"
    $cmd.ExecuteNonQuery()
    
    # Index opus-results.md
    $resultsFile = Join-Path $CrossflowDir "opus-results.md"
    if (Test-Path $resultsFile) {
        $content = Get-Content $resultsFile -Raw
        $blocks = $content -split '(?=### \[TASK-)'
        
        foreach ($block in $blocks) {
            if ($block -match '### \[(TASK-\d+)\]\s+(.+)') {
                $taskId = $Matches[1]
                $title = $Matches[2]
                $output = ""
                if ($block -match '\*\*Output\*\*:\s*\n((?:.*\n)*?)(?=\n---|\z)') {
                    $output = $Matches[1].Trim()
                }
                
                $cmd = $Conn.CreateCommand()
                $cmd.CommandText = "INSERT INTO search_index (source, task_id, title, content, metadata) VALUES (@source, @taskId, @title, @content, @metadata)"
                $cmd.Parameters.AddWithValue("@source", "results")
                $cmd.Parameters.AddWithValue("@taskId", $taskId)
                $cmd.Parameters.AddWithValue("@title", $title)
                $cmd.Parameters.AddWithValue("@content", $output)
                $cmd.Parameters.AddWithValue("@metadata", "")
                $cmd.ExecuteNonQuery()
            }
        }
    }
    
    # Index knowledge-base.json
    $kbFile = Join-Path $CrossflowDir "knowledge-base.json"
    if (Test-Path $kbFile) {
        $kb = Get-Content $kbFile -Raw | ConvertFrom-Json
        foreach ($item in $kb) {
            $cmd = $Conn.CreateCommand()
            $cmd.CommandText = "INSERT INTO search_index (source, task_id, title, content, metadata) VALUES (@source, @taskId, @title, @content, @metadata)"
            $cmd.Parameters.AddWithValue("@source", "knowledge")
            $cmd.Parameters.AddWithValue("@taskId", $item.task_id)
            $cmd.Parameters.AddWithValue("@title", $item.type)
            $cmd.Parameters.AddWithValue("@content", $item.content)
            $cmd.Parameters.AddWithValue("@metadata", ($item.metadata | ConvertTo-Json -Compress))
            $cmd.ExecuteNonQuery()
        }
    }
    
    # Index skills
    $skillsDir = Join-Path $CrossflowDir "skills"
    if (Test-Path $skillsDir) {
        $skillFiles = Get-ChildItem "$skillsDir\*.md" -ErrorAction SilentlyContinue
        foreach ($file in $skillFiles) {
            $content = Get-Content $file.FullName -Raw
            $cmd = $Conn.CreateCommand()
            $cmd.CommandText = "INSERT INTO search_index (source, task_id, title, content, metadata) VALUES (@source, @taskId, @title, @content, @metadata)"
            $cmd.Parameters.AddWithValue("@source", "skills")
            $cmd.Parameters.AddWithValue("@taskId", $file.BaseName)
            $cmd.Parameters.AddWithValue("@title", $file.Name)
            $cmd.Parameters.AddWithValue("@content", $content)
            $cmd.Parameters.AddWithValue("@metadata", "")
            $cmd.ExecuteNonQuery()
        }
    }
    
    Write-Host "  Indexed content from opus-results.md, knowledge-base.json, skills/" -ForegroundColor Green
}

# ─── Search ─────────────────────────────────────────────────────
function Search-FTS5 {
    param(
        [System.Data.SQLite.SQLiteConnection]$Conn,
        [string]$Query,
        [string]$Source,
        [int]$Limit
    )
    
    $sql = "SELECT source, task_id, title, snippet(search_index, 3, '<b>', '</b>', '...', 32) as snippet, rank FROM search_index WHERE search_index MATCH @query"
    
    if ($Source -ne "all") {
        $sql += " AND source = @source"
    }
    
    $sql += " ORDER BY rank LIMIT @limit"
    
    $cmd = $Conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.Parameters.AddWithValue("@query", $Query)
    $cmd.Parameters.AddWithValue("@source", $Source)
    $cmd.Parameters.AddWithValue("@limit", $Limit)
    
    $results = @()
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        $results += [PSCustomObject]@{
            Source = $reader["source"]
            TaskId = $reader["task_id"]
            Title = $reader["title"]
            Snippet = $reader["snippet"]
            Rank = $reader["rank"]
        }
    }
    
    return $results
}

# ─── Main ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "  === CrossFlow FTS5 Search ===" -ForegroundColor Yellow
Write-Host ""

$conn = Initialize-SearchDb
Index-Content -Conn $conn

Write-Host "  Searching: '$Query' (source=$Source, limit=$Limit)" -ForegroundColor Cyan
Write-Host ""

$results = Search-FTS5 -Conn $conn -Query $Query -Source $Source -Limit $Limit

if ($results.Count -eq 0) {
    Write-Host "  No results found" -ForegroundColor Red
} else {
    Write-Host "  Found $($results.Count) results:" -ForegroundColor Green
    Write-Host ""
    
    foreach ($r in $results) {
        Write-Host "  [$($r.Source)] $($r.TaskId) - $($r.Title)" -ForegroundColor White
        Write-Host "    $($r.Snippet)" -ForegroundColor DarkGray
        Write-Host ""
    }
}

$conn.Close()
Write-Host ""
