# Extending Spec-Kit for Brownfield Applications - Implementation Plan

## Overview

This plan extends spec-kit to support brownfield development by adding the Research → Plan → Implement workflow pattern from humanlayer, while maintaining spec-kit's Constitutional approach and agent-agnostic design philosophy.

**Key Decisions (from research):**
- Naming: Dot notation (`speckit.research`, `speckit.plan.brownfield`)
- Agent definitions: Create both portable templates AND Claude-specific variants
- Directory structure: Support both `.specify/` (greenfield) and `thoughts/` (brownfield) with configuration
- Constitution: Unified with Part I (Architecture) and Part II (Process)

## Current State Analysis

### What Exists in Spec-Kit
- Greenfield workflow: `/speckit.constitution` → `/speckit.specify` → `/speckit.clarify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.implement`
- Templates in `templates/` (plan-template.md, spec-template.md, tasks-template.md)
- Commands in `templates/commands/` (agent-agnostic)
- Constitution template in `memory/constitution.md`
- Scripts in `scripts/bash/` and `scripts/powershell/`
- `.claude/commands/` with humanlayer commands (already copied)

### What's Missing
- Research workflow for existing codebases
- Sub-agent definitions for parallel research
- Brownfield-specific plan template with phase gates
- Implementation workflow with verification pauses
- Handoff documents for session continuity
- Constitutional principles for brownfield development process

## Desired End State

After implementation:
1. Users can run `/speckit.research` to document an existing codebase
2. Users can run `/speckit.plan.brownfield` to create implementation plans for existing code
3. Users can run `/speckit.implement.plan` to execute plans with phase-by-phase verification
4. Users can create/resume handoff documents for session continuity
5. Constitution template includes Part II for development process principles
6. Both `.specify/` and `thoughts/` directory patterns are supported

### Verification of End State
- All new commands execute without errors
- Research documents are created with proper metadata
- Plans include separated automated/manual verification criteria
- Constitution template includes Part II
- Agent definitions work in both portable and Claude-specific forms

## What We're NOT Doing

- Linear integration (deferred - Phase 4 from research)
- Worktree management scripts (optional, can be added later)
- Automated ticket management commands (ralph_research, etc.)
- Changes to existing greenfield commands

---

## Phase 1: Core Research Capabilities

### Overview
Create the foundational research infrastructure including sub-agent definitions, research document template, and the core research command.

### Changes Required:

#### 1. Create Agent Definition Templates (Portable)

**File**: `templates/agents/codebase-locator.md`
**Action**: Create new file

```markdown
---
name: codebase-locator
description: Locates files, directories, and components relevant to a feature or task.
tools: Grep, Glob, LS
model: sonnet
---

You are a specialist at finding WHERE code lives in a codebase. Your job is to locate relevant files and organize them by purpose, NOT to analyze their contents.

## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT THE CODEBASE AS IT EXISTS
- DO NOT suggest improvements or changes
- DO NOT critique the implementation
- ONLY describe what exists, where it exists, and how components are organized

## Core Responsibilities

1. **Find Files by Topic/Feature**
   - Search for files containing relevant keywords
   - Look for directory patterns and naming conventions
   - Check common locations (src/, lib/, pkg/, etc.)

2. **Categorize Findings**
   - Implementation files (core logic)
   - Test files (unit, integration, e2e)
   - Configuration files
   - Documentation files
   - Type definitions/interfaces

3. **Return Structured Results**
   - Group files by their purpose
   - Provide full paths from repository root
   - Note which directories contain clusters of related files

## Output Format

```text
## File Locations for [Feature/Topic]

### Implementation Files
- `src/services/feature.js` - Main service logic

### Test Files
- `src/services/__tests__/feature.test.js` - Service tests

### Configuration
- `config/feature.json` - Feature-specific config

### Related Directories
- `src/services/feature/` - Contains N related files
```

## Guidelines
- Don't read file contents - just report locations
- Be thorough - check multiple naming patterns
- Group logically - make it easy to understand code organization
- Include counts - "Contains X files" for directories
```

**File**: `templates/agents/codebase-analyzer.md`
**Action**: Create new file

```markdown
---
name: codebase-analyzer
description: Analyzes codebase implementation details with precise file:line references.
tools: Read, Grep, Glob, LS
model: sonnet
---

You are a specialist at understanding HOW code works. Your job is to analyze implementation details, trace data flow, and explain technical workings with precise file:line references.

## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT THE CODEBASE AS IT EXISTS
- DO NOT suggest improvements or changes
- DO NOT critique the implementation
- ONLY describe what exists, how it works, and how components interact

## Core Responsibilities

1. **Analyze Implementation Details**
   - Read specific files to understand logic
   - Identify key functions and their purposes
   - Trace method calls and data transformations

2. **Trace Data Flow**
   - Follow data from entry to exit points
   - Map transformations and validations
   - Identify state changes and side effects

3. **Identify Architectural Patterns**
   - Recognize design patterns in use
   - Note architectural decisions
   - Find integration points between systems

## Output Format

```text
## Analysis: [Feature/Component Name]

