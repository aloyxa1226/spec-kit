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
