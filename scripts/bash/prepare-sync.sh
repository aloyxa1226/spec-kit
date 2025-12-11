#!/bin/bash
# ABOUTME: Prepares the fork for upstream sync by checking status and creating backups.
# ABOUTME: Run this before syncing with github/spec-kit upstream repository.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== Fork Sync Preparation ===${NC}"
echo ""

# Get script directory and repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${RED}❌ Uncommitted changes detected. Commit or stash first.${NC}"
    git status -s
    exit 1
fi
echo -e "${GREEN}✓${NC} Working directory clean"

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "fork-main" ]]; then
    echo -e "${YELLOW}⚠️  Not on fork-main branch (currently on: $CURRENT_BRANCH)${NC}"
    read -p "Switch to fork-main? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout fork-main
    else
        echo -e "${RED}Aborting. Please switch to fork-main manually.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓${NC} On fork-main branch"

# Fetch upstream
echo ""
echo -e "${CYAN}📡 Fetching upstream changes...${NC}"
git fetch upstream

# Count commits behind
BEHIND=$(git rev-list --count fork-main..upstream/main)
AHEAD=$(git rev-list --count upstream/main..fork-main)

echo ""
echo -e "${CYAN}📊 Sync Status:${NC}"
echo -e "   Commits behind upstream: ${YELLOW}$BEHIND${NC}"
echo -e "   Commits ahead of upstream: ${GREEN}$AHEAD${NC}"

if [[ $BEHIND -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✓ Fork is up to date with upstream. No sync needed.${NC}"
    exit 0
fi

# Show files modified in both repos
echo ""
echo -e "${CYAN}🔍 Files modified in upstream since last sync:${NC}"
git diff --name-only fork-main...upstream/main | head -30
TOTAL_FILES=$(git diff --name-only fork-main...upstream/main | wc -l | tr -d ' ')
if [[ $TOTAL_FILES -gt 30 ]]; then
    echo -e "${YELLOW}   ... and $((TOTAL_FILES - 30)) more files${NC}"
fi

# Check for conflicts with protected files
echo ""
echo -e "${CYAN}⚠️  Protected files that may conflict:${NC}"
PROTECTED_FILES=(
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

CONFLICT_COUNT=0
for file in "${PROTECTED_FILES[@]}"; do
    if git diff --name-only fork-main...upstream/main | grep -q "^$file$"; then
        echo -e "   ${YELLOW}⚠️  $file${NC}"
        ((CONFLICT_COUNT++))
    fi
done

if [[ $CONFLICT_COUNT -eq 0 ]]; then
    echo -e "   ${GREEN}None - no protected files modified upstream${NC}"
fi

# Show recent upstream commits
echo ""
echo -e "${CYAN}📝 Recent upstream commits:${NC}"
git log fork-main..upstream/main --oneline --no-merges | head -15
if [[ $BEHIND -gt 15 ]]; then
    echo -e "${YELLOW}   ... and $((BEHIND - 15)) more commits${NC}"
fi

# Create backup
BACKUP_NAME="backup-fork-main-$(date +%Y%m%d-%H%M%S)"
echo ""
echo -e "${CYAN}💾 Creating backup branch: ${BACKUP_NAME}${NC}"
git branch "$BACKUP_NAME"
echo -e "${GREEN}✓${NC} Backup created"

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Ready to sync. Review changes above.${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Create sync branch:"
echo -e "     ${CYAN}git checkout -b sync-upstream-$(date +%Y%m%d)${NC}"
echo ""
echo -e "  2. Merge upstream (no commit):"
echo -e "     ${CYAN}git merge upstream/main --no-commit --no-ff${NC}"
echo ""
echo -e "  3. Resolve conflicts per FORK_CUSTOMIZATIONS.md"
echo ""
echo -e "  4. Test, commit, and merge into fork-main"
echo ""
echo -e "Backup branch: ${YELLOW}$BACKUP_NAME${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
