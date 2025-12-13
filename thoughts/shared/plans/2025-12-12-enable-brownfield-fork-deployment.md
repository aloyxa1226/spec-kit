# Enable Brownfield Fork Deployment Implementation Plan

## Overview

This plan enables independent fork-based brownfield development by making the spec-kit CLI configurable to download templates from any repository, adding local development mode for rapid iteration, enabling GitHub Actions releases on fork branches, and completing the brownfield workflow with handoff command templates.

## Current State Analysis

### What Exists Now

**Brownfield Templates Created** (Phase 1 & 2 of original brownfield plan):
- `templates/commands/research.md` - Core research command
- `templates/commands/plan-brownfield.md` - Brownfield planning command
- `templates/commands/implement-plan.md` - Plan execution command
- `templates/handoff-template.md` - Handoff document template

**CLI Download Mechanism**:
- `src/specify_cli/__init__.py:638-639` - Hardcoded `repo_owner = "github"` and `repo_name = "spec-kit"`
- Downloads pre-built ZIP packages from GitHub releases
- Supports `--here` mode with directory merging
- Environment variable support for GitHub token only

**GitHub Actions Release Workflow**:
- `.github/workflows/release.yml` - Triggers on `main` branch
- Already fork-compatible (no hardcoded repo references)
- Generates 32 packages (16 agents × 2 script types)
- Auto-increments patch version from git tags

**Reference Implementations**:
- `.claude/commands/create_handoff.md` - Handoff creation pattern
- `.claude/commands/resume_handoff.md` - Handoff resumption pattern

### What's Missing

1. **CLI cannot download from forks**: Hardcoded to `github/spec-kit`
2. **No local development mode**: Must create releases to test template changes
3. **Fork release automation**: Workflow triggers on `main`, not `fork-main`
4. **Missing handoff commands**: Templates for `handoff-create.md` and `handoff-resume.md` not created

### Key Discoveries

- **src/specify_cli/__init__.py:61-66**: Token precedence pattern (`cli_token` > `GH_TOKEN` > `GITHUB_TOKEN`) serves as model for repo configuration
- **src/specify_cli/__init__.py:821-842**: Existing merge logic can be reused for local template copying
- **src/specify_cli/__init__.py:637**: Function signature uses keyword-only parameters after `*` for optional config
- **.github/workflows/scripts/create-release-packages.sh:40-102**: Command generation from templates is fully scripted and reusable locally
- **User Feedback**: All brownfield artifacts must use `.specify/` directory structure with "brownfield" in filenames

## Desired End State

### Success Criteria

After implementation, the following will be true:

#### Automated Verification:
- [x] CLI accepts `--repo-owner` and `--repo-name` flags: `specify init --help` shows new options
- [ ] Environment variables work: `SPEC_KIT_REPO_OWNER=aloyxa1226 specify init --here --ai claude --script sh` downloads from fork
- [x] Local mode works: `specify init --here --ai claude --script sh --local` copies from local repository
- [ ] Fork release triggers: Push to `fork-main` creates GitHub release
- [x] Handoff templates exist: `ls templates/commands/handoff-*.md` shows two files
- [ ] All tests pass: `pytest` (if tests exist)
- [x] CLI installs successfully: `pip install -e .` completes without errors

#### Manual Verification:
- [ ] Fork release contains all brownfield commands (research, plan-brownfield, implement-plan, handoff-create, handoff-resume)
- [x] Local mode generates correct agent-specific commands in `.claude/commands/`
- [x] Handoff commands follow spec-kit conventions (`.specify/handoffs/` directory structure)
- [ ] Downloaded templates include brownfield artifacts
- [ ] Performance is acceptable (local mode faster than download mode)

## What We're NOT Doing

- NOT modifying the core template download logic (keeping ZIP-based approach)
- NOT adding config file support (`~/.config/specify/config.toml`) - environment variables and CLI flags only
- NOT changing the existing greenfield workflow
- NOT merging to upstream `github/spec-kit` at this time
- NOT implementing auto-detection of local spec-kit repository (explicit `--local` flag required)
- NOT adding handoff commands to greenfield workflow (brownfield-only feature)

## Implementation Approach

### High-Level Strategy

1. **Configuration First**: Add repo configuration to CLI, enabling fork downloads
2. **Local Development**: Add `--local` mode for rapid iteration without releases
3. **Fork Automation**: Enable GitHub Actions on fork branch
4. **Complete Workflow**: Create handoff templates to finish brownfield tooling

Each phase is independently testable and provides incremental value.

---

## Phase 1: CLI Repository Configuration

### Overview

Make the CLI download from configurable repositories instead of hardcoded `github/spec-kit`. This enables fork-based development and independent template distribution.

### Changes Required

#### 1. Centralize Repository Configuration

**File**: `src/specify_cli/__init__.py`

**New Constants** (add after line 233):

```python
# Default repository configuration
DEFAULT_REPO_OWNER = "github"
DEFAULT_REPO_NAME = "spec-kit"
```

#### 2. Add Repository Configuration Helper

**File**: `src/specify_cli/__init__.py`

**New Function** (add after line 66, following the `_github_auth_headers()` pattern):

```python
def _repo_config(cli_owner: str | None = None, cli_name: str | None = None) -> tuple[str, str]:
    """Return repository owner and name (cli args take precedence over env vars, then defaults).

    Precedence:
    1. CLI arguments (--repo-owner, --repo-name)
    2. Environment variables (SPEC_KIT_REPO_OWNER, SPEC_KIT_REPO_NAME)
    3. Default values (github/spec-kit)

    Returns:
        tuple[str, str]: (repo_owner, repo_name)
    """
    owner = cli_owner or os.getenv("SPEC_KIT_REPO_OWNER") or DEFAULT_REPO_OWNER
    name = cli_name or os.getenv("SPEC_KIT_REPO_NAME") or DEFAULT_REPO_NAME
    return owner, name
```

#### 3. Update Download Function Signature

