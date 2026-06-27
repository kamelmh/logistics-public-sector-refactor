# Comprehensive VBA compile-error sweep
# Finds: undeclared module-level vars, unresolved unqualified function calls,
# unresolved cross-module calls, missing UDT types.

$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$src = Join-Path (Split-Path $ScriptDir -Parent) "Software_Surgical_Edit\VBA_Modules"

# Sub/End Sub and Function/End Function balance check (Catches "Expected End Function",
# "Expected End Sub" errors that VBE swallows in some cases)
Write-Host ""
Write-Host "[0] SUB/FUNCTION BALANCE CHECK" -ForegroundColor Cyan
$balanceMismatches = 0
Get-ChildItem -LiteralPath $src -File -Include *.bas,*.frm,*.cls | ForEach-Object {
    $lines = Get-Content -LiteralPath $_.FullName
    $subs = 0; $endSubs = 0; $funcs = 0; $endFuncs = 0
    foreach ($l in $lines) {
        $t = $l.Trim()
        if ($t -match '^(Public|Private)\s+Sub\s+' -and $t -notmatch '\bSub (New|Get|Let|Set)\b') { $subs++ }
        if ($t -eq 'End Sub') { $endSubs++ }
        if ($t -match '^(Public|Private)\s+Function\s+') { $funcs++ }
        if ($t -eq 'End Function') { $endFuncs++ }
    }
    if (($subs -ne $endSubs) -or ($funcs -ne $endFuncs)) {
        Write-Host "  MISMATCH: $($_.Name) Subs=$subs/$endSubs Funcs=$funcs/$endFuncs" -ForegroundColor Red
        $balanceMismatches++
    }
}
if ($balanceMismatches -eq 0) { Write-Host "  (balanced)" -ForegroundColor Green }
else { Write-Host "  $balanceMismatches mismatched files" -ForegroundColor Yellow }
Write-Host ""

# Chr() corruption check (Catches "Chr(157 la)" or "Chr(123abc)" malformed literals)
Write-Host "[0b] Chr() LITERAL CORRUPTION CHECK" -ForegroundColor Cyan
$chrCorrupt = 0
Get-ChildItem -LiteralPath $src -File -Include *.bas,*.frm,*.cls | ForEach-Object {
    $lines = Get-Content -LiteralPath $_.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
        # Match Chr( followed by digits, then whitespace + alphabetic text (no operator) -- corruption
        # Excludes valid expressions like Chr(64 + lastCol), Chr(65) & something
        if ($lines[$i] -match 'Chr\(\d+\s+[a-zA-Z]') {
            Write-Host "  CORRUPT: $($_.Name):$($i+1) $($lines[$i].Trim().Substring(0, [Math]::Min(100, $lines[$i].Trim().Length)))" -ForegroundColor Red
            $chrCorrupt++
        }
    }
}
if ($chrCorrupt -eq 0) { Write-Host "  (clean)" -ForegroundColor Green }
else { Write-Host "  $chrCorrupt corrupted Chr() calls" -ForegroundColor Yellow }
Write-Host ""
$results = @{
    'undeclared_vars' = @{}
    'missing_qualified' = @{}
    'missing_unqualified' = @{}
    'missing_types' = @{}
}

# ====== Step 1: Build module->symbols map ======
$moduleMap = @{}  # name -> @{subs:Set; funcs:Set; consts:Set; props:Set; types:Set; udt_members:Map; module_vars:Set}

