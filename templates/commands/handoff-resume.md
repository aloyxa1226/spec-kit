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