**File**: `src/specify_cli/__init__.py`

**Line 637** - Update function signature:

```python
def download_template_from_github(ai_assistant: str, download_dir: Path, *, script_type: str = "sh", verbose: bool = True, show_progress: bool = True, client: httpx.Client = None, debug: bool = False, github_token: str = None, repo_owner: str = None, repo_name: str = None) -> Tuple[Path, dict]:
```

**Lines 638-639** - Replace hardcoded values with configuration:

```python
def download_template_from_github(ai_assistant: str, download_dir: Path, *, script_type: str = "sh", verbose: bool = True, show_progress: bool = True, client: httpx.Client = None, debug: bool = False, github_token: str = None, repo_owner: str = None, repo_name: str = None) -> Tuple[Path, dict]:
    repo_owner, repo_name = _repo_config(repo_owner, repo_name)

    # Debug output to show which repo is being used
    if debug:
        console.print(f"[dim]Using repository: {repo_owner}/{repo_name}[/dim]")
```

#### 4. Update Version Command

**File**: `src/specify_cli/__init__.py`

**Lines 1310-1312** - Update version command to use configuration:

```python
@app.command()
def version(
    repo_owner: str = typer.Option(None, "--repo-owner", help="GitHub repository owner (defaults to 'github' or SPEC_KIT_REPO_OWNER env var)"),
    repo_name: str = typer.Option(None, "--repo-name", help="GitHub repository name (defaults to 'spec-kit' or SPEC_KIT_REPO_NAME env var)"),
):
    """Show the latest spec-kit release version from GitHub."""
    repo_owner, repo_name = _repo_config(repo_owner, repo_name)
```

#### 5. Add CLI Parameters to Init Command

**File**: `src/specify_cli/__init__.py`

**Line 956** - Add new parameters after `github_token`:

```python
@app.command()
def init(
    project_name: str = typer.Argument(None, help="Name for your new project directory (optional if using --here, or use '.' for current directory)"),
    ai_assistant: str = typer.Option(None, "--ai", help="AI assistant to use: claude, gemini, copilot, cursor-agent, qwen, opencode, codex, windsurf, kilocode, auggie, codebuddy, amp, shai, q, bob, or qoder "),
    script_type: str = typer.Option(None, "--script", help="Script type to use: sh or ps"),
    ignore_agent_tools: bool = typer.Option(False, "--ignore-agent-tools", help="Skip checks for AI agent tools like Claude Code"),
    no_git: bool = typer.Option(False, "--no-git", help="Skip git repository initialization"),
    here: bool = typer.Option(False, "--here", help="Initialize project in the current directory instead of creating a new one"),
    force: bool = typer.Option(False, "--force", help="Force merge/overwrite when using --here (skip confirmation)"),
    skip_tls: bool = typer.Option(False, "--skip-tls", help="Skip SSL/TLS verification (not recommended)"),
    debug: bool = typer.Option(False, "--debug", help="Show verbose diagnostic output for network and extraction failures"),
    github_token: str = typer.Option(None, "--github-token", help="GitHub token to use for API requests (or set GH_TOKEN or GITHUB_TOKEN environment variable)"),
    repo_owner: str = typer.Option(None, "--repo-owner", help="GitHub repository owner (defaults to 'github' or SPEC_KIT_REPO_OWNER env var)"),
    repo_name: str = typer.Option(None, "--repo-name", help="GitHub repository name (defaults to 'spec-kit' or SPEC_KIT_REPO_NAME env var)"),
):
```

#### 6. Thread Parameters Through Call Chain

**File**: `src/specify_cli/__init__.py`

**Line 1127** - Pass to `download_and_extract_template()`:

```python
download_and_extract_template(project_path, selected_ai, selected_script, here, verbose=False, tracker=tracker, client=local_client, debug=debug, github_token=github_token, repo_owner=repo_owner, repo_name=repo_name)
```

**Line 760** - Update `download_and_extract_template()` signature (add after line 755):

```python
def download_and_extract_template(project_path: Path, ai_assistant: str, script_type: str,
    is_current_dir: bool = False, *, verbose: bool = True, tracker: StepTracker | None = None,
    client: httpx.Client = None, debug: bool = False, github_token: str = None, repo_owner: str = None, repo_name: str = None) -> Path:
```

**Line 768** - Pass to `download_template_from_github()`:

```python
zip_path, meta = download_template_from_github(
    ai_assistant,
    current_dir,
    script_type=script_type,
    verbose=verbose and tracker is None,
    show_progress=(tracker is None),
    client=client,
    debug=debug,
    github_token=github_token,
    repo_owner=repo_owner,
    repo_name=repo_name
)
```

### Success Criteria

#### Automated Verification:
- [x] CLI help shows new flags: `specify init --help | grep -E "(--repo-owner|--repo-name)"`
- [ ] Default behavior unchanged: `specify init test-project --ai claude --script sh` downloads from `github/spec-kit`
- [ ] Environment variables work: `SPEC_KIT_REPO_OWNER=test SPEC_KIT_REPO_NAME=fork specify init --help` (check debug output)
- [x] CLI flags work: `specify init --help` shows repo options
- [ ] Type checking passes: `mypy src/specify_cli/` (if mypy configured)
- [ ] Linting passes: `ruff check src/specify_cli/` (if ruff configured)

#### Manual Verification:
- [ ] Fork download works with flags: `specify init test-fork --ai claude --script sh --repo-owner aloyxa1226 --repo-name spec-kit`
- [ ] Fork download works with env vars: `SPEC_KIT_REPO_OWNER=aloyxa1226 specify init test-fork2 --ai claude --script sh`
- [ ] Debug output shows correct repo: `specify init test --ai claude --script sh --debug --repo-owner test`
- [ ] Error handling works for invalid repos
- [ ] Version command shows fork version: `specify version --repo-owner aloyxa1226`

**Implementation Note**: After completing this phase and all automated verification passes, test manually with a fork repository before proceeding to Phase 2.

---