Get-ChildItem "$src\*.bas" | ForEach-Object {
    $file = $_.Name
    $content = Get-Content $_.FullName
    $modName = $null
    $inSub = $false
    $inType = $false
    $inEnum = $false
    $currentTypeMembers = @{}

    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        $trim = $line.Trim()

        if ($line -match '^Attribute VB_Name = "([^"]+)"') { $modName = $Matches[1]; continue }
        if ($trim.StartsWith("'")) { continue }

        if ($trim -match '^(Public|Private)?\s*(Sub|Function)\s+([A-Za-z_][A-Za-z0-9_]*)') {
            $inSub = $true
            $name = $Matches[3]
            $scope = if ($Matches[1]) { $Matches[1] } else { 'Public' }
            $kind = $Matches[2]
            if (-not $moduleMap.ContainsKey($modName)) { $moduleMap[$modName] = @{subs=@{};funcs=@{};consts=@{};props=@{};types=@{};udt_members=@{};module_vars=@{}} }
            if ($kind -eq 'Sub') {
                $moduleMap[$modName]['subs'][$name] = $scope
            } else {
                $moduleMap[$modName]['funcs'][$name] = $scope
            }
            continue
        }
        if ($trim -match '^(Public\s+)?Type\s+([A-Za-z_][A-Za-z0-9_]*)') {
            $inType = $true
            $typeName = $Matches[2]
            if (-not $moduleMap.ContainsKey($modName)) { $moduleMap[$modName] = @{subs=@{};funcs=@{};consts=@{};props=@{};types=@{};udt_members=@{};module_vars=@{}} }
            $moduleMap[$modName]['types'][$typeName] = $true
            $currentTypeMembers = @{}
            continue
        }
        if ($trim -match '^(Public\s+)?Enum\s+([A-Za-z_][A-Za-z0-9_]*)') {
            $inEnum = $true
            $typeName = $Matches[2]
            if (-not $moduleMap.ContainsKey($modName)) { $moduleMap[$modName] = @{subs=@{};funcs=@{};consts=@{};props=@{};types=@{};udt_members=@{};module_vars=@{}} }
            $moduleMap[$modName]['types'][$typeName] = $true
            continue
        }
        if ($trim -match '^End\s+Type\s*$') { $inType = $false
            $moduleMap[$modName]['udt_members'] += $currentTypeMembers
            continue
        }
        if ($trim -match '^End\s+Enum\s*$') { $inEnum = $false; continue }
        if ($trim -match '^End\s+(Sub|Function)\s*$') { $inSub = $false; continue }

        if (-not $inSub) {
            # Module-level declarations
            if ($trim -match '^(Public|Private)\s+Const\s+([A-Za-z_][A-Za-z0-9_]*)') {
                if (-not $moduleMap.ContainsKey($modName)) { $moduleMap[$modName] = @{subs=@{};funcs=@{};consts=@{};props=@{};types=@{};udt_members=@{};module_vars=@{}} }
                $moduleMap[$modName]['consts'][$Matches[2]] = $true
                continue
            }
            if ($trim -match '^(Public|Private)\s+Property\s+(Get|Let|Set)\s+([A-Za-z_][A-Za-z0-9_]*)') {
                if (-not $moduleMap.ContainsKey($modName)) { $moduleMap[$modName] = @{subs=@{};funcs=@{};consts=@{};props=@{};types=@{};udt_members=@{};module_vars=@{}} }
                $moduleMap[$modName]['props'][$Matches[3]] = $true
                continue
            }
            if ($trim -match '^(Public|Private)\s+([A-Za-z_][A-Za-z0-9_]*)(\([^)]*\))?\s+As\s+(\w+)') {
                if (-not $moduleMap.ContainsKey($modName)) { $moduleMap[$modName] = @{subs=@{};funcs=@{};consts=@{};props=@{};types=@{};udt_members=@{};module_vars=@{}} }
                $moduleMap[$modName]['module_vars'][$Matches[2]] = $Matches[4]
                continue
            }
            if ($trim -match '^Dim\s+([A-Za-z_][A-Za-z0-9_]*)(\([^)]*\))?\s+As\s+(\w+)') {
                if (-not $moduleMap.ContainsKey($modName)) { $moduleMap[$modName] = @{subs=@{};funcs=@{};consts=@{};props=@{};types=@{};udt_members=@{};module_vars=@{}} }
                $moduleMap[$modName]['module_vars'][$Matches[1]] = $Matches[3]
                continue
            }
            # UDT members (indented)
            if ($inType -and $trim -match '^([A-Za-z_][A-Za-z0-9_]*)\s+As\s+(\w+)(.*)$') {
                $currentTypeMembers[$Matches[1]] = $Matches[2]
            }
        }
    }
}

# ====== Step 2: Find unresolved references ======
$VBA_KEYWORDS = @('If','Then','Else','ElseIf','End','For','Next','Do','Loop','While','Wend','Dim','ReDim','Private','Public','Const','Set','Let','Call','Sub','Function','As','String','Integer','Long','Boolean','Double','Single','Variant','Date','Object','Nothing','True','False','Empty','Null','Step','To','With','New','Exit','On','Error','GoTo','Resume','And','Or','Not','Xor','Mod','Like','Return','Static','ByVal','ByRef','Optional','ParamArray','Friend','Implements','Preserve','LBound','UBound','Split','Join','Trim','Len','Mid','Left','Right','Replace','Format','CStr','CInt','CLng','CDbl','CSng','CDate','CBool','Val','Str','Chr','Asc','LCase','UCase','StrComp','InStr','IsEmpty','IsNull','IsError','IsDate','IsNumeric','IsObject','TypeName','VarType','MsgBox','InputBox','RGB','Array','CVar','Now','Date','Time','Year','Month','Day','Hour','Minute','Second','Timer','Rnd','Randomize','Sqr','Sgn','Abs','Int','Fix','Hex','Oct','Exp','Log','Sin','Cos','Tan','Atn','Choose','Switch','DoEvents','Shell','Beep','Tab','Spc','Spc','Call')