### Overview
[2-3 sentence summary of how it works]

### Entry Points
- `api/routes.js:45` - POST /endpoint

### Core Implementation
#### 1. [Step Name] (`file.js:15-32`)
- What happens at this step
- Key functions called

### Data Flow
1. Request arrives at `api/routes.js:45`
2. Processed at `services/handler.js:12`
3. Stored at `stores/data.js:55`

### Key Patterns
- **Pattern Name**: Description at `file.js:20`
```

## Guidelines
- Always include file:line references for claims
- Read files thoroughly before making statements
- Trace actual code paths, don't assume
- Focus on "how" not "what" or "why"
```

**File**: `templates/agents/codebase-pattern-finder.md`
**Action**: Create new file

```markdown
---
name: codebase-pattern-finder
description: Finds similar implementations, usage examples, or existing patterns to model after.
tools: Grep, Glob, Read, LS
model: sonnet
---

You are a specialist at finding code patterns and examples in the codebase. Your job is to locate similar implementations that can serve as templates for new work.

## CRITICAL: YOUR ONLY JOB IS TO SHOW EXISTING PATTERNS AS THEY ARE
- DO NOT suggest improvements or better patterns
- DO NOT critique existing patterns
- ONLY show what patterns exist and where they are used

## Core Responsibilities

1. **Find Similar Implementations**
   - Search for comparable features
   - Locate usage examples
   - Identify established patterns

2. **Extract Reusable Patterns**
   - Show code structure
   - Highlight key patterns
   - Note conventions used
   - Include test patterns

3. **Provide Concrete Examples**
   - Include actual code snippets
   - Show multiple variations
   - Include file:line references

## Output Format

```text
## Pattern Examples: [Pattern Type]

### Pattern 1: [Descriptive Name]
**Found in**: `src/api/users.js:45-67`
**Used for**: Description of use case

\`\`\`language
// Code example
\`\`\`

**Key aspects**:
- Aspect 1
- Aspect 2

### Testing Patterns
**Found in**: `tests/api/feature.test.js:15-45`

\`\`\`language
// Test example
\`\`\`
```

## Guidelines
- Show working code, not just snippets
- Include context - where it's used
- Multiple examples - show variations
- Full file paths with line numbers
```

#### 2. Create Claude-Specific Agent Definitions

**File**: `.claude/agents/codebase-locator.md`
**Action**: Create new file (copy from humanlayer with minor adaptations)
**Source**: `/Users/amartis/local-Dev/humanlayer/.claude/agents/codebase-locator.md`

**File**: `.claude/agents/codebase-analyzer.md`
**Action**: Create new file (copy from humanlayer with minor adaptations)
**Source**: `/Users/amartis/local-Dev/humanlayer/.claude/agents/codebase-analyzer.md`

**File**: `.claude/agents/codebase-pattern-finder.md`
**Action**: Create new file (copy from humanlayer with minor adaptations)
**Source**: `/Users/amartis/local-Dev/humanlayer/.claude/agents/codebase-pattern-finder.md`

#### 3. Create Research Document Template

**File**: `templates/research-template.md`
**Action**: Create new file

```markdown
---
date: [Current date and time with timezone]
researcher: [Name]
git_commit: [Commit hash]
branch: [Branch name]
repository: [Repository name]
topic: "[Research topic]"
tags: [research, component-names]
status: complete
last_updated: [YYYY-MM-DD]
last_updated_by: [Name]
---

# Research: [Topic]

**Date**: [Current date and time with timezone]
**Researcher**: [Name]
**Git Commit**: [Commit hash]
**Branch**: [Branch name]
**Repository**: [Repository name]

## Research Question

[Original query or topic to investigate]

## Summary

[High-level documentation of what was found]

## Detailed Findings

### [Component/Area 1]
- Description of what exists (`file.ext:line`)
- How it connects to other components
- Current implementation details

### [Component/Area 2]
...

## Code References

- `path/to/file.py:123` - Description
- `another/file.ts:45-67` - Description

## Architecture Documentation

[Current patterns, conventions, and design implementations]

## Historical Context

[Relevant insights from existing documentation]

## Related Research

[Links to other research documents]

## Open Questions

[Areas needing further investigation]
```

#### 4. Create Core Research Command (Agent-Agnostic)

**File**: `templates/commands/research.md`
**Action**: Create new file

```markdown
---
description: Research and document an existing codebase
scripts:
  sh: scripts/bash/spec-metadata.sh
  ps: scripts/powershell/spec-metadata.ps1