## Phase 2: Local Development Mode

### Overview

Add `--local` flag to enable copying templates from local repository without needing a GitHub release. This accelerates development iteration and enables testing changes immediately.

### Changes Required

#### 1. Add Local Mode Flag to Init Command

**File**: `src/specify_cli/__init__.py`

**Line 967** - Add after `repo_name` parameter:

```python
    local: bool = typer.Option(False, "--local", help="Copy templates from local repository instead of downloading from GitHub"),
    local_repo_path: str = typer.Option(None, "--local-repo-path", help="Path to local spec-kit repository (defaults to current directory or git root)"),
```

#### 2. Add Local Repository Detection Function

**File**: `src/specify_cli/__init__.py`

**New Function** (add after `_repo_config()`):

```python
def _detect_local_repo_path(custom_path: str | None = None) -> Path | None:
    """Detect local spec-kit repository path.

    Search order:
    1. Custom path provided via --local-repo-path
    2. Current working directory (if it contains templates/commands/)
    3. Git repository root (if in a git repo and it contains templates/commands/)

    Returns:
        Path | None: Absolute path to spec-kit repository, or None if not found
    """
    if custom_path:
        path = Path(custom_path).resolve()
        if (path / "templates" / "commands").is_dir():
            return path
        else:
            console.print(f"[red]Error:[/red] Path {custom_path} does not contain templates/commands/")
            return None

    # Check current directory
    cwd = Path.cwd()
    if (cwd / "templates" / "commands").is_dir():
        return cwd

    # Check git root
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            check=True,
            cwd=cwd
        )
        git_root = Path(result.stdout.strip()).resolve()
        if (git_root / "templates" / "commands").is_dir():
            return git_root
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    return None
```

#### 3. Create Local Template Copy Function

**File**: `src/specify_cli/__init__.py`

**New Function** (add after `_detect_local_repo_path()`):

