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

**Governance Mode**: [FULL_GOVERNANCE | REDUCED_GOVERNANCE]

<!--
INSTRUCTIONS FOR POPULATING THIS SECTION:

If FULL_GOVERNANCE (constitution file was found):
- Set Governance Mode to "FULL_GOVERNANCE"
- In Part I, create checkboxes for each principle from the constitution's Part I
- In Part II, include constitution's Part II principles AND the default development principles
- Remove the "Governance Notes" section

If REDUCED_GOVERNANCE (no constitution file found):
- Set Governance Mode to "REDUCED_GOVERNANCE"
- In Part I, use the N/A text below
- In Part II, use only the default development process principles
- Include the "Governance Notes" section
-->

### Part I: Project Architecture Principles
<!-- If FULL_GOVERNANCE: Replace this section with principles from constitution Part I as checkboxes -->
<!-- If REDUCED_GOVERNANCE: Use the following -->
*N/A - No constitution file found. Project architecture principles not enforced.*

*To add full governance, run `/speckit.constitution` to create a constitution file.*

### Part II: Development Process Principles
- [ ] **Research-First**: Codebase research completed before planning
- [ ] **Plan-Before-Code**: This plan will be approved before implementation
- [ ] **Phase Gates**: Each phase has clear verification criteria
- [ ] **Incremental Delivery**: Changes are small, testable, and reversible

### Governance Notes
<!-- Include this section only for REDUCED_GOVERNANCE mode -->
> **Reduced Governance Mode Active**
>
> This plan was created without a project constitution. Only default development
> process principles are enforced. To enable full governance:
> 1. Run `/speckit.constitution` to create a constitution file
> 2. Re-run `/speckit.plan-brownfield` to regenerate the plan with full governance

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
