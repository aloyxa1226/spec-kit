---
date: 2025-12-12 20:13:13 PST
researcher: Claude Code
git_commit: 414983f42d3f42e9a8cc3753fb3d5d2f191bae34
branch: fork-main
repository: spec-kit
topic: "Investigation: Why brownfield artifacts are not deployed by CLI"
tags: [research, cli, brownfield, deployment, debugging, configuration, github-actions]
status: complete
last_updated: 2025-12-12
last_updated_by: Claude Code
last_updated_note: "Added comprehensive CLI architecture, deployment patterns, GitHub Actions analysis, and implementation recommendations"
---

# Research: Why Brownfield Artifacts Are Not Deployed by CLI

**Date**: 2025-12-12 20:13:13 PST
**Researcher**: Claude Code
**Git Commit**: 414983f42d3f42e9a8cc3753fb3d5d2f191bae34
**Branch**: fork-main
**Repository**: spec-kit

## Research Question

The brownfield development workflow was implemented as per the plan at `thoughts/shared/plans/2025-12-11-extending-spec-kit-brownfield.md`, but when testing with `specify init --here --ai claude --script sh`, only greenfield artifacts were deployed. Why are the new brownfield commands missing?

## Summary

**Three distinct issues were identified:**

1. **CLI downloads from hardcoded upstream repository**: The CLI at `src/specify_cli/__init__.py:638-639` hardcodes `github/spec-kit` as the source, ignoring the user's fork at `aloyxa1226/spec-kit`.

2. **No new GitHub release created**: Even if the fork were used, no GitHub release has been created with the brownfield changes. The CLI downloads pre-built ZIP packages from GitHub releases, not from the local repository.

3. **Missing handoff command templates**: The implementation plan specified handoff commands (`speckit.handoff.create.md`, `speckit.handoff.resume.md`), but the source templates were never created in `templates/commands/`.

## Detailed Findings

### 1. CLI Download Mechanism

The `specify init` command does NOT copy files from the local repository. Instead, it downloads pre-built ZIP packages from GitHub releases.

**Entry point**: `src/specify_cli/__init__.py:637-749`

```python
def download_template_from_github(...):
    repo_owner = "github"   # Hardcoded!
    repo_name = "spec-kit"  # Hardcoded!
    api_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/releases/latest"
```

This means:
- The CLI always fetches from `https://api.github.com/repos/github/spec-kit/releases/latest`
- User's fork at `https://github.com/aloyxa1226/spec-kit` is ignored
- Local changes to templates have no effect on `specify init`

### 2. Deployed Files vs Expected Files

**Actually deployed** to `/Users/amartis/work-Dev/Celito.Middleware/.claude/commands/`:
1. speckit.analyze.md
2. speckit.checklist.md
3. speckit.clarify.md
4. speckit.constitution.md
5. speckit.implement.md
6. speckit.plan.md
7. speckit.specify.md
8. speckit.tasks.md
9. speckit.taskstoissues.md

**Expected brownfield commands** (missing):
- speckit.research.md
- speckit.plan-brownfield.md
- speckit.implement-plan.md
- speckit.handoff.create.md
- speckit.handoff.resume.md

### 3. Brownfield Template Files Status

**Present in repository** (`templates/commands/`):
| File | Created | Status |
|------|---------|--------|
| research.md | Dec 11 21:19 | ✅ Present |
| plan-brownfield.md | Dec 12 08:15 | ✅ Present |
| implement-plan.md | Dec 12 15:13 | ✅ Present |

**Missing from repository**:
| File | Expected Location | Status |
|------|-------------------|--------|
| handoff-create.md | templates/commands/ | ❌ Not created |
| handoff-resume.md | templates/commands/ | ❌ Not created |

The handoff template (`templates/handoff-template.md`) exists, but the command templates to use it were never created.

### 4. Release Build Process

The release packages are built by GitHub Actions via `.github/workflows/scripts/create-release-packages.sh`:

1. **Source directories packaged**:
   - `memory/` → `.specify/memory/`
   - `scripts/bash/` or `scripts/powershell/` → `.specify/scripts/`
   - `templates/` (excluding `commands/`) → `.specify/templates/`