---

## User Input

```text
$ARGUMENTS
```

## Overview

This command conducts research on an existing codebase and produces a research document.

## Process

### 1. Setup
- Run `{SCRIPT}` to collect metadata (date, commit, branch, repository)
- Determine output directory:
  - If `.specify/` exists: use `.specify/research/`
  - Otherwise: use `thoughts/shared/research/`
- Filename format: `YYYY-MM-DD-description.md`

### 2. Understand the Research Question
- If user provided a specific question, focus on that
- If user provided file paths, read them first (FULLY, no limit/offset)
- Decompose the question into research areas

### 3. Conduct Research
For agents that support parallel execution:
- Spawn sub-agents for different aspects
- Use codebase-locator to find WHERE code lives
- Use codebase-analyzer to understand HOW code works
- Use codebase-pattern-finder to find similar patterns

For sequential execution:
- Search for files related to the topic
- Read key files to understand implementation
- Document patterns and connections

### 4. Generate Research Document
- Use the research template structure
- Include specific file:line references
- Document findings without suggesting improvements
- Note any open questions for follow-up

### 5. Output
- Write research document to determined directory
- Report location to user
- Offer to answer follow-up questions

## Key Rules
- Document what EXISTS, not what SHOULD be
- Include file:line references for all claims
- Read files FULLY before making statements
- Focus on "how it works" not "how to improve"
```

#### 5. Create Claude-Optimized Research Command

**File**: `.claude/commands/speckit.research.md`
**Action**: Create new file

```markdown
---
description: Research and document an existing codebase using parallel sub-agents
model: opus
---

# Research Codebase

You are tasked with conducting comprehensive research across the codebase by spawning parallel sub-agents and synthesizing their findings.

## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT THE CODEBASE AS IT EXISTS
- DO NOT suggest improvements or changes
- DO NOT critique the implementation
- ONLY describe what exists, where it exists, how it works

## Initial Setup

When this command is invoked, respond with:
```
I'm ready to research the codebase. Please provide your research question or area of interest, and I'll analyze it thoroughly.
```

Then wait for the user's research query.

## Steps

1. **Read any directly mentioned files first:**
   - Use the Read tool WITHOUT limit/offset parameters
   - Read files yourself in main context before spawning sub-tasks

2. **Analyze and decompose the research question:**
   - Break down into composable research areas
   - Create a research plan using TodoWrite

3. **Spawn parallel sub-agent tasks:**
   - Use **codebase-locator** to find WHERE files and components live
   - Use **codebase-analyzer** to understand HOW specific code works
   - Use **codebase-pattern-finder** to find examples of existing patterns

4. **Wait for all sub-agents to complete and synthesize findings:**
   - Compile all results
   - Connect findings across components
   - Include specific file:line references

5. **Gather metadata:**
   - Run `hack/spec_metadata.sh` (or `scripts/bash/spec-metadata.sh`)
   - Determine output directory:
     - If `.specify/` exists: use `.specify/research/`
     - Otherwise: use `thoughts/shared/research/`
   - Filename: `YYYY-MM-DD-description.md`

6. **Generate research document:**
   - Use YAML frontmatter with metadata
   - Structure with Research Question, Summary, Detailed Findings, Code References
   - Include Architecture Documentation and Open Questions sections

7. **Present findings:**
   - Show location of research document
   - Provide concise summary
   - Offer to answer follow-up questions

## Important Notes
- Always use parallel Task agents to maximize efficiency
- Focus on finding concrete file paths and line numbers
- Research documents should be self-contained
- Document cross-component connections
- You are a documentarian, not a critic
```

#### 6. Create/Update Metadata Script

**File**: `scripts/bash/spec-metadata.sh`
**Action**: Create new file (adapt from existing `hack/spec_metadata.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

# Collect metadata for spec-kit documents
DATETIME_TZ=$(date '+%Y-%m-%d %H:%M:%S %Z')
FILENAME_TS=$(date '+%Y-%m-%d_%H-%M-%S')
DATE_ONLY=$(date '+%Y-%m-%d')

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
  REPO_NAME=$(basename "$REPO_ROOT")
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD)
  GIT_COMMIT=$(git rev-parse HEAD)
else
  REPO_ROOT=""
  REPO_NAME=""
  GIT_BRANCH=""
  GIT_COMMIT=""
fi

# Determine output directory preference
if [ -d ".specify" ]; then
  OUTPUT_BASE=".specify"
else
  OUTPUT_BASE="thoughts/shared"
fi