```python
def copy_template_from_local(
    project_path: Path,
    local_repo_path: Path,
    ai_assistant: str,
    script_type: str,
    is_current_dir: bool = False,
    *,
    verbose: bool = True,
    tracker: StepTracker | None = None,
    debug: bool = False
) -> Path:
    """Copy template files from local repository and generate agent-specific commands.

    This mimics the download-and-extract flow but sources from local filesystem.
    Reuses the same merge/extract logic as remote templates.

    Args:
        project_path: Destination directory
        local_repo_path: Path to local spec-kit repository
        ai_assistant: Agent type (claude, gemini, etc.)
        script_type: Script variant (sh or ps)
        is_current_dir: Whether merging into current directory
        verbose: Show detailed output
        tracker: Optional progress tracker
        debug: Show debug information

    Returns:
        Path: The project path where templates were copied
    """
    import tempfile
    import subprocess

    if debug:
        console.print(f"[dim]Using local repository: {local_repo_path}[/dim]")

    if tracker:
        tracker.update(f"Copying from local repository", style="cyan")
    elif verbose:
        console.print("[cyan]Copying templates from local repository...[/cyan]")

    # Create temporary staging directory to build package structure
    with tempfile.TemporaryDirectory() as temp_dir:
        staging_dir = Path(temp_dir) / "staging"
        staging_dir.mkdir()

        if tracker:
            tracker.update("Preparing template structure", style="cyan")

        # 1. Copy base structure
        spec_dir = staging_dir / ".specify"
        spec_dir.mkdir()

        # Copy memory/ if exists
        memory_src = local_repo_path / "memory"
        if memory_src.is_dir():
            shutil.copytree(memory_src, spec_dir / "memory")
            if debug:
                console.print(f"[dim]Copied memory/[/dim]")

        # Copy scripts (filter by variant)
        script_dir_name = "bash" if script_type == "sh" else "powershell"
        scripts_src = local_repo_path / "scripts" / script_dir_name
        if scripts_src.is_dir():
            shutil.copytree(scripts_src, spec_dir / "scripts" / script_dir_name)
            if debug:
                console.print(f"[dim]Copied scripts/{script_dir_name}/[/dim]")

        # Copy templates (excluding commands/)
        templates_src = local_repo_path / "templates"
        templates_dest = spec_dir / "templates"
        templates_dest.mkdir()

        for item in templates_src.iterdir():
            if item.name == "commands" or item.name == "vscode-settings.json":
                continue  # Skip - handled separately
            if item.is_dir():
                shutil.copytree(item, templates_dest / item.name)
            else:
                shutil.copy2(item, templates_dest / item.name)

        if debug:
            console.print(f"[dim]Copied templates/ (excluding commands/)[/dim]")

        # 2. Generate agent-specific commands
        if tracker:
            tracker.update("Generating agent commands", style="cyan")

        # Determine agent configuration
        agent_configs = {
            "claude": {"folder": ".claude/commands", "ext": "md", "args": "$ARGUMENTS"},
            "gemini": {"folder": ".gemini/commands", "ext": "toml", "args": "{{args}}"},
            "copilot": {"folder": ".github/agents", "ext": "agent.md", "args": "$ARGUMENTS"},
            "cursor-agent": {"folder": ".cursor/commands", "ext": "md", "args": "$ARGUMENTS"},
            "qwen": {"folder": ".qwen/commands", "ext": "toml", "args": "{{args}}"},
            "opencode": {"folder": ".opencode/command", "ext": "md", "args": "$ARGUMENTS"},
            "windsurf": {"folder": ".windsurf/workflows", "ext": "md", "args": "$ARGUMENTS"},
            "codex": {"folder": ".codex/prompts", "ext": "md", "args": "$ARGUMENTS"},
            "kilocode": {"folder": ".kilocode/workflows", "ext": "md", "args": "$ARGUMENTS"},
            "auggie": {"folder": ".augment/commands", "ext": "md", "args": "$ARGUMENTS"},
            "roo": {"folder": ".roo/commands", "ext": "md", "args": "$ARGUMENTS"},
            "codebuddy": {"folder": ".codebuddy/commands", "ext": "md", "args": "$ARGUMENTS"},
            "qoder": {"folder": ".qoder/commands", "ext": "md", "args": "$ARGUMENTS"},
            "amp": {"folder": ".agents/commands", "ext": "md", "args": "$ARGUMENTS"},
            "shai": {"folder": ".shai/commands", "ext": "md", "args": "$ARGUMENTS"},
            "q": {"folder": ".amazonq/prompts", "ext": "md", "args": "$ARGUMENTS"},
            "bob": {"folder": ".bob/commands", "ext": "md", "args": "$ARGUMENTS"},
        }

        agent_config = agent_configs.get(ai_assistant)
        if not agent_config:
            raise ValueError(f"Unknown AI assistant: {ai_assistant}")

        commands_dir = staging_dir / agent_config["folder"]
        commands_dir.mkdir(parents=True)

        # Process each command template
        commands_src = local_repo_path / "templates" / "commands"
        if not commands_src.is_dir():
            console.print(f"[yellow]Warning:[/yellow] No templates/commands/ directory found")
        else:
            for template in commands_src.glob("*.md"):
                _generate_command_from_template(
                    template,
                    commands_dir,
                    ai_assistant,
                    script_type,
                    agent_config["ext"],
                    agent_config["args"],
                    debug=debug
                )

        if debug:
            console.print(f"[dim]Generated commands in {agent_config['folder']}[/dim]")

        # Special handling for Copilot (generate prompt files)
        if ai_assistant == "copilot":
            prompts_dir = staging_dir / ".github" / "prompts"
            prompts_dir.mkdir(parents=True)
            for agent_file in commands_dir.glob("speckit.*.agent.md"):
                basename = agent_file.stem  # e.g., "speckit.research"
                prompt_file = prompts_dir / f"{basename}.prompt.md"
                prompt_file.write_text(f"---\nagent: {basename}\n---\n")

            # Copy VS Code settings for Copilot
            vscode_settings_src = local_repo_path / "templates" / "vscode-settings.json"
            if vscode_settings_src.is_file():
                vscode_dir = staging_dir / ".vscode"
                vscode_dir.mkdir()
                shutil.copy2(vscode_settings_src, vscode_dir / "settings.json")

        # 3. Merge or extract using existing logic
        if tracker:
            tracker.update("Deploying templates", style="cyan")

        # Reuse the merge/extract logic from download_and_extract_template
        if is_current_dir:
            # Merge mode - iterate through staging and merge into project_path
            for item in staging_dir.iterdir():
                dest_path = project_path / item.name
                if item.is_dir():
                    if dest_path.exists():
                        # Merge directory
                        if verbose and not tracker:
                            console.print(f"[yellow]Merging directory:[/yellow] {item.name}")
                        for sub_item in item.rglob('*'):
                            if sub_item.is_file():
                                rel_path = sub_item.relative_to(item)
                                dest_file = dest_path / rel_path
                                dest_file.parent.mkdir(parents=True, exist_ok=True)
                                # Special handling for .vscode/settings.json
                                if dest_file.name == "settings.json" and dest_file.parent.name == ".vscode":
                                    handle_vscode_settings(sub_item, dest_file, rel_path, verbose, tracker)
                                else:
                                    shutil.copy2(sub_item, dest_file)
                    else:
                        # New directory - copy entire tree
                        shutil.copytree(item, dest_path)
                else:
                    # File - overwrite
                    if dest_path.exists() and verbose and not tracker:
                        console.print(f"[yellow]Overwriting file:[/yellow] {item.name}")
                    shutil.copy2(item, dest_path)
        else:
            # Clean extract mode - copy everything to project_path
            for item in staging_dir.iterdir():
                dest_path = project_path / item.name
                if item.is_dir():
                    shutil.copytree(item, dest_path)
                else:
                    shutil.copy2(item, dest_path)

    if tracker:
        tracker.update("Local templates copied", style="green")
    elif verbose:
        console.print("[green]✓[/green] Templates copied from local repository")

    return project_path


def _generate_command_from_template(
    template_path: Path,
    output_dir: Path,
    agent: str,
    script_variant: str,
    extension: str,
    arg_format: str,
    debug: bool = False
) -> None:
    """Generate an agent-specific command file from a template.

    This implements the same logic as create-release-packages.sh:40-102

    Args:
        template_path: Path to template markdown file
        output_dir: Directory to write generated command
        agent: Agent type (claude, gemini, etc.)
        script_variant: Script type (sh or ps)
        extension: Output file extension (md, toml, agent.md)
        arg_format: Argument placeholder ($ARGUMENTS or {{args}})
        debug: Show debug output
    """
    import re

    name = template_path.stem  # e.g., "research"
    content = template_path.read_text(encoding='utf-8')

    # Normalize line endings
    content = content.replace('\r\n', '\n').replace('\r', '\n')

    # Extract YAML frontmatter values
    description = ""
    script_command = ""
    agent_script_command = ""

    # Parse frontmatter
    lines = content.split('\n')
    in_frontmatter = False
    in_scripts = False
    in_agent_scripts = False

    for line in lines:
        if line.strip() == '---':
            if not in_frontmatter:
                in_frontmatter = True
            else:
                in_frontmatter = False
                break
            continue

        if not in_frontmatter:
            continue

        if line.startswith('description:'):
            description = line.split('description:', 1)[1].strip()
        elif line.strip() == 'scripts:':
            in_scripts = True
            in_agent_scripts = False
        elif line.strip() == 'agent_scripts:':
            in_agent_scripts = True
            in_scripts = False
        elif in_scripts and line.strip().startswith(f'{script_variant}:'):
            script_command = line.split(':', 1)[1].strip()
        elif in_agent_scripts and line.strip().startswith(f'{script_variant}:'):
            agent_script_command = line.split(':', 1)[1].strip()
        elif re.match(r'^[a-zA-Z]', line):
            in_scripts = False
            in_agent_scripts = False

    # Replace placeholders
    body = content
    if script_command:
        body = body.replace('{SCRIPT}', script_command)
    if agent_script_command:
        body = body.replace('{AGENT_SCRIPT}', agent_script_command)

    # Remove scripts: and agent_scripts: sections from frontmatter
    body_lines = body.split('\n')
    filtered_lines = []
    dash_count = 0
    in_fm = False
    skip_scripts = False

    for line in body_lines:
        if line.strip() == '---':
            filtered_lines.append(line)
            dash_count += 1
            if dash_count == 1:
                in_fm = True
            elif dash_count == 2:
                in_fm = False
            continue

        if in_fm and (line.strip() == 'scripts:' or line.strip() == 'agent_scripts:'):
            skip_scripts = True
            continue
        elif in_fm and re.match(r'^[a-zA-Z].*:', line) and skip_scripts:
            skip_scripts = False

        if in_fm and skip_scripts and re.match(r'^\s+', line):
            continue

        filtered_lines.append(line)

    body = '\n'.join(filtered_lines)

    # Apply other substitutions
    body = body.replace('{ARGS}', arg_format)
    body = body.replace('__AGENT__', agent)

    # Path rewrites (memory/ → .specify/memory/, etc.)
    body = re.sub(r'(/?)memory/', r'.specify/memory/', body)
    body = re.sub(r'(/?)scripts/', r'.specify/scripts/', body)
    body = re.sub(r'(/?)templates/', r'.specify/templates/', body)

    # Write output based on extension
    output_file = output_dir / f"speckit.{name}.{extension}"

    if extension == "toml":
        # Escape backslashes for TOML
        body_escaped = body.replace('\\', '\\\\')
        toml_content = f'description = "{description}"\n\nprompt = """\n{body_escaped}\n"""\n'
        output_file.write_text(toml_content, encoding='utf-8')
    else:
        output_file.write_text(body, encoding='utf-8')

    if debug:
        console.print(f"[dim]Generated: {output_file.name}[/dim]")
```

