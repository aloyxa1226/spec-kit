---
date: 2025-12-11 20:12:55 PST
researcher: Claude Code
git_commit: 3ee4101c5670479376e46d6551ed10508ce8e2ad
branch: fork-main
repository: spec-kit
topic: "Extending spec-kit for brownfield applications using humanlayer patterns"
tags: [research, codebase, brownfield, greenfield, constitutional, linear, sdd]
status: complete
last_updated: 2025-12-11
last_updated_by: Claude Code
last_updated_note: "Added design decisions based on stakeholder feedback"
---

# Research: Extending spec-kit for Brownfield Applications

**Date**: 2025-12-11 20:12:55 PST
**Researcher**: Claude Code
**Git Commit**: 3ee4101c5670479376e46d6551ed10508ce8e2ad
**Branch**: fork-main
**Repository**: spec-kit

## Research Question

How can spec-kit be extended to support brownfield applications by incorporating the research, plan, and implement phases from humanlayer, while maintaining the Constitutional approach and adding Linear workflow integration?

## Summary

Spec-kit currently excels at **greenfield development** through its Spec-Driven Development (SDD) methodology, which inverts the traditional relationship between specifications and code. The toolkit provides comprehensive prompts, templates, scripts, and workflows for building software from scratch.

The humanlayer project (referenced in `.claude/` and `hack/` folders) implements a sophisticated **brownfield development workflow** with three distinct phases: **Research → Plan → Implement**. This workflow emphasizes understanding existing codebases before making changes, uses parallel sub-agents for efficiency, and integrates deeply with Linear for ticket-based workflow management.

To extend spec-kit for brownfield applications, we need to:
1. Add codebase research capabilities (parallel sub-agents)
2. Create brownfield-specific planning templates
3. Adapt the Constitutional approach for existing codebases
4. Integrate Linear workflow management

## Detailed Findings

### Current Spec-Kit Architecture (Greenfield Focus)

#### Core Philosophy: Spec-Driven Development

Spec-kit implements a "power inversion" where specifications become the **source of truth** and code is the generated output. The methodology emphasizes:
- Specifications as executable artifacts
- Intent-driven development from natural language
- Constitutional principles as governance
- Template-driven quality constraints

#### Workflow Structure (6 Steps + Optional)

| Step | Command | Purpose |
|------|---------|---------|
| 1 | `/speckit.constitution` | Establish project principles |
| 2 | `/speckit.specify` | Create feature specification |
| 3 | `/speckit.clarify` | Resolve ambiguities (optional) |
| 4 | `/speckit.plan` | Technical implementation plan |
| 5 | `/speckit.tasks` | Break into executable tasks |
| 6 | `/speckit.implement` | Execute implementation |
| Bonus | `/speckit.analyze` | Cross-artifact consistency analysis |
| Bonus | `/speckit.checklist` | Domain-specific quality validation |

#### Directory Structure

```
project-root/
├── .specify/
│   ├── memory/
│   │   └── constitution.md          # Project principles
│   ├── specs/
│   │   └── 001-feature-name/
│   │       ├── spec.md              # Feature specification
│   │       ├── plan.md              # Implementation plan
│   │       ├── research.md          # Technology decisions
│   │       ├── data-model.md        # Entity definitions
│   │       ├── contracts/           # API specifications
│   │       ├── quickstart.md        # Validation scenarios
│   │       └── tasks.md             # Execution plan
│   ├── scripts/                     # Automation scripts
│   └── templates/                   # Document templates
├── src/                             # Implementation
└── .claude/                         # Agent commands
```

#### Constitutional Approach (Existing)

The Constitutional approach is already well-established in spec-kit through:

**Constitution Template** (`memory/constitution.md`):
- Versioned principles (MAJOR.MINOR.PATCH)
- Non-negotiable rules (e.g., Test-First Imperative)
- Amendment process with rationale requirements

**Constitutional Gates** (`templates/plan-template.md`):
- Simplicity Gate (≤3 projects)
- Anti-Abstraction Gate (use framework directly)
- Integration-First Gate (contract tests required)