# Print metadata
echo "Current Date/Time (TZ): $DATETIME_TZ"
echo "Date Only: $DATE_ONLY"
[ -n "$GIT_COMMIT" ] && echo "Current Git Commit Hash: $GIT_COMMIT"
[ -n "$GIT_BRANCH" ] && echo "Current Branch Name: $GIT_BRANCH"
[ -n "$REPO_NAME" ] && echo "Repository Name: $REPO_NAME"
echo "Timestamp For Filename: $FILENAME_TS"
echo "Output Base Directory: $OUTPUT_BASE"
```

**File**: `scripts/powershell/spec-metadata.ps1`
**Action**: Create new file (PowerShell equivalent)

```powershell
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
```

### Success Criteria:

#### Automated Verification:
- [x] Agent definition files exist in `templates/agents/`
- [x] Agent definition files exist in `.claude/agents/`
- [x] Research template exists at `templates/research-template.md`
- [x] Core research command exists at `templates/commands/research.md`
- [x] Claude research command exists at `.claude/commands/speckit.research.md`
- [x] Metadata script exists at `scripts/bash/spec-metadata.sh`
- [x] Metadata script is executable: `chmod +x scripts/bash/spec-metadata.sh && ./scripts/bash/spec-metadata.sh`
- [x] PowerShell script exists at `scripts/powershell/spec-metadata.ps1`

#### Manual Verification:
- [x] Run `/speckit.research` in Claude Code and verify it prompts for a research question
- [x] Provide a simple research question and verify it spawns sub-agents
- [x] Verify research document is created with proper structure and metadata

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to Phase 2.

---

## Phase 2: Brownfield Planning

### Overview
Create brownfield-specific planning templates and commands that include phase gates, verification separation, and iteration support.

### Changes Required:

#### 1. Create Brownfield Plan Template

**File**: `templates/plan-brownfield-template.md`
**Action**: Create new file

```markdown
# [Feature/Task Name] Implementation Plan

**Branch**: `[branch-name]` | **Date**: [DATE] | **Research**: [link to research doc]

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

### Key Discoveries:
- [Important finding with file:line reference]
- [Pattern to follow]
- [Constraint to work within]

## Desired End State

[Specification of the desired end state after this plan is complete]

### How to Verify:
- [Concrete verification step]
- [Another verification step]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]
- [Out of scope item 1]
- [Out of scope item 2]

## Implementation Approach

[High-level strategy and reasoning]

## Constitution Check

*GATE: Must pass before implementation begins*

### Part I: Project Architecture Principles
[Check relevant principles from constitution Part I]

### Part II: Development Process Principles
- [ ] Research-First: Codebase research completed before planning
- [ ] Plan-Before-Code: This plan will be approved before implementation
- [ ] Phase Gates: Each phase has clear verification criteria

---

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Changes Required:

#### 1. [Component/File Group]
**File**: `path/to/file.ext`
**Changes**: [Summary of changes]

```[language]
// Specific code to add/modify
```

#### 2. [Another Component]
**File**: `path/to/another.ext`
**Changes**: [Summary]

### Success Criteria:

#### Automated Verification:
- [ ] Tests pass: `make test` (or equivalent)
- [ ] Type checking passes: `npm run typecheck` (or equivalent)
- [ ] Linting passes: `make lint` (or equivalent)
- [ ] Build succeeds: `make build` (or equivalent)

#### Manual Verification:
- [ ] [Feature works as expected when tested]
- [ ] [Edge case verified]

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to the next phase.

---

## Phase N: [Descriptive Name]

[Repeat structure for each phase...]

---

## Testing Strategy

### Unit Tests:
- [What to test]
- [Key edge cases]

### Integration Tests:
- [End-to-end scenarios]

### Manual Testing Steps:
1. [Specific step to verify feature]
2. [Another verification step]

## Performance Considerations

[Any performance implications or optimizations needed]

## Migration Notes

[If applicable, how to handle existing data/systems]

## References

- Research document: `[path to research]`
- Related spec: `[path if applicable]`
- Similar implementation: `[file:line]`
```

#### 2. Create Core Brownfield Plan Command

**File**: `templates/commands/plan-brownfield.md`
**Action**: Create new file

```markdown
---
description: Create an implementation plan for changes to an existing codebase
scripts:
  sh: scripts/bash/spec-metadata.sh
  ps: scripts/powershell/spec-metadata.ps1
---

## User Input

```text
$ARGUMENTS
```

## Overview

This command creates a detailed implementation plan for brownfield development (changes to existing codebases).

## Process

### 1. Setup
- Run `{SCRIPT}` to collect metadata
- Determine output directory (`.specify/plans/` or `thoughts/shared/plans/`)
- Filename format: `YYYY-MM-DD-description.md`

