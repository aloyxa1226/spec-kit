# Fork Customizations (aloyxa1226/spec-kit)

> **IMPORTANT**: This repository is a fork of `github/spec-kit`. All modifications must follow the fork workflow to prevent losing custom changes when syncing with upstream.

## Repository Structure

| Repository | Remote | Purpose |
|------------|--------|---------|
| `github/spec-kit` | `upstream` | Parent repository (read-only) |
| `aloyxa1226/spec-kit` | `origin` | Fork repository (your changes) |

### Branch Strategy

| Branch | Purpose | Modify? |
|--------|---------|---------|
| `upstream-main` | Pristine copy of parent repo | **Never** |
| `main` | Tracks origin/main | Rarely |
| `fork-main` | **Default working branch** with fork-specific modifications | **Yes** |
| `sync-upstream-YYYYMMDD` | Temporary branches for upstream syncs | Delete after merge |
| `backup-fork-main-YYYYMMDD` | Safety backups before risky operations | Keep for 30 days |

---

## Remote Configuration

```bash
# Verify remotes are properly configured
git remote -v
# Expected output:
# origin    https://github.com/aloyxa1226/spec-kit (fetch)
# origin    https://github.com/aloyxa1226/spec-kit (push)
# upstream  https://github.com/github/spec-kit.git (fetch)
# upstream  https://github.com/github/spec-kit.git (push)

# If upstream is missing:
git remote add upstream https://github.com/github/spec-kit.git
git fetch upstream
```

---

## Protected Custom Files

Files listed below contain fork-specific customizations. During upstream syncs, **keep our version** (`--ours`) unless noted otherwise.

### Command/Prompt Files (High Modification Likelihood)

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `templates/commands/specify.md` | `--ours` | Enhanced prompt engineering |
| `templates/commands/plan.md` | `--ours` | Additional planning steps |
| `templates/commands/tasks.md` | `--ours` | Custom task generation logic |
| `templates/commands/implement.md` | `--ours` | Modified implementation workflow |
| `templates/commands/clarify.md` | `--ours` | Custom clarification approach |
| `templates/commands/constitution.md` | Manual | Fork-specific constitution rules |
| `templates/commands/analyze.md` | `--ours` | Custom analysis prompts |
| `templates/commands/checklist.md` | `--ours` | Modified checklist generation |
| `templates/commands/taskstoissues.md` | `--ours` | Custom issue creation |

### Utility Scripts (Medium Modification Likelihood)

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `scripts/bash/common.sh` | Manual | Additional utility functions |
| `scripts/bash/create-new-feature.sh` | Manual | Custom feature numbering |
| `scripts/bash/setup-plan.sh` | `--ours` | Modified planning setup |
| `scripts/bash/check-prerequisites.sh` | Manual | Custom validation logic |
| `scripts/bash/update-agent-context.sh` | Manual | Fork-specific context updates |
| `scripts/powershell/*.ps1` | Mirror bash | PowerShell equivalents |

### Templates (Low-Medium Modification Likelihood)

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `templates/spec-template.md` | Manual | Custom specification format |
| `templates/plan-template.md` | Manual | Modified planning template |
| `templates/tasks-template.md` | Manual | Custom task breakdown format |
| `templates/checklist-template.md` | `--theirs` | Usually take upstream |
| `templates/agent-file-template.md` | `--theirs` | Usually take upstream |

### Fork-Specific Files (Never in Upstream)

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `FORK_CUSTOMIZATIONS.md` | `--ours` | This file |
| `memory/constitution.md` | `--ours` | Fork-specific constitution |

### CLI Customizations

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `src/specify_cli/__init__.py` | Manual | Custom CLI behavior |
| `pyproject.toml` | Manual | Fork-specific dependencies/versions |

---

## Upstream Sync Workflow

### Quick Check (Weekly)

```bash
# Fetch upstream and check how far behind we are
git fetch upstream
BEHIND=$(git rev-list --count fork-main..upstream/main)
echo "Fork is $BEHIND commits behind upstream"

# Preview what changed
git log --oneline upstream/main ^fork-main --no-merges | head -20
```

### Full Sync Process (Monthly or Before Major Changes)

```bash
# Step 1: Ensure clean working directory
git status
# Commit or stash any pending changes

# Step 2: Create backup branch
git branch backup-fork-main-$(date +%Y%m%d)

# Step 3: Create sync branch from fork-main
git checkout -b sync-upstream-$(date +%Y%m%d) fork-main

# Step 4: Merge upstream changes (NO COMMIT yet)
git merge upstream/main --no-commit --no-ff

# Step 5: Check for conflicts
git status | grep "both modified"
```

