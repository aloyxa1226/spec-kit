# ABOUTME: Prepares the fork for upstream sync by checking status and creating backups.
# ABOUTME: Run this before syncing with github/spec-kit upstream repository.

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Get script directory and repo root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
Set-Location $RepoRoot

Write-Host "=== Fork Sync Preparation ===" -ForegroundColor Cyan
Write-Host ""

# Check for uncommitted changes
$status = git status -s
if ($status) {
    Write-Host "❌ Uncommitted changes detected. Commit or stash first." -ForegroundColor Red
    git status -s
    exit 1
}
Write-Host "✓ Working directory clean" -ForegroundColor Green

# Check current branch
$currentBranch = git branch --show-current
if ($currentBranch -ne "fork-main") {
    Write-Host "⚠️  Not on fork-main branch (currently on: $currentBranch)" -ForegroundColor Yellow
    if (-not $Force) {
        $response = Read-Host "Switch to fork-main? [y/N]"
        if ($response -match "^[Yy]$") {
            git checkout fork-main
        } else {
            Write-Host "Aborting. Please switch to fork-main manually." -ForegroundColor Red
            exit 1
        }
    } else {
        git checkout fork-main
    }
}
Write-Host "✓ On fork-main branch" -ForegroundColor Green

# Fetch upstream
Write-Host ""
Write-Host "📡 Fetching upstream changes..." -ForegroundColor Cyan
git fetch upstream

# Count commits behind
$behind = (git rev-list --count fork-main..upstream/main)
$ahead = (git rev-list --count upstream/main..fork-main)

Write-Host ""
Write-Host "📊 Sync Status:" -ForegroundColor Cyan
Write-Host "   Commits behind upstream: $behind" -ForegroundColor Yellow
Write-Host "   Commits ahead of upstream: $ahead" -ForegroundColor Green

if ($behind -eq 0) {
    Write-Host ""
    Write-Host "✓ Fork is up to date with upstream. No sync needed." -ForegroundColor Green
    exit 0
}

# Show files modified in upstream
Write-Host ""
Write-Host "🔍 Files modified in upstream since last sync:" -ForegroundColor Cyan
$modifiedFiles = git diff --name-only fork-main...upstream/main
$modifiedFiles | Select-Object -First 30 | ForEach-Object { Write-Host "   $_" }
$totalFiles = ($modifiedFiles | Measure-Object).Count
if ($totalFiles -gt 30) {
    Write-Host "   ... and $($totalFiles - 30) more files" -ForegroundColor Yellow
}

# Check for conflicts with protected files
Write-Host ""
Write-Host "⚠️  Protected files that may conflict:" -ForegroundColor Cyan
$protectedFiles = @(
    "templates/commands/specify.md"
    "templates/commands/plan.md"
    "templates/commands/tasks.md"
    "templates/commands/implement.md"
    "templates/commands/clarify.md"
    "templates/commands/analyze.md"
    "templates/commands/checklist.md"
    "templates/commands/constitution.md"
    "scripts/bash/common.sh"
    "scripts/bash/create-new-feature.sh"
    "scripts/bash/check-prerequisites.sh"
    "scripts/bash/update-agent-context.sh"
    "src/specify_cli/__init__.py"
    "pyproject.toml"
)

$conflictCount = 0
foreach ($file in $protectedFiles) {
    if ($modifiedFiles -contains $file) {
        Write-Host "   ⚠️  $file" -ForegroundColor Yellow
        $conflictCount++
    }
}

if ($conflictCount -eq 0) {
    Write-Host "   None - no protected files modified upstream" -ForegroundColor Green
}

# Show recent upstream commits
Write-Host ""
Write-Host "📝 Recent upstream commits:" -ForegroundColor Cyan
git log fork-main..upstream/main --oneline --no-merges | Select-Object -First 15 | ForEach-Object { Write-Host "   $_" }
if ($behind -gt 15) {
    Write-Host "   ... and $($behind - 15) more commits" -ForegroundColor Yellow
}

# Create backup
$backupName = "backup-fork-main-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Write-Host ""
Write-Host "💾 Creating backup branch: $backupName" -ForegroundColor Cyan
git branch $backupName
Write-Host "✓ Backup created" -ForegroundColor Green

# Summary
$syncBranchName = "sync-upstream-$(Get-Date -Format 'yyyyMMdd')"
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✓ Ready to sync. Review changes above." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Create sync branch:"
Write-Host "     git checkout -b $syncBranchName" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Merge upstream (no commit):"
Write-Host "     git merge upstream/main --no-commit --no-ff" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Resolve conflicts per FORK_CUSTOMIZATIONS.md"
Write-Host ""
Write-Host "  4. Test, commit, and merge into fork-main"
Write-Host ""
Write-Host "Backup branch: $backupName" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