2. **Command generation** (`create-release-packages.sh:40-102`):
   - Processes each file in `templates/commands/`
   - Generates agent-specific command files (e.g., `.claude/commands/speckit.*.md`)

3. **ZIP creation**:
   - Pattern: `spec-kit-template-{agent}-{script}-{version}.zip`
   - Example: `spec-kit-template-claude-sh-v0.0.90.zip`

### 5. Fork vs Upstream Configuration

**Git remotes**:
```
origin    https://github.com/aloyxa1226/spec-kit (fork)
upstream  https://github.com/github/spec-kit (original)
```

The brownfield commit (`602f7bc feat: Add brownfield development workflow support`) exists on the fork's `fork-main` branch but:
- Has not been merged to upstream
- No release has been created on the fork

## Architecture Documentation

### CLI Deployment Flow

```
specify init --ai claude --script sh
    │
    ▼
download_template_from_github()
    │
    ├── API call: https://api.github.com/repos/github/spec-kit/releases/latest
    │                                          ▲
    │                                          │ Hardcoded!
    │
    ▼
Find asset: spec-kit-template-claude-sh-v*.zip
    │
    ▼
download_and_extract_template()
    │
    ├── Extract to temp directory
    ├── Merge into target directory
    └── Set script permissions
```

### Release Build Flow

```
Push to main branch
    │
    ▼
.github/workflows/release.yml
    │
    ▼
create-release-packages.sh
    │
    ├── For each (agent, script) combination:
    │   ├── Copy memory/, scripts/, templates/
    │   ├── Generate agent-specific commands from templates/commands/
    │   └── Create ZIP archive
    │
    ▼
Create GitHub release with ZIP assets
```

## Code References

- `src/specify_cli/__init__.py:637-749` - Template download function with hardcoded repo
- `src/specify_cli/__init__.py:638-639` - Hardcoded `github/spec-kit` owner/repo
- `.github/workflows/scripts/create-release-packages.sh:40-102` - Command generation logic
- `.github/workflows/scripts/create-release-packages.sh:124-223` - Package build function
- `templates/commands/research.md` - Brownfield research command template
- `templates/commands/plan-brownfield.md` - Brownfield planning command template
- `templates/commands/implement-plan.md` - Plan implementation command template

## Root Cause Analysis

| Issue | Root Cause | Impact |
|-------|------------|--------|
| CLI downloads from upstream | Hardcoded `repo_owner = "github"` at line 638 | Fork changes are never deployed |
| No release on fork | GitHub Actions not triggered on fork | Even if CLI used fork, no packages exist |
| Missing handoff commands | Templates never created | Handoff workflow incomplete |

## Remediation Options

### Option A: Create Release on Fork

1. Configure GitHub Actions on fork to create releases
2. Modify CLI to use fork's repo (or make configurable)
3. Create new release to include brownfield templates

### Option B: Merge to Upstream

1. Create PR to merge brownfield changes to `github/spec-kit`
2. Wait for new release to be created
3. No CLI changes needed

### Option C: Local Development Mode

1. Add `--local` flag to CLI that copies from local repo instead of downloading
2. Use for development/testing before releases

### Option D: Create Missing Templates

Regardless of deployment method, create missing command templates:
- `templates/commands/handoff-create.md`
- `templates/commands/handoff-resume.md`

## Related Research

- `thoughts/shared/research/2025-12-11-extending-spec-kit-for-brownfield.md` - Original brownfield research
- `thoughts/shared/plans/2025-12-11-extending-spec-kit-brownfield.md` - Implementation plan

## CLI Configuration Architecture

### Current Configuration Mechanisms

**Framework**: The CLI uses **Typer** (built on Click) for argument parsing.

**Configuration Precedence** (limited):
1. CLI arguments (highest priority)
2. Environment variables (`GH_TOKEN`, `GITHUB_TOKEN` only)
3. No config file support currently
4. Hardcoded defaults (lowest priority)