#### 4. Integrate Local Mode into Init Command

**File**: `src/specify_cli/__init__.py`

**After line 1095** - Add local mode handling before interactive selection:

```python
    # Handle local mode
    if local:
        local_repo_path = _detect_local_repo_path(local_repo_path)
        if not local_repo_path:
            console.print("[red]Error:[/red] Could not detect local spec-kit repository")
            console.print("Please run from within the spec-kit repository or use --local-repo-path")
            raise typer.Exit(1)

        if debug:
            console.print(f"[cyan]Local mode enabled:[/cyan] Using repository at {local_repo_path}")
```

**Replace line 1127** - Choose download vs local copy:

```python
    if local:
        copy_template_from_local(project_path, local_repo_path, selected_ai, selected_script, here, verbose=False, tracker=tracker, debug=debug)
    else:
        download_and_extract_template(project_path, selected_ai, selected_script, here, verbose=False, tracker=tracker, client=local_client, debug=debug, github_token=github_token, repo_owner=repo_owner, repo_name=repo_name)
```

### Success Criteria

#### Automated Verification:
- [x] CLI help shows local flag: `specify init --help | grep -E "(--local|--local-repo-path)"`
- [x] Local mode creates directory structure: Test with temporary project
- [x] Script permissions set correctly: `find .specify/scripts -name "*.sh" -executable | wc -l` > 0 (on Unix)
- [x] Commands generated: `ls .claude/commands/speckit.*.md | wc -l` matches template count
- [x] Import succeeds: `python -c "from specify_cli import copy_template_from_local"`

#### Manual Verification:
- [x] Local mode works from spec-kit root: `specify init --here --ai claude --script sh --local`
- [x] Local mode works with custom path: `specify init test --ai claude --script sh --local --local-repo-path /path/to/spec-kit`
- [x] Brownfield commands deployed: Verify `.claude/commands/speckit.research.md`, `.claude/commands/speckit.plan-brownfield.md`, `.claude/commands/speckit.handoff-create.md` exist
- [x] Path rewrites correct: Check that commands reference `.specify/memory/` not `memory/`
- [x] Merge mode works: Run `--here --local` in non-empty directory
- [ ] Performance is faster than download mode
- [ ] Generated commands match release package structure

**Implementation Note**: After completing this phase, test local mode thoroughly with all 17 agents to ensure command generation works correctly. Verify that brownfield-specific templates are included.

---

## Phase 3: Fork Release Automation

### Overview

Enable GitHub Actions to create releases on the fork's `fork-main` branch. The workflow is already fork-compatible; only the trigger branch needs updating.

### Changes Required

#### 1. Update Release Workflow Trigger

**File**: `.github/workflows/release.yml`

**Line 5** - Change trigger branch:

```yaml
on:
  push:
    branches: [ fork-main ]
    paths:
      - 'memory/**'
      - 'scripts/**'
      - 'templates/**'
      - '.github/workflows/**'
  workflow_dispatch:
```

**Alternative** - Support both branches (if merging back to upstream later):

```yaml
on:
  push:
    branches: [ main, fork-main ]
    paths:
      - 'memory/**'
      - 'scripts/**'
      - 'templates/**'
      - '.github/workflows/**'
  workflow_dispatch:
```

### Success Criteria

#### Automated Verification:
- [x] Workflow file is valid YAML: `yamllint .github/workflows/release.yml` (if yamllint installed)
- [ ] GitHub Actions validates workflow: Check via GitHub UI after pushing

#### Manual Verification:
- [ ] Push to `fork-main` triggers workflow: Make a small change to `templates/`, push, verify Actions tab shows run
- [ ] Release is created: Check Releases page for new version tag
- [ ] All 32 packages built: Verify release has `spec-kit-template-{agent}-{sh,ps}-v*.zip` files
- [ ] Brownfield commands included: Download a package, extract, verify brownfield commands exist
- [ ] Version auto-increment works: Check that version increments from previous tag
- [ ] Download from fork works: `specify init test --ai claude --script sh --repo-owner aloyxa1226 --repo-name spec-kit`