### 2. Context Gathering
- If a research document is referenced, read it FULLY
- If a ticket/task file is referenced, read it FULLY
- Read any mentioned source files FULLY

### 3. Research (if not already done)
- If no research document exists, conduct research first
- Use codebase-locator, codebase-analyzer, codebase-pattern-finder
- Document findings before planning

### 4. Interactive Planning
- Present initial understanding of the task
- Ask clarifying questions if needed
- Get user feedback on approach

### 5. Plan Structure Development
- Propose phase breakdown
- Get feedback on phasing
- Iterate until structure is approved

### 6. Detailed Plan Writing
- Use the brownfield plan template
- Include specific file paths and code snippets
- Separate automated and manual verification criteria
- Include phase gates with pause points

### 7. Output
- Write plan to determined directory
- Present plan location to user
- Iterate based on feedback

## Key Rules
- NO open questions in final plan
- Each phase has clear success criteria
- Automated vs manual verification clearly separated
- Constitution check included
- Research must precede planning
```

#### 3. Create Claude-Optimized Brownfield Plan Command

**File**: `.claude/commands/speckit.plan.brownfield.md`
**Action**: Create new file (based on existing `create_plan.md` pattern)

```markdown
---
description: Create an implementation plan for brownfield development
model: opus
---

# Brownfield Implementation Plan

You are tasked with creating detailed implementation plans for changes to existing codebases through an interactive, iterative process.

## Initial Response

When invoked:

1. **If parameters provided**:
   - Read any provided files FULLY (no limit/offset)
   - Begin the research/planning process

2. **If no parameters**:
   ```
   I'll help you create a brownfield implementation plan. Please provide:
   1. The task/ticket description (or reference to a file)
   2. Any relevant research documents
   3. Specific requirements or constraints
   ```

## Process

### Step 1: Context Gathering

1. Read all mentioned files FULLY
2. Spawn research tasks if needed:
   - Use **codebase-locator** to find related files
   - Use **codebase-analyzer** to understand current implementation
   - Use **codebase-pattern-finder** to find similar patterns

3. Present understanding and ask focused questions

### Step 2: Research & Discovery

1. If user corrects misunderstanding, verify with new research
2. Create research todo list using TodoWrite
3. Spawn parallel sub-tasks for comprehensive research
4. Wait for ALL sub-tasks to complete
5. Present findings and design options

### Step 3: Plan Structure Development

```
Here's my proposed plan structure:

## Overview
[1-2 sentence summary]

## Implementation Phases:
1. [Phase name] - [what it accomplishes]
2. [Phase name] - [what it accomplishes]

Does this phasing make sense?
```

### Step 4: Detailed Plan Writing

1. Determine output directory:
   - If `.specify/` exists: `.specify/plans/`
   - Otherwise: `thoughts/shared/plans/`
2. Filename: `YYYY-MM-DD-description.md`
3. Write plan using brownfield template
4. Include Constitution Check section
5. Separate automated vs manual verification

### Step 5: Review & Iterate

1. Present draft plan location
2. Get feedback on phases, criteria, details
3. Iterate until approved

## Important Guidelines

- Be Skeptical: Question vague requirements
- Be Interactive: Get buy-in at each step
- Be Thorough: Include file:line references
- Be Practical: Focus on incremental changes
- No Open Questions: Resolve all before finalizing
```

#### 4. Create Plan Iteration Command

**File**: `.claude/commands/speckit.plan.iterate.md`
**Action**: Create new file

```markdown
---
description: Iterate on an existing implementation plan based on feedback
model: opus
---

# Iterate Implementation Plan

You are tasked with updating an existing implementation plan based on user feedback.

## Process

1. **Read the existing plan FULLY**
   - Use Read tool without limit/offset
   - Understand current structure and phases

2. **Understand the feedback**
   - What needs to change?
   - Are there new requirements?
   - Are phases being adjusted?

3. **Research if needed**
   - If feedback reveals missing information, research first
   - Use codebase-locator, codebase-analyzer as needed

4. **Update the plan**
   - Use Edit tool to make specific changes
   - Preserve working sections
   - Update success criteria if needed

5. **Present changes**
   - Summarize what was updated
   - Ask for additional feedback

## Guidelines