**Argument Pattern** (`src/specify_cli/__init__.py:946-957`):
```python
def init(
    project_name: str = typer.Argument(None, help="..."),
    ai_assistant: str = typer.Option(None, "--ai", help="..."),
    script_type: str = typer.Option(None, "--script", help="..."),
    here: bool = typer.Option(False, "--here", help="..."),
    github_token: str = typer.Option(None, "--github-token", help="..."),
    # ... other parameters
):
```

**Key Findings**:
- No `.specify/config.toml` or `~/.config/specify/config.toml` support
- `platformdirs` dependency is available but unused
- Easy to extend with new flags using Typer's type-safe pattern
- GitHub token is only configurable value via env vars

### Hardcoded Repository References

**Two locations** maintain hardcoded `github/spec-kit`:

1. **Download function** (`src/specify_cli/__init__.py:638-639`):
```python
def download_template_from_github(...):
    repo_owner = "github"
    repo_name = "spec-kit"
```

2. **Version command** (`src/specify_cli/__init__.py:1310-1312`):
```python
@app.command()
def version():
    repo_owner = "github"
    repo_name = "spec-kit"
```

Both need centralization and configuration support.

### File Deployment and Merging Logic

**Standard Extraction** (`src/specify_cli/__init__.py:846-870`):
- Extracts ZIP directly to `project_path`
- Flattens single-directory structure if present
- Sets executable permissions on `.sh` files (Unix only)

**Merge Mode** for `--here` (`src/specify_cli/__init__.py:821-844`):
- Extracts to temp directory first
- Iterates recursively through source files
- **Directories**: Merges if exists, copies if new
- **Files**: Overwrites existing files
- **Special case**: `.vscode/settings.json` uses deep JSON merge

**JSON Deep Merge** (`src/specify_cli/__init__.py:594-635`):
```python
def merge_json_files(existing_path, new_content):
    # Recursively merges nested dictionaries
    # Replaces non-dict values (arrays, primitives)
    # New keys are added to existing settings
```

### Directory Structures Copied

**From release packages** (via `create-release-packages.sh`):

1. **Scripts** (filtered by variant):
   - Source: `scripts/bash/` or `scripts/powershell/`
   - Destination: `.specify/scripts/{bash|powershell}/`
   - Files: `common.{sh|ps1}`, `prepare-sync.{sh|ps1}`, `setup-plan.{sh|ps1}`, etc.

2. **Templates** (excluding commands):
   - Source: `templates/*.md`, `templates/agents/`
   - Destination: `.specify/templates/`
   - Excludes: `templates/commands/*` (generated per-agent), `vscode-settings.json` (special handling)

3. **Memory** (if exists):
   - Source: `memory/`
   - Destination: `.specify/memory/`
   - Note: Currently doesn't exist in repository

4. **Agent Commands** (generated from `templates/commands/`):
   - Source: `templates/commands/*.md`
   - Destination: Agent-specific folders (`.claude/commands/`, `.gemini/commands/`, etc.)
   - Processing: Path rewriting, placeholder substitution, format conversion

### GitHub Actions Release Workflow

**Triggers** (`.github/workflows/release.yml`):
- Push to `main` branch with changes to: `memory/**`, `scripts/**`, `templates/**`, `.github/workflows/**`
- Manual trigger via `workflow_dispatch`

**Fork Compatibility**: ✅ Excellent
- **No hardcoded repo references** in workflow files
- Uses `GITHUB_TOKEN` (automatically provided)
- All scripts use relative paths
- `gh release create` works for any repo
- Version auto-increment from git tags is repo-agnostic

**Required Changes for Fork**:
1. Change trigger branch from `main` to `fork-main`:
   ```yaml
   on:
     push:
       branches: [ fork-main ]  # Change from [ main ]
   ```

**Version Determination** (`get-next-version.sh`):
- Gets latest git tag: `git describe --tags --abbrev=0`
- Auto-increments patch version: `v0.0.9` → `v0.0.10`
- First release defaults to `v0.0.1`

**Build Process** (`create-release-packages.sh`):
- Builds 17 agents × 2 script types = 34 ZIP packages
- Agents: claude, gemini, copilot, cursor-agent, qwen, opencode, windsurf, codex, kilocode, auggie, roo, codebuddy, qoder, amp, shai, q, bob
- Output: `spec-kit-template-{agent}-{script}-{version}.zip`

