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
| `templates/commands/plan-brownfield.md` | `--ours` | Brownfield planning workflow |
| `templates/commands/tasks.md` | `--ours` | Custom task generation logic |
| `templates/commands/implement.md` | `--ours` | Modified implementation workflow |
| `templates/commands/implement-plan.md` | `--ours` | Implementation tracking with phase gates |
| `templates/commands/clarify.md` | `--ours` | Custom clarification approach |
| `templates/commands/research.md` | `--ours` | Brownfield research workflow |
| `templates/commands/constitution.md` | Manual | Fork-specific constitution rules |
| `templates/commands/analyze.md` | `--ours` | Custom analysis prompts |
| `templates/commands/checklist.md` | `--ours` | Modified checklist generation |
| `templates/commands/taskstoissues.md` | `--ours` | Custom issue creation |
| `templates/commands/handoff-create.md` | `--ours` | Brownfield handoff creation workflow |
| `templates/commands/handoff-resume.md` | `--ours` | Brownfield handoff resume workflow |

### Utility Scripts (Medium Modification Likelihood)

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `scripts/bash/common.sh` | Manual | Additional utility functions |
| `scripts/bash/create-new-feature.sh` | Manual | Custom feature numbering |
| `scripts/bash/prepare-sync.sh` | `--ours` | Automated upstream sync preparation |
| `scripts/bash/setup-plan.sh` | `--ours` | Modified planning setup |
| `scripts/bash/spec-metadata.sh` | `--ours` | Spec metadata helpers |
| `scripts/bash/check-prerequisites.sh` | Manual | Custom validation logic |
| `scripts/bash/update-agent-context.sh` | Manual | Fork-specific context updates |
| `scripts/powershell/prepare-sync.ps1` | `--ours` | PowerShell sync preparation |
| `scripts/powershell/spec-metadata.ps1` | `--ours` | PowerShell spec metadata helpers |
| `scripts/powershell/*.ps1` | Mirror bash | PowerShell equivalents |

### Templates (Low-Medium Modification Likelihood)

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `templates/spec-template.md` | Manual | Custom specification format |
| `templates/plan-template.md` | Manual | Modified planning template |
| `templates/plan-brownfield-template.md` | `--ours` | Brownfield planning template |
| `templates/tasks-template.md` | Manual | Custom task breakdown format |
| `templates/checklist-template.md` | `--theirs` | Usually take upstream |
| `templates/research-template.md` | `--ours` | Brownfield research template |
| `templates/handoff-template.md` | `--ours` | Session handoff template |
| `templates/agents/*.md` | `--ours` | Brownfield agent prompts |
| `templates/agent-file-template.md` | `--theirs` | Usually take upstream |

### Fork-Specific Files (Never in Upstream)

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `FORK_CUSTOMIZATIONS.md` | `--ours` | This file |
| `thoughts/shared/**` | `--ours` | Fork-specific planning/research notes |

### Repository Configuration

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `.gitignore` | `--ours` | Fork-specific ignored development directories |

### CLI Customizations

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `src/specify_cli/__init__.py` | Manual | Fork repository configuration, local development mode, brownfield help display |
| `pyproject.toml` | Manual | Fork-specific dependencies/versions |

### Workflow Customizations

| File | Merge Strategy | Description |
|------|----------------|-------------|
| `.github/workflows/release.yml` | Manual | Triggers on `fork-main` branch for independent releases |

---

## Fork-Specific Features

### Brownfield Fork Deployment

The fork includes comprehensive brownfield development support with independent fork-based deployment:

#### **1. Repository Configuration**

The CLI can download templates from any GitHub repository, not just `github/spec-kit`:

```bash
# Using environment variables
export SPEC_KIT_REPO_OWNER=aloyxa1226
export SPEC_KIT_REPO_NAME=spec-kit
specify init myproject --ai claude --script sh

# Using CLI flags
specify init myproject --ai claude --script sh --repo-owner aloyxa1226 --repo-name spec-kit
```