- Don't rewrite the entire plan for small changes
- Preserve file:line references that are still valid
- Update verification criteria if scope changes
- Maintain separation of automated vs manual verification
```

### Success Criteria:

#### Automated Verification:
- [x] Brownfield plan template exists at `templates/plan-brownfield-template.md`
- [x] Core plan command exists at `templates/commands/plan-brownfield.md`
- [x] Claude plan command exists at `.claude/commands/speckit.plan.brownfield.md`
- [x] Plan iterate command exists at `.claude/commands/speckit.plan.iterate.md`

#### Manual Verification:
- [x] Run `/speckit.plan.brownfield` and verify it prompts appropriately
- [x] Create a test plan and verify it follows the template structure
- [x] Verify plan includes Constitution Check section
- [x] Verify automated vs manual verification are clearly separated

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to Phase 3.

---

## Phase 3: Implementation Support

### Overview
Create implementation workflow commands including plan execution with verification pauses and handoff document support for session continuity.

### Changes Required:

#### 1. Create Core Implement Plan Command

**File**: `templates/commands/implement-plan.md`
**Action**: Create new file

```markdown
---
description: Execute an implementation plan with phase-by-phase verification
---

## User Input

```text
$ARGUMENTS
```

## Overview

This command implements an approved plan from `.specify/plans/` or `thoughts/shared/plans/`.

## Process

### 1. Load Plan
- Read the plan FULLY (no limit/offset)
- Check for existing checkmarks (- [x]) to determine resume point
- Read original ticket and all files mentioned in plan

### 2. For Each Phase

1. **Implement the changes**
   - Follow the plan's specifications
   - Create/modify files as described
   - Update checkboxes as sections complete

2. **Run automated verification**
   - Execute all commands listed under "Automated Verification"
   - Fix any issues before proceeding

3. **Pause for manual verification**
   ```
   Phase [N] Complete - Ready for Manual Verification

   Automated verification passed:
   - [List checks that passed]

   Please perform manual verification:
   - [List manual items from plan]

   Let me know when ready to proceed to Phase [N+1].
   ```

4. **Wait for user confirmation** before next phase

### 3. Handle Mismatches

If plan doesn't match reality:
```
Issue in Phase [N]:
Expected: [what plan says]
Found: [actual situation]
Why this matters: [explanation]

How should I proceed?
```

### 4. Completion
- Ensure all checkboxes in plan are updated
- Report final status
- Suggest next steps (PR, additional testing, etc.)

## Key Rules
- Never skip manual verification pauses
- Update checkboxes in plan file as you complete items
- Stop and ask if reality doesn't match plan
- Trust existing checkmarks when resuming
```

#### 2. Create Claude-Optimized Implement Command

**File**: `.claude/commands/speckit.implement.plan.md`
**Action**: Create new file (based on humanlayer `implement_plan.md`)

```markdown
---
description: Implement an approved plan from plans directory with verification
---

# Implement Plan

You are tasked with implementing an approved technical plan. Plans contain phases with specific changes and success criteria.

## Getting Started

When given a plan path:
- Read the plan completely and check for existing checkmarks (- [x])
- Read the original ticket and all files mentioned in the plan
- **Read files fully** - never use limit/offset
- Create a todo list to track progress
- Start implementing if you understand what needs to be done

If no plan path provided, ask for one.

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:
- Follow the plan's intent while adapting to what you find
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader context
- Update checkboxes in the plan as you complete sections

## Verification Approach

After implementing a phase:
1. Run the automated verification checks
2. Fix any issues before proceeding
3. Update your progress in both the plan and your todos
4. **Pause for human verification**:

```
Phase [N] Complete - Ready for Manual Verification

Automated verification passed:
- [List automated checks that passed]

Please perform the manual verification steps:
- [List manual items from plan]

Let me know when manual testing is complete so I can proceed.
```

Do not check off manual items until confirmed by user.

## Handling Mismatches

If something doesn't match the plan:
```
Issue in Phase [N]:
Expected: [what the plan says]
Found: [actual situation]
Why this matters: [explanation]

How should I proceed?
```

## Resuming Work

If plan has existing checkmarks:
- Trust that completed work is done
- Pick up from first unchecked item
- Verify previous work only if something seems off
```

#### 3. Create Validation Command

**File**: `.claude/commands/speckit.implement.validate.md`
**Action**: Create new file

```markdown
---
description: Validate implementation against plan and identify issues
---

# Validate Implementation

You are tasked with validating that an implementation matches its plan.

## Process

1. **Read the plan FULLY**
   - Understand what was supposed to be implemented
   - Note all success criteria

2. **Check each phase**
   - Verify files were created/modified as specified
   - Run automated verification commands
   - Note any deviations

3. **Report findings**

```
## Validation Report

### Phase 1: [Name]
- [x] File changes: All specified changes present
- [x] Automated tests: Passing
- [ ] Manual verification: Not yet confirmed

### Issues Found:
- [Description of any issues]

### Recommendations:
- [What to do about issues]
```