**Implementation Note**: This is the simplest phase but requires pushing to fork and waiting for GitHub Actions to complete. Test with a small change first (e.g., add a comment to a template) to verify the workflow triggers correctly.

---

## Phase 4: Create Handoff Command Templates

### Overview

Complete the brownfield workflow by creating handoff command templates. These templates will be adapted from existing `.claude/commands/create_handoff.md` and `.claude/commands/resume_handoff.md` to follow spec-kit conventions.

### Changes Required

#### 1. Create Handoff Creation Template

**File**: `templates/commands/handoff-create.md`

**Content** (adapted from `.claude/commands/create_handoff.md`):

```markdown
---
description: Create a handoff document to transfer work to another session
scripts:
  sh: scripts/bash/spec-metadata.sh
  ps: scripts/powershell/spec-metadata.ps1
---

# Create Brownfield Handoff Document

You are tasked with creating a **handoff document** to transfer work to another session or developer.

## Handoff Document Structure

Handoff documents capture:
1. **What was done** (changes made, with file:line references)
2. **What was learned** (discoveries, patterns, constraints)
3. **What's next** (action items, next steps)
4. **Critical context** (files that must be read to continue)

## Instructions

### 1. Filepath & Metadata

**Directory Structure**: Use `.specify/handoffs/` for spec-kit projects:

- **With ticket/task ID**: `.specify/handoffs/TICKET-ID/YYYY-MM-DD_HH-MM-SS_brownfield-description.md`
- **Without ticket**: `.specify/handoffs/YYYY-MM-DD_HH-MM-SS_brownfield-description.md`

**Metadata Collection**:
Run: `{SCRIPT}`

This outputs:
- Current date/time with timezone
- Git commit hash
- Branch name
- Repository name

**Filename Format**:
```
YYYY-MM-DD_HH-MM-SS_brownfield-description.md
```

Examples:
- `.specify/handoffs/PROJ-123/2025-12-12_14-30-45_brownfield-api-refactor.md`
- `.specify/handoffs/2025-12-12_14-30-45_brownfield-database-migration.md`

### 2. Write Handoff Document

Use the template at `.specify/templates/handoff-template.md` or this structure:

```markdown
---
date: [Date and time with timezone from metadata script]
researcher: Claude Code
git_commit: [Commit hash from metadata script]
branch: [Branch name from metadata script]
repository: [Repository name from metadata script]
topic: "[Brief task description]"
tags: [handoff, brownfield, component-names]
status: in_progress
last_updated: [YYYY-MM-DD]
last_updated_by: Claude Code
type: handoff
---

# Handoff: [Task] - [Brief Description]

## Task(s)

| Task | Status | Notes |
|------|--------|-------|
| [Task 1] | [completed/in_progress/planned] | [Notes] |

If working from a plan:
- **Plan**: `.specify/plans/YYYY-MM-DD-brownfield-description.md`
- **Current Phase**: [N]
- **Phase Status**: [description]

## Critical References

[2-3 most important files that must be read to continue]
- `path/to/critical/file.ext:45-67` - Why it's critical
- `path/to/another.ext:120-145` - Why it's critical

## Recent Changes

[Changes made in this session, with file:line references]
- `path/to/modified.ext:45-67` - What was changed and why
- `path/to/new-file.ext` - What was created

## Learnings

[Important discoveries that the next session should know]
- [Pattern discovered in codebase]
- [Root cause of issue found]
- [Important constraint or limitation]
- [Architectural decision made]

## Artifacts

[Files produced or updated in this session]
- `.specify/plans/YYYY-MM-DD-brownfield-description.md` - Implementation plan
- `.specify/research/YYYY-MM-DD-brownfield-description.md` - Research document
- `src/component/file.ext` - Modified file

## Action Items & Next Steps

1. [ ] [Next action item with enough detail to resume]
2. [ ] [Another action item]
3. [ ] [Future consideration or follow-up]

## Other Notes

[Additional context, references, or useful information]
- Links to relevant documentation
- Performance metrics or benchmarks
- Testing notes
- Deployment considerations
```

### 3. Key Guidelines

**Be Thorough But Concise**:
- Include more information rather than less
- Use file:line references instead of code snippets
- Provide both high-level context and low-level details

**Avoid Code Snippets**:
- Reference `file.ext:45-67` instead of pasting 20 lines
- Exception: Very short snippets (1-3 lines) that are critical to understanding

**Critical References**:
- List 2-3 **most important** files that must be read to continue
- Explain WHY each file is critical
- Use specific line ranges when possible

**Learnings Section**:
- Document discoveries about the codebase
- Include patterns, conventions, constraints
- Note architectural decisions or tradeoffs

**Action Items**:
- Make actionable and specific
- Provide enough detail to resume without context
- Prioritize by dependency and importance

**Brownfield Naming**:
- Always include "brownfield" in filename
- Use descriptive names: `brownfield-api-auth-refactor.md` not `brownfield-changes.md`

### 4. Response Template

After creating and saving the handoff document, respond with:

```
Handoff document created at:
`.specify/handoffs/[path]`

You can resume from this handoff in a new session with the `/speckit.handoff.resume` command, providing the path to this handoff document.

The handoff captures:
- [X] tasks with [N] completed, [M] in progress
- [N] critical files identified for context
- [N] key learnings documented
- [N] action items for next session
```

## Important Notes

- **Only create handoffs for brownfield work** (modifying existing codebases)
- **Run metadata script first** to collect git/branch/timestamp data
- **Use `.specify/` directory structure**, not `thoughts/` (greenfield convention)
- **Include "brownfield" in all filenames** for clarity
- **Focus on continuity** - provide everything needed to resume the work
- **Be precise with file references** - use file:line syntax consistently
```

#### 2. Create Handoff Resume Template

**File**: `templates/commands/handoff-resume.md`

**Content** (adapted from `.claude/commands/resume_handoff.md`):