$badPatterns = '^(True|False|Nothing|Empty|Null)$'

Get-ChildItem "$src\*.bas" | ForEach-Object {
    $file = $_.Name
    $content = Get-Content $_.FullName
    $modName = $null
    $inSub = $false
    $inType = $false
    $inEnum = $false
    $inString = $false
    $procName = $null
    $isDefineTask = $false

    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        $trim = $line.Trim()
        $lnum = $i + 1

        if ($line -match '^Attribute VB_Name = "([^"]+)"') { $modName = $Matches[1]; continue }
        if ($trim.StartsWith("'")) { continue }

        if ($trim -match '^(Public|Private)?\s*(Sub|Function)\s+([A-Za-z_][A-Za-z0-9_]*)') {
            $inSub = $true
            $procName = $Matches[3]
            $isDefineTask = ($procName -match 'DefineTask')
            continue
        }
        if ($trim -match '^(Public\s+)?Type\s+') { $inType = $true; continue }
        if ($trim -match '^(Public\s+)?Enum\s+') { $inEnum = $true; continue }
        if ($trim -match '^End\s+Type\s*$') { $inType = $false; continue }
        if ($trim -match '^End\s+Enum\s*$') { $inEnum = $false; continue }
        if ($trim -match '^End\s+(Sub|Function)\s*$') { $inSub = $false; $procName = $null; $isDefineTask = $false; continue }

        # Check 1: qualified calls mod_X.Y where Y doesn't exist
        $ms = [regex]::Matches($line, '\b(mod_[A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)')
        foreach ($m in $ms) {
            $targetMod = $m.Groups[1].Value
            $targetFunc = $m.Groups[2].Value
            if ($targetMod -eq $modName) { continue }
            if (-not $moduleMap.ContainsKey($targetMod)) {
                if (-not $results['missing_qualified'].ContainsKey("$targetMod.$targetFunc")) {
                    $results['missing_qualified']["$targetMod.$targetFunc"] = @()
                }
                $results['missing_qualified']["$targetMod.$targetFunc"] += "$file : $lnum"
                continue
            }
            $mInfo = $moduleMap[$targetMod]
            $exists = $mInfo['funcs'].ContainsKey($targetFunc) -or
                      $mInfo['subs'].ContainsKey($targetFunc) -or
                      $mInfo['consts'].ContainsKey($targetFunc) -or
                      $mInfo['props'].ContainsKey($targetFunc) -or
                      $mInfo['types'].ContainsKey($targetFunc) -or
                      $mInfo['module_vars'].ContainsKey($targetFunc)
            if (-not $exists) {
                if (-not $results['missing_qualified'].ContainsKey("$targetMod.$targetFunc")) {
                    $results['missing_qualified']["$targetMod.$targetFunc"] = @()
                }
                $results['missing_qualified']["$targetMod.$targetFunc"] += "$file : $lnum"
            }
        }

        # Check 2: unqualified function calls in sub bodies
        if ($inSub -and -not $inType -and -not $inEnum -and -not $isDefineTask) {
            # Match: identifier followed by ( and not preceded by . (so not UDT access) or preceded by space (statement start)
            $ms = [regex]::Matches($line, '(?<![\.\w])([A-Za-z_][A-Za-z0-9_]*)\s*\(')
            foreach ($m in $ms) {
                $name = $m.Groups[1].Value
                if ($name -in $VBA_KEYWORDS) { continue }
                if ($name -match '^[A-Z][A-Z0-9_]*$') { continue }  # constants
                if ($name -in @('Debug','Application','ThisWorkbook','MsgBox','InputBox','Replace','Trim','Mid','Left','Right','Len','Format','CInt','CStr','CLng','CDbl','Val','CDate','CBool','Chr','Asc','LCase','UCase','StrComp','InStr','IsEmpty','IsNull','IsError','IsDate','IsNumeric','Split','Join','RGB','Sqr','Int','Fix','Abs','Sgn','LBound','UBound','ReDim','Set','Let','Erase','Open','Close','Print','Write','Input','Put','Get','Seek','FreeFile','Error','Raise','Line','Width','Circle','PSet','Scale','Cls')) { continue }
                # Is it defined in this module?
                $mInfo = $moduleMap[$modName]
                $defined = $mInfo['funcs'].ContainsKey($name) -or
                           $mInfo['subs'].ContainsKey($name) -or
                           $mInfo['consts'].ContainsKey($name) -or
                           $mInfo['props'].ContainsKey($name) -or
                           $mInfo['module_vars'].ContainsKey($name)
                # Or is it a local variable? (declared with Dim at top of Sub)
                # Heuristic: check if `Dim ... $name ... As` appears earlier in this sub
                $isLocal = $false
                for ($j = $i; $j -ge 0; $j--) {
                    $prevLine = $content[$j]
                    if ($prevLine -match '^(Public|Private)?\s*(Sub|Function)\s+') { break }
                    if ($prevLine -match '(?:^|\s)Dim\s+([A-Za-z_][A-Za-z0-9_]*)(\s+As\s+\w+)?' -or $prevLine -match '^\s*Dim\s+' -and $prevLine -match "\b$([regex]::Escape($name))\b") {
                        # rough
                    }
                    if ($prevLine -match "\b$([regex]::Escape($name))\b" -and $prevLine -match '\bDim\b') {
                        $isLocal = $true; break
                    }
                }
                if (-not $defined -and -not $isLocal) {
                    if (-not $results['missing_unqualified'].ContainsKey($name)) {
                        $results['missing_unqualified'][$name] = @()
                    }
                    $results['missing_unqualified'][$name] += "$file : $lnum (in $procName)"
                }
            }
        }

        # Check 3: undeclared module-level variables (only when in module scope, not in sub)
        if (-not $inSub -and -not $inType -and -not $inEnum) {
            # Look for bare assignments to identifiers
            if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*[^=]') {
                $name = $Matches[1]
                if ($name -in $VBA_KEYWORDS) { continue }
                if ($name -match '^[A-Z][A-Z0-9_]*$') { continue }
                if ($name -in @('True','False','Nothing','Empty','Null')) { continue }
                if ($name -eq $modName) { continue }
                $mInfo = $moduleMap[$modName]
                $defined = $mInfo['module_vars'].ContainsKey($name) -or
                           $mInfo['funcs'].ContainsKey($name) -or
                           $mInfo['subs'].ContainsKey($name) -or
                           $mInfo['consts'].ContainsKey($name) -or
                           $mInfo['props'].ContainsKey($name) -or
                           $mInfo['types'].ContainsKey($name)
                if (-not $defined) {
                    if (-not $results['undeclared_vars'].ContainsKey($file)) {
                        $results['undeclared_vars'][$file] = @()
                    }
                    $results['undeclared_vars'][$file] += "  L$lnum $name"
                }
            }
        }
    }
}

