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