```markdown
---
description: Resume work from a brownfield handoff document
scripts:
  sh: scripts/bash/spec-metadata.sh
  ps: scripts/powershell/spec-metadata.ps1
---

# Resume from Brownfield Handoff Document

You are tasked with resuming work from a **handoff document** created in a previous session.

## Three Invocation Modes

### Mode 1: With Handoff Path (Immediate)
User provides the full path to a handoff document:
```
/speckit.handoff.resume .specify/handoffs/PROJ-123/2025-12-12_14-30-45_brownfield-api-refactor.md
```

**Action**: Read the handoff immediately and proceed to Step 1.

### Mode 2: With Ticket/Task ID (Find Most Recent)
User provides just a ticket or task identifier:
```
/speckit.handoff.resume PROJ-123
```

**Action**:
1. Search `.specify/handoffs/PROJ-123/` for the most recent handoff file
2. Display found handoff and ask for confirmation
3. If confirmed, proceed to Step 1

### Mode 3: No Parameters (Prompt)
User invokes without parameters:
```
/speckit.handoff.resume
```

**Action**:
1. List available handoff directories in `.specify/handoffs/`
2. Ask user to specify which handoff to resume from
3. Once specified, proceed to Step 1

## Process Steps

### Step 1: Read and Analyze Handoff

1. **Read handoff document COMPLETELY**:
   - Use Read tool WITHOUT limit/offset parameters
   - Read the entire handoff into main context
   - DO NOT spawn sub-agents for this initial read

2. **Read all linked documents FULLY**:
   - If handoff references a plan: Read the complete plan
   - If handoff references research: Read the complete research document
   - Read any other artifacts mentioned
   - Again: NO sub-agents, read everything into main context

3. **Spawn focused research tasks IN PARALLEL**:
   Use Task tool with appropriate sub-agents to verify current state:

   - **codebase-locator**: Find files mentioned in "Critical References"
   - **codebase-analyzer**: Analyze current state of modified components
   - **Grep/Read**: Verify "Recent Changes" are still present
   - **Bash**: Run `git status` and `git log` to check repository state

   Focus these tasks on:
   - Verifying the changes mentioned in handoff still exist
   - Checking if any new changes have been made since handoff
   - Understanding current state vs. handoff state

4. **Wait for ALL sub-tasks to complete** before proceeding

5. **Read critical files identified**:
   - Read the 2-3 critical files mentioned in handoff
   - Read any files flagged by research tasks
   - Build complete context before presenting analysis

### Step 2: Synthesize and Present Analysis

Present a comprehensive analysis structured as:

```
## Handoff Analysis

**Handoff Created**: [Date/time from metadata]
**Branch**: [Branch name] | **Commit**: [Git commit hash]
**Topic**: [Task description]

**Task Status**:
- [X] tasks total
- [N] completed
- [M] in progress
- [K] planned

**Current Repository State**:
- Branch: [Current branch - compare to handoff]
- Latest commit: [Current HEAD - compare to handoff]
- Working directory: [Clean or modified]

**Validation**:
✓ [Changes from handoff still present]
✓ [Critical files exist and match description]
⚠️ [Any divergences found]

**Learnings from Handoff**:
1. [Key learning 1]
2. [Key learning 2]
3. [Key learning 3]

**Next Steps from Handoff**:
1. [ ] [Action item 1]
2. [ ] [Action item 2]
3. [ ] [Action item 3]

**Recommendation**: [Proceed with action items | Reconcile divergences first | Re-evaluate approach]

Ready to proceed?
```

### Step 3: Create Action Plan

Once user confirms, use TodoWrite to create a task list:

```markdown
**From Handoff Action Items**:
1. [ ] [Converted action item 1 with details]
2. [ ] [Converted action item 2 with details]
3. [ ] [Converted action item 3 with details]

**Additional Tasks** (if divergences found):
1. [ ] [Reconciliation task]
```

### Step 4: Begin Implementation

1. **Reference learnings throughout**:
   - Keep handoff learnings in mind while working
   - Follow patterns and conventions identified
   - Respect constraints documented

2. **Update progress**:
   - Mark todos as in_progress/completed
   - Update handoff document if making significant discoveries
   - Create new handoff when session ends

3. **Handle phase-based work**:
   - If resuming from a plan, check which phase was in progress
   - Read plan checkmarks to understand completion state
   - Resume at the correct phase

## Four Common Scenarios

### Scenario 1: Clean Continuation
- All changes from handoff are present
- No divergence from handoff state
- **Action**: Proceed with action items directly

### Scenario 2: Diverged Codebase
- Code has changed since handoff
- Working directory has uncommitted changes
- **Action**: Reconcile differences, verify handoff context still valid

### Scenario 3: Incomplete Handoff Work
- Some changes from handoff are missing
- Tasks marked "in progress" weren't completed
- **Action**: Complete unfinished work before new action items

### Scenario 4: Stale Handoff
- Handoff is old (weeks/months)
- Significant codebase evolution since creation
- **Action**: Re-evaluate approach, may need fresh research

## Important Guidelines

1. **Always read handoff FULLY into main context** - Do not delegate to sub-agents
2. **Verify before acting** - Don't assume handoff state matches current state
3. **Present analysis before implementing** - Get user confirmation
4. **Reference learnings** - Use discoveries from handoff to inform decisions
5. **Update handoff if needed** - Document new learnings as you work
6. **Create new handoff at session end** - Maintain continuity chain

## Brownfield Workflow Integration

Handoff documents are part of the brownfield workflow:

```
Research → Plan → Implement → Handoff → Resume → Implement → ...
```

When resuming from a handoff that references a plan:
1. Read both handoff AND plan completely
2. Verify which phase was in progress
3. Check plan for phase completion checkmarks
4. Resume at correct phase with handoff context

## Key Differences from Greenfield

- **Directory structure**: `.specify/handoffs/` not `thoughts/shared/handoffs/`
- **Metadata script**: Use `{SCRIPT}` from spec-kit
- **Naming convention**: Always include "brownfield" in filenames
- **Focus**: Continuity and state preservation over new feature planning

## Response After Completion

After implementing action items from handoff:

```
Completed handoff action items:
✓ [Action item 1]
✓ [Action item 2]
✓ [Action item 3]

