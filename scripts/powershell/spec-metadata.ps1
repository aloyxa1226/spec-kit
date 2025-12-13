# Collect metadata for spec-kit documents
$DateTimeTZ = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
$FilenameTS = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$DateOnly = Get-Date -Format "yyyy-MM-dd"

$RepoRoot = ""
$RepoName = ""
$GitBranch = ""
$GitCommit = ""

if (Get-Command git -ErrorAction SilentlyContinue) {
    try {
        $RepoRoot = git rev-parse --show-toplevel 2>$null
        $RepoName = Split-Path $RepoRoot -Leaf
        $GitBranch = git branch --show-current 2>$null
        if (-not $GitBranch) { $GitBranch = git rev-parse --abbrev-ref HEAD 2>$null }
        $GitCommit = git rev-parse HEAD 2>$null
    } catch { }
}

# Determine output directory preference
$OutputBase = if (Test-Path ".specify") { ".specify" } else { "thoughts/shared" }

Write-Output "Current Date/Time (TZ): $DateTimeTZ"
Write-Output "Date Only: $DateOnly"
if ($GitCommit) { Write-Output "Current Git Commit Hash: $GitCommit" }
if ($GitBranch) { Write-Output "Current Branch Name: $GitBranch" }
if ($RepoName) { Write-Output "Repository Name: $RepoName" }
Write-Output "Timestamp For Filename: $FilenameTS"
Write-Output "Output Base Directory: $OutputBase"