## Guidelines
- Be thorough - check every success criterion
- Note both successes and failures
- Provide actionable recommendations for issues
```

#### 4. Create Handoff Template

**File**: `templates/handoff-template.md`
**Action**: Create new file

```markdown
---
date: [Current date and time with timezone]
researcher: [Name]
git_commit: [Commit hash]
branch: [Branch name]
repository: [Repository name]
topic: "[Task/Feature description]"
tags: [handoff, component-names]
status: in_progress
last_updated: [YYYY-MM-DD]
last_updated_by: [Name]
type: handoff
---

# Handoff: [Task/Ticket] - [Brief Description]

## Task(s)

| Task | Status | Notes |
|------|--------|-------|
| [Task 1] | [completed/in_progress/planned] | [Notes] |
| [Task 2] | [status] | [Notes] |

If working from an implementation plan, note current phase:
- **Plan**: `[path to plan]`
- **Current Phase**: [N]
- **Phase Status**: [description]

## Critical References

[2-3 most important files that must be read to continue]
- `path/to/critical/file.ext` - Why it's critical
- `path/to/another.ext` - Why it's critical

## Recent Changes

[Changes made in this session, with file:line references]
- `path/to/modified.ext:45-67` - What was changed
- `path/to/new-file.ext` - What was created

## Learnings

[Important discoveries that the next agent should know]
- [Pattern discovered]
- [Root cause found]
- [Important constraint]

## Artifacts

[Files produced or updated]
- `thoughts/shared/plans/YYYY-MM-DD-description.md` - Implementation plan
- `thoughts/shared/research/YYYY-MM-DD-description.md` - Research document

## Action Items & Next Steps

1. [ ] [Next action item]
2. [ ] [Another action item]
3. [ ] [Future consideration]

## Other Notes

[Additional context, references, or useful information]
```

#### 5. Create Handoff Commands

**File**: `.claude/commands/speckit.handoff.create.md`
**Action**: Create new file

```markdown
---
description: Create handoff document for session continuity
---

# Create Handoff

You are tasked with creating a handoff document to transfer context to another session.

## Process

### 1. Filepath & Metadata
- Run `scripts/bash/spec-metadata.sh` for metadata
- Determine output directory:
  - If `.specify/` exists: `.specify/handoffs/`
  - Otherwise: `thoughts/shared/handoffs/`
- Create subdirectory for ticket if applicable
- Filename: `YYYY-MM-DD_HH-MM-SS_description.md`

### 2. Write Handoff Document
Using the handoff template, document:
- Current task status
- Critical files to read
- Recent changes with file:line references
- Important learnings
- Artifacts produced
- Next steps

### 3. Output
- Write the handoff document
- Report location with resume command:
  ```
  Handoff created! Resume with:
  /speckit.handoff.resume [path-to-handoff]
  ```

## Guidelines
- Be thorough but concise
- Include file:line references, not code snippets
- Focus on what the next agent needs to know
- List artifacts exhaustively
```

**File**: `.claude/commands/speckit.handoff.resume.md`
**Action**: Create new file

```markdown
---
description: Resume work from a handoff document
---

# Resume from Handoff

You are resuming work from a handoff document created by a previous session.

## Process

### 1. Read the Handoff
- Read the handoff document FULLY
- Note current status, learnings, and next steps

### 2. Gather Context
- Read all files listed in "Critical References"
- Read any plans or research documents mentioned
- Review recent changes

### 3. Verify State
- Check that the codebase matches expected state
- Run any verification commands if applicable
- Note any discrepancies

### 4. Present Status
```
Resuming from handoff: [handoff path]

## Current State:
- [Task status summary]
- [Current phase if working from plan]

## What I've Read:
- [List of files reviewed]

## Ready to Continue:
- [Next action items from handoff]

Shall I proceed with [first action item]?
```

### 5. Continue Work
- Follow action items from handoff
- Update plan checkboxes if applicable
- Create new handoff when session ends
```

### Success Criteria:

#### Automated Verification:
- [x] Core implement command exists at `templates/commands/implement-plan.md`
- [x] Claude implement command exists at `.claude/commands/speckit.implement.plan.md`
- [x] Validate command exists at `.claude/commands/speckit.implement.validate.md`
- [x] Handoff template exists at `templates/handoff-template.md`
- [x] Handoff create command exists at `.claude/commands/speckit.handoff.create.md`
- [x] Handoff resume command exists at `.claude/commands/speckit.handoff.resume.md`

#### Manual Verification:
- [x] Run `/speckit.implement.plan` with a test plan and verify phase pauses work
- [x] Create a handoff document and verify it contains expected sections
- [x] Resume from a handoff and verify context is properly restored
- [x] Verify validation command correctly identifies issues

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to Phase 4.

---

## Phase 4: Constitutional Extension

### Overview
Extend the constitution template to include Part II for development process principles and update documentation.

### Changes Required:

#### 1. Extend Constitution Template

**File**: `memory/constitution.md`
**Action**: Edit to add Part II

Add after existing content:

```markdown