[Summary of work done]

Would you like me to create a new handoff document to capture the current state?
```
```

### Success Criteria

#### Automated Verification:
- [x] Template files exist: `ls templates/commands/handoff-*.md | wc -l` equals 2
- [x] Templates have valid YAML: Check frontmatter is parseable
- [x] Templates reference correct scripts: Grep for `{SCRIPT}` placeholder

#### Manual Verification:
- [x] Local mode deploys handoff commands: `specify init test --ai claude --script sh --local`, verify `.claude/commands/speckit.handoff-create.md` and `.claude/commands/speckit.handoff-resume.md` exist
- [ ] Handoff create command works: Invoke in a test project, verify handoff created in `.specify/handoffs/`
- [ ] Handoff resume command works: Create a handoff, then resume from it in new session
- [ ] Brownfield naming enforced: Verify created handoffs include "brownfield" in filename
- [ ] Directory structure correct: Handoffs go to `.specify/handoffs/` not `thoughts/`
- [ ] Metadata script integration: Handoff includes git commit, branch, timestamp
- [ ] Three resume modes work: Test path, ticket ID, and no parameters
- [x] Commands follow spec-kit conventions: Path rewrites, placeholder substitutions correct

**Implementation Note**: After creating templates, test the full brownfield workflow end-to-end: research → plan → implement → handoff → resume. Verify handoff commands integrate properly with the brownfield planning and implementation commands.

---

## Testing Strategy

### Unit Tests

No existing test suite found. If tests are added later:
- Test `_repo_config()` precedence logic
- Test `_detect_local_repo_path()` with various directory structures
- Test `_generate_command_from_template()` YAML parsing and substitutions
- Mock filesystem operations for `copy_template_from_local()`

### Integration Tests

**End-to-End Workflow Tests**:
1. Fork download: Set env vars, run init, verify correct repo used
2. Local mode: Run from spec-kit repo, verify templates copied
3. Brownfield workflow: Research → plan → implement → handoff → resume
4. Release automation: Push to fork-main, wait for release, download package

### Manual Testing Steps

**Phase 1 - Repository Configuration**:
1. Default behavior: `specify init test1 --ai claude --script sh`
2. Environment variables: `SPEC_KIT_REPO_OWNER=aloyxa1226 specify init test2 --ai claude --script sh`
3. CLI flags: `specify init test3 --ai claude --script sh --repo-owner aloyxa1226`
4. Debug output: `specify init test4 --ai claude --script sh --debug --repo-owner test`
5. Version command: `specify version --repo-owner aloyxa1226`

**Phase 2 - Local Mode**:
1. From spec-kit root: `specify init --here --ai claude --script sh --local`
2. Custom path: `specify init test5 --ai claude --script sh --local --local-repo-path /path/to/spec-kit`
3. All agents: Test with `claude`, `gemini`, `copilot`, `cursor-agent`, etc.
4. Both script types: Test with `--script sh` and `--script ps`
5. Merge mode: Create non-empty dir, run `--here --local`, verify merge

**Phase 3 - Fork Release**:
1. Add comment to template file
2. Commit and push to `fork-main`
3. Check GitHub Actions tab for workflow run
4. Wait for release creation
5. Download package and inspect contents
6. Test download with `--repo-owner aloyxa1226`

**Phase 4 - Handoff Commands**:
1. Initialize project with local mode
2. Invoke `/speckit.handoff.create`, verify handoff created
3. Create another session, invoke `/speckit.handoff.resume` with path
4. Verify handoff resume loads context correctly
5. Test all three resume modes (path, ticket, no params)

## Performance Considerations

**Local Mode Performance**:
- **Expected**: 5-10x faster than download mode (no network I/O)
- **Optimization**: Use `shutil.copytree()` instead of file-by-file copying where possible
- **Trade-off**: Slightly more disk I/O but eliminates network latency

**Template Generation**:
- **Current**: Python-based generation may be slower than bash scripts
- **Acceptable**: Template generation is one-time per init, performance not critical
- **Future**: Could call bash script directly if performance becomes issue

**Fork Release Builds**:
- **Current**: 32 packages take ~3-5 minutes on GitHub Actions
- **No change**: Same build time as upstream releases
- **Consideration**: Could filter agents via `AGENTS` env var to speed up testing

## Migration Notes

**For Existing Fork Users**:

1. **Update environment**:
   ```bash
   export SPEC_KIT_REPO_OWNER=aloyxa1226
   export SPEC_KIT_REPO_NAME=spec-kit
   ```

2. **Or use CLI flags**:
   ```bash
   specify init --repo-owner aloyxa1226 --repo-name spec-kit
   ```

3. **For development**:
   ```bash
   cd /path/to/spec-kit
   specify init --here --ai claude --script sh --local
   ```

**For Upstream Users**:
- No changes required
- Default behavior unchanged (`github/spec-kit`)
- Fork-specific features opt-in only

**Backwards Compatibility**:
- All existing commands continue to work
- New flags are optional
- Environment variables are optional
- Default values preserve original behavior

## References

- Original research: `thoughts/shared/research/2025-12-12-brownfield-cli-deployment-investigation.md`
- Brownfield implementation plan: `thoughts/shared/plans/2025-12-11-extending-spec-kit-brownfield.md`
- Brownfield research: `thoughts/shared/research/2025-12-11-extending-spec-kit-for-brownfield.md`
- CLI source: `src/specify_cli/__init__.py:637-749` (download function)
- Release script: `.github/workflows/scripts/create-release-packages.sh:40-102` (command generation)
- Handoff references: `.claude/commands/create_handoff.md`, `.claude/commands/resume_handoff.md`