**Configuration precedence:**
1. CLI arguments (`--repo-owner`, `--repo-name`)
2. Environment variables (`SPEC_KIT_REPO_OWNER`, `SPEC_KIT_REPO_NAME`)
3. Default values (`github/spec-kit`)

#### **2. Local Development Mode**

Rapid iteration without GitHub releases using `--local` flag:

```bash
# From spec-kit repository root
specify init --here --ai claude --script sh --local --force

# With custom repository path
specify init myproject --ai claude --script sh --local --local-repo-path /path/to/spec-kit

# Auto-detection order:
# 1. Custom path (--local-repo-path)
# 2. Current working directory (if contains templates/commands/)
# 3. Git repository root (if contains templates/commands/)
```

**Benefits:**
- Instant template deployment (no release needed)
- Test template changes immediately
- Supports all 17 AI agents
- Generates agent-specific commands locally
- 5-10x faster than download mode

#### **3. Fork Release Automation**

GitHub Actions automatically creates releases when pushing to `fork-main`:

```bash
# Make changes to templates
git add templates/commands/
git commit -m "feat: Update brownfield templates"
git push origin fork-main

# GitHub Actions automatically:
# 1. Increments patch version
# 2. Generates 32 packages (17 agents × 2 script types)
# 3. Creates release with all packages
# 4. Includes all brownfield commands
```

**Release triggers:**
- Push to `fork-main` or `main` branches
- Changes in: `memory/`, `scripts/`, `templates/`, `.github/workflows/`
- Manual workflow dispatch

#### **4. Brownfield Command Suite**

Five specialized commands for existing codebase development:

| Command | Purpose | Output |
|---------|---------|--------|
| `/speckit.research` | Document and analyze existing codebase | `.specify/research/YYYY-MM-DD-brownfield-*.md` |
| `/speckit.plan-brownfield` | Create implementation plan for changes | `.specify/plans/YYYY-MM-DD-brownfield-*.md` |
| `/speckit.implement-plan` | Execute plan with phase-by-phase verification | Code changes + plan checkmarks |
| `/speckit.handoff-create` | Create session handoff document | `.specify/handoffs/[TICKET/]YYYY-MM-DD_HH-MM-SS_brownfield-*.md` |
| `/speckit.handoff-resume` | Resume from previous handoff | Restored context + action items |

**Workflow:**
```
Research → Plan → Implement → Handoff → Resume → Implement → ...
```

#### **5. Flexible Constitution Lookup**

The brownfield planning workflow supports flexible constitution file lookup with graceful fallback:

**Search Priority Order:**
1. `.specify/memory/constitution.md` (standard deployed location)
2. `memory/constitution.md` (source/local dev location)
3. `.specify/constitution.md` (alternative location)
4. `constitution.md` (root-level fallback)

**Governance Modes:**

| Mode | Condition | Behavior |
|------|-----------|----------|
| **Full Governance** | Constitution file found | Populate Constitution Check from file principles |
| **Reduced Governance** | No constitution file | Continue with default development process principles |

**Reduced Governance Defaults:**
- Research-First: Codebase research completed before planning
- Plan-Before-Code: Plan approved before implementation
- Phase Gates: Each phase has clear verification criteria
- Incremental Delivery: Changes are small, testable, and reversible

**User Guidance:**
When running in Reduced Governance mode, the plan includes actionable guidance:
```markdown
> **Reduced Governance Mode Active**
>
> This plan was created without a project constitution. Only default development
> process principles are enforced. To enable full governance:
> 1. Run `/speckit.constitution` to create a constitution file
> 2. Re-run `/speckit.plan-brownfield` to regenerate the plan with full governance
```

**Files Modified:**
- `templates/commands/plan-brownfield.md`: Constitution loading instructions, population rules
- `templates/plan-brownfield-template.md`: Governance mode indicator, fallback content

#### **6. CLI Help Display**

The CLI now displays brownfield commands in a dedicated panel:

```
╭──────── Brownfield Commands ────────╮
│  Commands for existing codebases    │
│  • /speckit.research                │
│  • /speckit.plan-brownfield         │
│  • /speckit.implement-plan          │
│  • /speckit.handoff-create          │
│  • /speckit.handoff-resume          │
╰─────────────────────────────────────╯
```