## Implementation Patterns for Local Mode

### Proposed Local Copy Pattern

A `--local` flag would mirror the download flow but source from local repository:

**Key Steps**:
1. **Prepare staging directory** (mimics ZIP structure)
2. **Copy base structure**:
   - `scripts/{bash|powershell}/` → staging
   - `templates/` (excluding `commands/`) → staging
   - `memory/` (if exists) → staging
3. **Generate agent commands** from `templates/commands/`:
   - Apply path rewrites: `memory/` → `.specify/memory/`, etc.
   - Substitute placeholders: `{SCRIPT}`, `{ARGS}`, etc.
   - Output to agent-specific directories
4. **Merge or extract** using existing `download_and_extract_template()` logic

**Reusable Components**:
- Directory merging logic (lines 821-844)
- JSON merge for `.vscode/settings.json` (lines 594-635)
- Script permission setting (lines 901-943)
- Path flattening (lines 857-870)

**File Copy Utilities Used**:
- `shutil.copytree()` - Copy entire directory trees
- `shutil.copy2()` - Copy single files (preserves metadata)
- `Path.rglob('*')` - Recursive file iteration
- `tempfile.TemporaryDirectory()` - Atomic operations

## Updated Remediation Options

### Option A: Create Release on Fork ✅ Recommended

**Advantages**:
- Enables independent fork development
- Full brownfield workflow available immediately
- No dependency on upstream merges

**Implementation Steps**:
1. Update `.github/workflows/release.yml` trigger branch to `fork-main`
2. Add CLI configuration for custom repo:
   - Environment variables: `SPEC_KIT_REPO_OWNER`, `SPEC_KIT_REPO_NAME`
   - CLI flags: `--repo-owner`, `--repo-name`
   - Config file support (optional): `~/.config/specify/config.toml`
3. Create missing handoff command templates
4. Push to `fork-main` to trigger release
5. Test with: `specify init --here --ai claude --script sh --repo-owner aloyxa1226`

**Complexity**: Medium (3-4 files to modify)

### Option C: Local Development Mode ✅ Recommended

**Advantages**:
- No release needed for testing
- Instant iteration on template changes
- Essential for fork development workflow

**Implementation Steps**:
1. Add `--local` flag to `init()` function
2. Create `copy_template_from_local()` function:
   - Accept `local_repo_path` parameter
   - Detect local repo root (use current directory or git root)
   - Copy directory structures (scripts, templates, memory)
   - Generate agent commands from `templates/commands/`
   - Reuse existing merge/extract logic
3. Auto-detect local mode if in spec-kit repository
4. Test with: `specify init --here --ai claude --script sh --local`

**Complexity**: Medium (1 new function, reuses existing patterns)

### Option D: Create Missing Templates ✅ Required

**Missing Files**:
- `templates/commands/handoff-create.md`
- `templates/commands/handoff-resume.md`

**Based on Plan Phase 3**:
- Source: `.claude/commands/speckit.handoff.create.md` as reference
- Source: `.claude/commands/speckit.handoff.resume.md` as reference
- Extract core logic into agent-agnostic templates
- Add YAML frontmatter with `scripts` and `description`

**Complexity**: Low (2 new template files)

## Open Questions - ANSWERED

1. **Should the CLI support configurable repo owner/name for forks?**
   - ✅ **YES** - Via environment variables and CLI flags

2. **Should there be a `--local` development mode that copies from local repo?**
   - ✅ **YES** - Essential for fork development and testing

3. **Is the fork intended to eventually merge to upstream, or remain separate?**
   - ❌ **NO** - Fork will remain independent at this time

4. **Should handoff commands be created to complete the brownfield workflow?**
   - ✅ **YES** - Required to complete Phase 3 of brownfield implementation

## Next Steps

Based on user responses, the implementation plan should include:

1. **Fork release automation**: Update GitHub Actions for `fork-main` branch
2. **CLI configuration support**: Add `--repo-owner`, `--repo-name`, environment variables
3. **Local development mode**: Add `--local` flag with local copy logic
4. **Complete brownfield workflow**: Create missing handoff command templates

All four components work together to enable fork-based brownfield development.