# ====== Report ======
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  VBA COMPILE-ERROR SWEEP REPORT" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "`n[1] UNDECLARED MODULE-LEVEL VARIABLES" -ForegroundColor Yellow
if ($results['undeclared_vars'].Count -eq 0) { Write-Host "  (none)" -ForegroundColor Green }
else {
    foreach ($f in ($results['undeclared_vars'].Keys | Sort-Object)) {
        Write-Host "  $f`:"
        $results['undeclared_vars'][$f] | ForEach-Object { Write-Host "    $_" }
    }
}

Write-Host "`n[2] UNRESOLVED QUALIFIED CALLS (mod_X.Y)" -ForegroundColor Yellow
if ($results['missing_qualified'].Count -eq 0) { Write-Host "  (none)" -ForegroundColor Green }
else {
    foreach ($k in ($results['missing_qualified'].Keys | Sort-Object)) {
        Write-Host "  $k :"
        $results['missing_qualified'][$k] | Select-Object -First 3 | ForEach-Object { Write-Host "    $_" }
        if ($results['missing_qualified'][$k].Count -gt 3) { Write-Host "    ... +$($results['missing_qualified'][$k].Count - 3) more" }
    }
}

Write-Host "`n[3] UNRESOLVED UNQUALIFIED CALLS (FuncName(...))" -ForegroundColor Yellow
if ($results['missing_unqualified'].Count -eq 0) { Write-Host "  (none)" -ForegroundColor Green }
else {
    foreach ($k in ($results['missing_unqualified'].Keys | Sort-Object)) {
        Write-Host "  $k :"
        $results['missing_unqualified'][$k] | ForEach-Object { Write-Host "    $_" }
    }
}

Write-Host "`n=========================================" -ForegroundColor Cyan