#### **Implementation Details**

**Files Modified:**
- `src/specify_cli/__init__.py`: Added 800+ lines for repository config, local mode, help display
- `.github/workflows/release.yml`: Added `fork-main` trigger
- `templates/commands/handoff-create.md`: New handoff creation workflow
- `templates/commands/handoff-resume.md`: New handoff resume workflow (3 invocation modes)

**Key Functions:**
- `_repo_config()`: Repository configuration with precedence logic
- `_detect_local_repo_path()`: Auto-detect local spec-kit repository
- `copy_template_from_local()`: Copy templates from local filesystem
- `_generate_command_from_template()`: Generate agent-specific commands locally

**Bug Fixes:**
- Fixed `StepTracker.update()` calls → proper `add()`, `start()`, `complete()` methods

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
git checkout --ours .gitignore
git checkout --ours templates/commands/specify.md
git checkout --ours templates/commands/plan.md
git checkout --ours templates/commands/plan-brownfield.md
git checkout --ours templates/commands/tasks.md
git checkout --ours templates/commands/implement.md
git checkout --ours templates/commands/implement-plan.md
git checkout --ours templates/commands/clarify.md
git checkout --ours templates/commands/research.md
git checkout --ours templates/commands/analyze.md
git checkout --ours templates/commands/checklist.md
git checkout --ours templates/commands/taskstoissues.md
git checkout --ours templates/commands/handoff-create.md
git checkout --ours templates/commands/handoff-resume.md
git checkout --ours templates/plan-brownfield-template.md
git checkout --ours templates/research-template.md
git checkout --ours templates/handoff-template.md
git checkout --ours scripts/bash/setup-plan.sh
git checkout --ours scripts/bash/prepare-sync.sh
git checkout --ours scripts/bash/spec-metadata.sh
git checkout --ours FORK_CUSTOMIZATIONS.md

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
| 2025-12-11 | `FORK_CUSTOMIZATIONS.md` | Created fork management docs | `--ours` |
| 2025-12-11 | `scripts/bash/prepare-sync.sh` | Added sync preparation script | `--ours` |
| 2025-12-11 | `scripts/powershell/prepare-sync.ps1` | Added PowerShell sync preparation script | `--ours` |
| 2025-12-11 | `.gitignore` | Ignored AI development directories | `--ours` |
| 2025-12-12 | `templates/commands/research.md` | Added brownfield research workflow | `--ours` |
| 2025-12-12 | `templates/commands/plan-brownfield.md` | Added brownfield planning workflow | `--ours` |
| 2025-12-12 | `templates/commands/implement-plan.md` | Added implementation tracking workflow | `--ours` |
| 2025-12-12 | `templates/research-template.md` | Added research template | `--ours` |
| 2025-12-12 | `templates/plan-brownfield-template.md` | Added brownfield plan template | `--ours` |
| 2025-12-12 | `templates/handoff-template.md` | Added session handoff template | `--ours` |
| 2025-12-12 | `templates/agents/*.md` | Added brownfield agent prompts | `--ours` |
| 2025-12-12 | `scripts/bash/spec-metadata.sh` | Added spec metadata helpers | `--ours` |
| 2025-12-12 | `scripts/powershell/spec-metadata.ps1` | Added PowerShell spec metadata helpers | `--ours` |
| 2025-12-12 | `templates/commands/handoff-create.md` | Added handoff creation workflow | `--ours` |
| 2025-12-12 | `templates/commands/handoff-resume.md` | Added handoff resume workflow | `--ours` |
| 2025-12-12 | `src/specify_cli/__init__.py` | Added fork repository config, local mode, brownfield help | Manual |
| 2025-12-12 | `.github/workflows/release.yml` | Configured release triggers for `fork-main` branch | Manual |
| 2025-12-13 | `templates/commands/plan-brownfield.md` | Added flexible constitution lookup with 4-location search, governance modes | `--ours` |
| 2025-12-13 | `templates/plan-brownfield-template.md` | Added governance mode indicator, reduced governance fallback content | `--ours` |

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