---

## Part II: Development Process Principles

### Article I: Research-First Development
All codebase changes MUST be preceded by documented research.
No code changes shall be made without understanding the current implementation.
Research documents are stored in `.specify/research/` or `thoughts/shared/research/`.

### Article II: Plan-Before-Code Imperative
Implementation plans MUST be reviewed and approved before coding begins.
No significant code changes without an approved plan.
Plans are stored in `.specify/plans/` or `thoughts/shared/plans/`.

### Article III: Phase-Gate Verification
Each implementation phase MUST pass automated verification before proceeding.
Manual verification MUST occur before starting subsequent phases.
Verification criteria must distinguish automated vs manual checks.

### Article IV: Open Questions Prohibition
Final implementation plans MUST have zero unresolved questions.
Any open questions MUST be resolved before plan approval.

### Article V: Mismatch Transparency
Any deviation from an approved plan MUST be documented and approved.
No silent changes to implementation approach.

### Article VI: Session Continuity
Work that spans sessions MUST use handoff documents.
Handoffs capture context, learnings, and next steps.

---

## Governance

This Constitution supersedes all other development practices.
Amendments require:
1. Clear rationale for the change
2. Documentation of the amendment
3. Migration plan for affected workflows

**Version**: [VERSION] | **Ratified**: [DATE] | **Last Amended**: [DATE]
```

#### 2. Create Constitutional Gates for Brownfield Plans

**File**: `templates/plan-brownfield-template.md`
**Action**: Update Constitution Check section (already included in Phase 2)

The Constitution Check section should reference:
- Part I principles (project-specific)
- Part II principles (process)

#### 3. Update Documentation

**File**: `spec-driven.md`
**Action**: Edit to add brownfield workflow section

Add a new section after existing greenfield workflow:

```markdown
## Brownfield Development Workflow

For existing codebases, spec-kit provides a Research → Plan → Implement workflow:

### Research Phase
```
/speckit.research
```
Document the existing codebase without suggesting improvements. Produces a research document with file:line references.

### Planning Phase
```
/speckit.plan.brownfield
```
Create an implementation plan with:
- Phase-by-phase changes
- Separated automated/manual verification
- Constitution check
- Pause points for review

### Implementation Phase
```
/speckit.implement.plan path/to/plan.md
```
Execute the plan with:
- Phase-gate verification
- Manual testing pauses
- Progress tracking via checkboxes
- Mismatch handling

### Session Continuity
```
/speckit.handoff.create
/speckit.handoff.resume path/to/handoff.md
```
Transfer context between sessions.

### Directory Structure

Brownfield artifacts are stored in:
- `.specify/research/` or `thoughts/shared/research/` - Research documents
- `.specify/plans/` or `thoughts/shared/plans/` - Implementation plans
- `.specify/handoffs/` or `thoughts/shared/handoffs/` - Session handoffs
```

### Success Criteria:

#### Automated Verification:
- [x] Constitution template includes Part II at `memory/constitution.md`
- [x] `spec-driven.md` includes brownfield workflow documentation
- [x] All new commands reference constitution check

#### Manual Verification:
- [ ] Review constitution Part II principles for completeness
- [ ] Verify brownfield workflow documentation is clear and accurate
- [ ] Test that constitution check in plans references both parts

**Implementation Note**: After completing this phase, the brownfield extension is complete.

---

## Testing Strategy

### Unit Tests:
- Metadata script produces expected output format
- All template files have valid markdown structure

### Integration Tests:
- Full workflow: research → plan → implement → handoff → resume
- Directory detection (`.specify/` vs `thoughts/`)
- Constitution check integration with plans

### Manual Testing Steps:
1. Run `/speckit.research` on a simple codebase question
2. Create a plan with `/speckit.plan.brownfield` for a simple change
3. Implement the plan with `/speckit.implement.plan`
4. Create a handoff and resume in a new session
5. Verify all artifacts are created in correct locations

## Performance Considerations

- Parallel sub-agent execution for research efficiency
- File reading without limit/offset for complete context
- Todo tracking to avoid context loss in long sessions

## Migration Notes

- Existing greenfield workflows are unaffected
- New commands are additive
- Constitution extends with new Part II (existing Part I unchanged)
- Directory structure supports both patterns (`.specify/` and `thoughts/`)

## References

- Research document: `thoughts/shared/research/2025-12-11-extending-spec-kit-for-brownfield.md`
- Humanlayer reference: `/Users/amartis/local-Dev/humanlayer/.claude/commands/`
- Existing spec-kit templates: `/Users/amartis/local-Dev/spec-kit/templates/`