**Enforcement Points**:
- `/speckit.plan`: Validates against constitution before Phase 0
- `/speckit.analyze`: Constitution conflicts = CRITICAL severity
- `/speckit.specify`: Marks ambiguities for resolution

---

### Humanlayer Brownfield Architecture (Reference Implementation)

#### Core Philosophy: Research-First Development

Humanlayer implements an **interactive, research-driven workflow** where understanding the existing codebase is mandatory before any changes. Key principles:
- Research phase is non-negotiable
- Plan review happens BEFORE code (not at PR stage)
- Parallel sub-agents maximize efficiency
- Documentation-first mindset (describe, don't critique)
- Session continuity through handoff documents

#### Three-Phase Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    RESEARCH PHASE                            │
│  - Read directly mentioned files FULLY                       │
│  - Spawn parallel sub-agents (locator, analyzer, pattern-finder) │
│  - Document findings in thoughts/shared/research/            │
│  - DO NOT suggest improvements - only document               │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     PLAN PHASE                               │
│  - Create initial understanding                              │
│  - Get user feedback on correctness                          │
│  - Research any corrections                                  │
│  - Write detailed plan with phases                           │
│  - Separate automated vs manual verification                 │
│  - NO open questions in final plan                           │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   IMPLEMENT PHASE                            │
│  - Read plan completely                                      │
│  - Check existing checkmarks (resume if partial)             │
│  - Implement phase by phase                                  │
│  - Run automated verification after each phase               │
│  - PAUSE for manual verification                             │
│  - Update checkboxes in plan                                 │
│  - Handle mismatches by stopping and presenting issue        │
└─────────────────────────────────────────────────────────────┘
```

#### Specialized Sub-Agents

| Agent | Tools | Purpose |
|-------|-------|---------|
| `codebase-locator` | Grep, Glob, LS | Find WHERE code lives |
| `codebase-analyzer` | Read, Grep, Glob, LS | Understand HOW code works |
| `codebase-pattern-finder` | Grep, Glob, Read, LS | Find similar patterns |
| `thoughts-locator` | Grep, Glob, LS | Find existing documentation |
| `thoughts-analyzer` | Read, Grep, Glob, LS | Extract insights from docs |
| `web-search-researcher` | WebSearch, WebFetch, TodoWrite, Read, Grep, Glob, LS | Research external info |

**Key Agent Principle**: "You are a documentarian, not a critic" - agents describe what exists without suggesting improvements.

#### Linear Workflow Integration

**Status Progression**:
```
Triage → Spec Needed → Research Needed → Research in Progress → Research in Review
→ Ready for Plan → Plan in Progress → Plan in Review → Ready for Dev
→ In Dev → Code Review → Done
```

**Key Innovation**: Review and alignment happen at the **plan stage** (not PR stage) to move faster and avoid rework.

**Automated Commands**:
- `/ralph_research`: Auto-pick highest priority "research needed" ticket
- `/ralph_plan`: Auto-pick highest priority "ready for spec" ticket
- `/ralph_impl`: Auto-pick highest priority "ready for dev" ticket
- `/oneshot_plan`: Research + plan in one command

#### Supporting Infrastructure

**Worktree Management** (`hack/create_worktree.sh`):
- Isolated git worktrees per ticket
- Copies `.claude/` configuration
- Runs `make setup` validation
- Initializes thoughts system

**Linear CLI** (`hack/linear/linear-cli.ts`):
- Git branch integration (extracts ticket ID from branch name)
- Image fetching from Linear attachments
- Status updates and comment management
- Assignment and link management

**Metadata Collection** (`hack/spec_metadata.sh`):
- Date/time with timezone
- Git commit and branch
- Repository name
- Thoughts system status

#### Document Storage Conventions

```
thoughts/
├── shared/
│   ├── tickets/          # Linear ticket exports
│   │   └── ENG-XXXX.md
│   ├── research/         # Research documents
│   │   └── YYYY-MM-DD-ENG-XXXX-description.md
│   ├── plans/            # Implementation plans
│   │   └── YYYY-MM-DD-ENG-XXXX-description.md
│   ├── handoffs/         # Session continuity
│   │   └── ENG-XXXX/
│   │       └── YYYY-MM-DD_HH-MM-SS_ENG-XXXX_description.md
│   └── images/           # Downloaded images
│       └── ENG-XXXX/
└── local/                # Personal notes (not shared)
```

---

### Gap Analysis: Greenfield vs Brownfield

| Capability | Spec-Kit (Greenfield) | Humanlayer (Brownfield) |
|------------|----------------------|-------------------------|
| Starting Point | Natural language description | Existing codebase + ticket |
| Research | Technology options only | Deep codebase analysis |
| Sub-Agents | Not used | Parallel specialized agents |
| Constitution | Project-wide principles | N/A (opportunity!) |
| Linear Integration | None | Deep workflow integration |
| Session Continuity | N/A | Handoff documents |
| Worktree Isolation | N/A | Per-ticket worktrees |
| Verification | Post-implementation | Phase-by-phase with pause |

---

## Architecture Insights: Extension Strategy

### 1. Constitutional Approach for Brownfield

The Constitutional approach can be adapted for brownfield development by:

**Research Phase Constitutional Principles**:
```markdown
### Article I: Documentation-First Research
All codebase research MUST describe what exists without critique.
No research shall suggest improvements - only document current state.

### Article II: Full-File Reading Mandate
Files MUST be read completely without limit/offset parameters.
No partial file reading shall be used during research.

### Article III: Parallel Agent Efficiency
Research tasks MUST spawn multiple sub-agents concurrently.
No sequential agent execution when parallelization is possible.
```

**Planning Phase Constitutional Principles**:
```markdown
### Article IV: Plan-Before-Code Imperative
Implementation plans MUST be reviewed and approved before coding.
No code shall be written without an approved plan.

### Article V: Open Questions Prohibition
Final plans MUST have zero unresolved questions.
Any open questions MUST be resolved before plan approval.

### Article VI: Verification Separation
Plans MUST separate automated and manual verification criteria.
No mixing of verification types within success criteria sections.
```

**Implementation Phase Constitutional Principles**:
```markdown
### Article VII: Phase-Gate Verification
Each implementation phase MUST pass automated verification before proceeding.
Manual verification MUST occur before starting subsequent phases.

### Article VIII: Mismatch Transparency
Any plan-reality mismatch MUST be presented to the user immediately.
No silent deviation from approved plans.
```

### 2. New Commands for Brownfield Support

**Research Commands**:
- `/speckit.research` - Interactive codebase research
- `/speckit.research.ticket <id>` - Research for specific ticket
- `/speckit.research.auto` - Auto-pick highest priority research ticket

**Planning Commands** (brownfield variants):
- `/speckit.plan.brownfield` - Plan for existing codebase changes
- `/speckit.plan.iterate` - Update existing plan based on feedback

**Implementation Commands**:
- `/speckit.implement.plan <path>` - Execute approved plan
- `/speckit.implement.validate` - Verify implementation against plan

**Linear Integration**:
- `/speckit.linear` - Ticket management interface
- `/speckit.linear.sync` - Sync ticket to local file

**Session Management**:
- `/speckit.handoff.create` - Create handoff document
- `/speckit.handoff.resume` - Resume from handoff

### 3. New Templates Required

**Research Document Template**:
```markdown
---
date: [ISO format with timezone]
researcher: [Name]
git_commit: [Hash]
branch: [Branch]
repository: [Repo]
topic: "[Topic]"
tags: [research, component-names]
status: complete
---

# Research: [Topic]

## Research Question

## Summary

## Detailed Findings
### [Component 1]
- Finding with reference (file.ext:line)

## Code References

## Architecture Documentation

## Historical Context

## Open Questions
```

**Brownfield Plan Template**:
```markdown
# [Feature/Task Name] Implementation Plan

## Overview

## Current State Analysis
[What exists now, constraints discovered]

## Desired End State

## Implementation Approach

## Phase N: [Descriptive Name]

### Changes Required:
#### 1. [Component/File Group]
**File**: path/to/file.ext
**Changes**: [Summary]

### Success Criteria:

#### Automated Verification:
- [ ] Tests pass: `make test`
- [ ] Type checking: `npm run typecheck`

#### Manual Verification:
- [ ] Feature works when tested via UI

**Implementation Note**: Pause here for manual confirmation before next phase.

## Testing Strategy

## Performance Considerations

## Migration Notes
```

**Handoff Document Template**:
```markdown
---
[YAML frontmatter]
---

# Handoff: [Ticket] {description}

## Task(s)
{tasks with status}

## Critical References
{important file paths}

## Recent Changes
{file:line syntax}

## Learnings
{discoveries, patterns}

## Artifacts
{produced/updated files}

## Action Items & Next Steps
```

### 4. New Agent Definitions

Create agent definitions in `.claude/agents/` (or equivalent):

```markdown
# codebase-locator.md
Model: sonnet
Tools: Grep, Glob, LS
Purpose: Find WHERE code lives for specific features

# codebase-analyzer.md
Model: sonnet
Tools: Read, Grep, Glob, LS
Purpose: Understand HOW code works

# codebase-pattern-finder.md
Model: sonnet
Tools: Grep, Glob, Read, LS
Purpose: Find similar implementations and patterns
```

### 5. Infrastructure Scripts

**Required Scripts**:
- `scripts/bash/create-worktree.sh` - Worktree management
- `scripts/bash/cleanup-worktree.sh` - Worktree cleanup
- `scripts/bash/spec-metadata.sh` - Metadata collection

**Optional Linear Integration**:
- `scripts/linear/linear-cli.ts` - Linear CLI wrapper
- `scripts/linear/package.json` - Dependencies

### 6. Directory Structure Extension

```
project-root/
├── .specify/
│   ├── memory/
│   │   └── constitution.md         # Extended with Part II (brownfield principles)
│   ├── specs/                      # Greenfield specs (existing)
│   │   └── 001-feature-name/
│   ├── research/                   # Brownfield research (NEW)
│   │   └── YYYY-MM-DD-description.md
│   ├── plans/                      # Brownfield plans (NEW)
│   │   └── YYYY-MM-DD-description.md
│   ├── handoffs/                   # Session continuity (NEW)
│   │   └── TICKET/
│   │       └── YYYY-MM-DD_HH-MM-SS_description.md
│   └── tickets/                    # Ticket exports (NEW, optional - for Linear/Jira/etc)
│       └── TICKET.md
├── templates/
│   ├── commands/
│   │   ├── research.md             # Core research command (NEW)
│   │   └── research-parallel.md    # Parallel pattern (NEW)
│   ├── agents/                     # Sub-agent definitions (NEW)
│   │   ├── codebase-locator.md
│   │   ├── codebase-analyzer.md
│   │   └── codebase-pattern-finder.md
│   ├── research-template.md        # Research document template (NEW)
│   ├── plan-brownfield-template.md # Brownfield plan template (NEW)
│   └── handoff-template.md         # Handoff document template (NEW)
├── scripts/
│   ├── bash/
│   │   ├── create-worktree.sh      # Worktree management (NEW, optional)
│   │   ├── cleanup-worktree.sh     # Worktree cleanup (NEW, optional)
│   │   └── spec-metadata.sh        # Metadata collection (NEW)
│   ├── powershell/
│   │   ├── create-worktree.ps1     # Windows variant (NEW, optional)
│   │   └── spec-metadata.ps1       # Windows variant (NEW)
│   └── linear/                     # Linear integration (OPTIONAL, deferred)
│       └── linear-cli.ts
└── .claude/
    ├── commands/
    │   └── speckit.research.md     # Claude-optimized research (NEW)
    └── agents/                     # Claude sub-agent definitions (NEW)
        ├── codebase-locator.md
        ├── codebase-analyzer.md
        └── codebase-pattern-finder.md
```

---

## Implementation Roadmap

### Phase 1: Core Research Capabilities
1. Create sub-agent definitions in `templates/agents/` (locator, analyzer, pattern-finder)
2. Create research document template (`templates/research-template.md`)
3. Implement core `/speckit.research` command (`templates/commands/research.md`)
4. Create Claude-optimized variant (`.claude/commands/speckit.research.md`)
5. Add metadata collection script (`scripts/bash/spec-metadata.sh`)

### Phase 2: Brownfield Planning
1. Create brownfield plan template with phase gates (`templates/plan-brownfield-template.md`)
2. Implement `/speckit.plan.brownfield` command (core + agent-optimized)
3. Add verification separation (automated vs manual) to templates
4. Implement `/speckit.plan.iterate` command for plan updates

### Phase 3: Implementation Support
1. Implement `/speckit.implement.plan` command
2. Add phase-by-phase verification with pause pattern
3. Implement `/speckit.implement.validate` command
4. Create handoff document template (`templates/handoff-template.md`)
5. Implement `/speckit.handoff.create` and `/speckit.handoff.resume` commands

### Phase 4: Linear Integration (OPTIONAL - Deferred)
> **Note**: This phase is optional and can be deferred. Core brownfield workflow works without it.

1. Port Linear CLI to `scripts/linear/` directory
2. Create `/speckit.linear` command for ticket management
3. Implement automated workflow commands (ralph-style)
4. Add worktree management scripts (`scripts/bash/create-worktree.sh`)

### Phase 5: Constitutional Extension (Unified Approach)
1. Extend constitution template with Part II (Development Process Principles)
2. Add brownfield constitutional gates to plan-brownfield template
3. Update `/speckit.analyze` for brownfield validation
4. Document the unified Constitutional approach in `spec-driven.md`
5. Update CLI to support brownfield initialization

---

## Code References

### Spec-Kit Core Files
- `spec-driven.md` - Complete SDD methodology (25KB)
- `templates/spec-template.md` - Feature specification template
- `templates/plan-template.md` - Implementation plan template (with gates)
- `templates/tasks-template.md` - Task breakdown template
- `templates/commands/constitution.md` - Constitution workflow
- `templates/commands/plan.md` - Planning workflow
- `templates/commands/implement.md` - Implementation workflow
- `memory/constitution.md` - Constitution template

### Humanlayer Reference Files
- `.claude/commands/research_codebase.md` - Research workflow
- `.claude/commands/create_plan.md` - Planning workflow
- `.claude/commands/implement_plan.md` - Implementation workflow
- `.claude/commands/linear.md` - Linear integration (389 lines)
- `.claude/agents/codebase-locator.md` - Locator agent
- `.claude/agents/codebase-analyzer.md` - Analyzer agent
- `.claude/agents/codebase-pattern-finder.md` - Pattern finder agent
- `hack/create_worktree.sh` - Worktree management (148 lines)
- `hack/linear/linear-cli.ts` - Linear CLI (1,314 lines)
- `hack/spec_metadata.sh` - Metadata collection (36 lines)

---

## Design Decisions

The following decisions were made based on stakeholder feedback and analysis:

### Decision 1: Constitution Unification

**Decision**: Unified Constitution with Distinct Sections

**Rationale**:
- Greenfield principles govern *what* you build (library-first, test-first, simplicity)
- Brownfield principles govern *how* you work (research-first, plan-before-code, phase gates)
- These are complementary concerns, not competing ones
- Most real-world projects are **hybrid** (new features in existing codebases) - both parts apply

**Implementation**:
```markdown
# Project Constitution v1.0.0

## Part I: Project Architecture Principles
[Existing greenfield principles - customizable per project]
- Library-First, CLI Interface, Test-First, etc.

## Part II: Development Process Principles
[Brownfield methodology - more universal]
- Research-First, Plan-Before-Code, Phase Gates, etc.

## Governance
[Unified amendment process]
```

**Benefits**:
- Single source of truth (no drift between files)
- Clear relationship between project design & process
- One versioning scheme
- Works for hybrid projects
- Constitutional gates in plan templates can reference either section

---

### Decision 2: Linear Integration

**Decision**: Optional Extension (Deferred)

**Rationale**:
- Linear integration adds complexity and external dependency
- Core brownfield workflow (research → plan → implement) can work without ticket management
- Users may prefer different ticket systems (Jira, GitHub Issues, etc.)

**Implementation**:
- Phase 4 of the roadmap is marked as optional
- Linear CLI and integration commands are in a separate `scripts/linear/` directory
- Core workflow commands work independently of Linear

---

### Decision 3: Directory Structure

**Decision**: Adapt to `.specify/` Directory Pattern

**Rationale**:
- Maintains consistency with existing spec-kit conventions
- `.specify/` is already established as the spec-kit workspace
- Avoids introducing a new top-level directory pattern

**Implementation**:
```
.specify/
├── memory/
│   └── constitution.md         # Extended for brownfield
├── specs/                      # Greenfield specs (existing)
├── research/                   # Brownfield research (NEW)
│   └── YYYY-MM-DD-description.md
├── plans/                      # Brownfield plans (NEW)
│   └── YYYY-MM-DD-description.md
├── handoffs/                   # Session continuity (NEW)
│   └── TICKET/
└── tickets/                    # Ticket exports (NEW, optional)
    └── TICKET.md
```

---

### Decision 4: Agent Framework

**Decision**: Layered Approach with Agent-Specific Optimizations

**Rationale**:
- Maintains spec-kit's agent-agnostic core philosophy
- Powerful agents (Claude Code) get full sub-agent capabilities
- Less capable agents still work (just with sequential execution)
- Follows existing spec-kit pattern of agent-specific command folders

**Implementation**:
```
┌─────────────────────────────────────────────────────┐
│  Layer 3: Agent-Optimized Commands                  │
│  .claude/commands/research.md (uses Task sub-agents)│
│  .gemini/commands/research.md (uses Gemini's tools) │
└─────────────────────────────────────────────────────┘
                        ▲
                        │ extends
┌─────────────────────────────────────────────────────┐
│  Layer 2: Enhanced Templates                        │
│  templates/commands/research-parallel.md            │
│  (pattern for agents that support parallelism)      │
└─────────────────────────────────────────────────────┘
                        ▲
                        │ extends
┌─────────────────────────────────────────────────────┐
│  Layer 1: Core Templates (Agent-Agnostic)           │
│  templates/commands/research.md                     │
│  (works with any agent, sequential execution)       │
└─────────────────────────────────────────────────────┘
```

**Structure**:
```
templates/
├── commands/
│   ├── research.md              # Core (any agent)
│   └── research-parallel.md     # Pattern for parallel-capable
├── agents/                      # Sub-agent definitions (portable)
│   ├── codebase-locator.md
│   ├── codebase-analyzer.md
│   └── codebase-pattern-finder.md

.claude/commands/
├── speckit.research.md          # Claude-optimized (uses Task tool)
```

---

### Decision 5: Worktree Management

**Decision**: User's Choice (Optional Flag)

**Rationale**:
- Per-ticket worktree isolation provides better isolation for complex changes
- Branch-based development is simpler and sufficient for many workflows
- Users should decide based on their project complexity and team size

**Implementation**:
- Worktree scripts provided in `scripts/bash/create-worktree.sh`
- Commands accept `--worktree` flag to enable worktree isolation
- Default behavior is branch-based development
- Documentation explains trade-offs to help users decide

**Worktree Benefits**:
- Complete isolation between concurrent work items
- Easier context switching
- No stash/unstash needed

**Branch-Based Benefits**:
- Simpler mental model
- No disk space overhead
- Faster for quick changes

---

## Decision Summary

| Question | Decision | Implementation Impact |
|----------|----------|----------------------|
| Constitution | Unified with sections | Extend `memory/constitution.md` template |
| Linear | Optional, deferred | Phase 4 marked optional |
| Directory | Adapt to `.specify/` | Use `.specify/research/`, `.specify/plans/` |
| Agent Framework | Layered approach | Core templates + agent-specific optimizations |
| Worktree | User's choice | `--worktree` flag on commands |

---

## Related Research

- This is the initial research document for brownfield extension
- Future research may cover specific implementation phases

## References

- [spec-driven.md](spec-driven.md) - Spec-Driven Development methodology
- [README.md](README.md) - Spec-kit overview and quick start
- Humanlayer project (private) - Reference implementation for brownfield workflows