### Resolve Conflicts

```bash
# Protected files - keep our version
git checkout --ours templates/commands/specify.md
git checkout --ours templates/commands/plan.md
git checkout --ours templates/commands/tasks.md
git checkout --ours templates/commands/implement.md
git checkout --ours templates/commands/clarify.md
git checkout --ours templates/commands/analyze.md
git checkout --ours templates/commands/checklist.md
git checkout --ours templates/commands/taskstoissues.md
git checkout --ours scripts/bash/setup-plan.sh
git checkout --ours FORK_CUSTOMIZATIONS.md
git checkout --ours memory/constitution.md

# Unmodified files - take upstream version
git checkout --theirs templates/checklist-template.md
git checkout --theirs templates/agent-file-template.md
git checkout --theirs templates/vscode-settings.json

# Manual merge required - open in editor
# Look for <<<<<<< HEAD markers and merge carefully
code scripts/bash/common.sh
code scripts/bash/create-new-feature.sh
code scripts/bash/check-prerequisites.sh
code scripts/bash/update-agent-context.sh
code src/specify_cli/__init__.py
code pyproject.toml
```

### Complete the Sync

```bash
# Step 6: Test the merge
bash scripts/bash/check-prerequisites.sh --json
uvx --from . specify init test-sync-project --ai claude
rm -rf test-sync-project  # cleanup

# Step 7: Complete the merge
git add .
git commit -m "sync: Merge upstream changes from github/spec-kit

Upstream commit: $(git rev-parse --short upstream/main)
Protected files: kept fork versions
Manual merges: [list files merged manually]
"

# Step 8: Merge into fork-main
git checkout fork-main
git merge sync-upstream-$(date +%Y%m%d) --no-ff

# Step 9: Push to origin
git push origin fork-main

# Step 10: Cleanup sync branch
git branch -d sync-upstream-$(date +%Y%m%d)
```

---

## Conflict Resolution Priority

| Priority | Category | Action |
|----------|----------|--------|
| 1 | **Security fixes** | ALWAYS take upstream immediately |
| 2 | **Bug fixes in core functionality** | Prefer upstream |
| 3 | **New features** | Merge manually, integrate with fork customizations |
| 4 | **Template improvements** | Merge manually, combine best of both |
| 5 | **Custom extensions/enhancements** | Prefer fork |
| 6 | **Fork-specific files** | Always keep ours |

---

## Pre-Commit Checklist for Fork Modifications

Before committing changes to fork-specific files:

```bash
# 1. Test the modification
bash scripts/bash/check-prerequisites.sh --json
uvx --from . specify init test-project --ai claude
rm -rf test-project

# 2. Update this file if adding new customizations
# Add entry to appropriate table above

# 3. Commit with clear description
git add <files>
git commit -m "fork: <description of customization>

- Customized <file> to add <feature>
- Reason: <why this is needed for the fork>
- Upstream merge strategy: <ours|manual|theirs>
"

# 4. Push to fork
git push origin fork-main
```

---

## Emergency Recovery

### Abort a Merge in Progress

```bash
git merge --abort
```

### Reset to Backup Branch

```bash
git checkout fork-main
git reset --hard backup-fork-main-YYYYMMDD
git push origin fork-main --force-with-lease
```

### Start Fresh from Backup

```bash
git checkout backup-fork-main-YYYYMMDD
git checkout -b fork-main-recovery
# Review and fix issues
git branch -D fork-main
git branch -m fork-main-recovery fork-main
git push origin fork-main --force-with-lease
```

---

## Customization Log

Track all fork-specific modifications here. Update when adding new customizations.

| Date | File | Change | Merge Strategy |
|------|------|--------|----------------|
| YYYY-MM-DD | `templates/commands/specify.md` | Enhanced prompt engineering | `--ours` |
| YYYY-MM-DD | `FORK_CUSTOMIZATIONS.md` | Created fork management docs | `--ours` |

---

## Last Sync Information

| Field | Value |
|-------|-------|
| **Last sync date** | _Not yet synced_ |
| **Upstream commit** | _N/A_ |
| **Conflicts resolved** | _N/A_ |
| **Notes** | Initial fork setup |

---

## References

- **Full methodology**: `spec-driven.md`
- **Agent support matrix**: `AGENTS.md`
- **Contributing guidelines**: `CONTRIBUTING.md`
- **Installation instructions**: `docs/installation.md`
- **Local development setup**: `docs/local-development.md`
