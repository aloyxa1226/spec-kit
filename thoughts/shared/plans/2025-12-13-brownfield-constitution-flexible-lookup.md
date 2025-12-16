# Brownfield Constitution Flexible Path Lookup Implementation Plan

## Overview

Add flexible constitution file lookup to the brownfield planning workflow with graceful fallback behavior. When the constitution file is not found, the workflow continues with reduced governance (default development process principles) rather than failing.

## Current State Analysis

The brownfield plan command (`templates/commands/plan-brownfield.md`) does NOT explicitly reference or load the constitution file in its workflow steps. It only mentions "Constitution check included" as a key rule (line 60), which refers to the template structure rather than an automated loading step.

### Key Discoveries:
- `templates/commands/plan-brownfield.md:60` - Mentions "Constitution check included" but no explicit file loading
- `templates/plan-brownfield-template.md:36-47` - Contains Constitution Check section with placeholder text
- `src/specify_cli/__init__.py:807-809` - Path transformation regex (`/memory/` → `.specify/memory/`)
- Standard plan at `templates/commands/plan.md:31` explicitly loads constitution; brownfield does not

### Constitution Search Locations (Priority Order):
1. `.specify/memory/constitution.md` - Standard deployed location
2. `memory/constitution.md` - Source location (local dev)
3. `.specify/constitution.md` - Alternative location
4. `constitution.md` - Root-level fallback

## Desired End State

After implementation:
1. Brownfield plan command explicitly searches for constitution file in multiple locations
2. If found: Load constitution and populate Constitution Check section fully
3. If not found: Warn user and continue with "Reduced Governance Mode" using default principles
4. Plan output clearly indicates governance mode (full vs reduced)
5. User receives actionable guidance on how to add constitution later

### Verification:
- Run `/speckit.plan-brownfield` in a project WITH constitution → full governance mode
- Run `/speckit.plan-brownfield` in a project WITHOUT constitution → reduced governance mode with warning
- Both scenarios produce valid, usable plans

## What We're NOT Doing

- **No CLI changes**: All changes are template-level only
- **No new scripts**: Using inline instructions in templates
- **No changes to standard plan workflow**: Only brownfield commands affected
- **No mandatory constitution requirement**: Reduced governance is acceptable
- **No auto-generation of constitution**: User must explicitly create if desired

## Implementation Approach

Modify the brownfield plan command template to:
1. Add explicit constitution search instructions with priority order
2. Provide graceful fallback when not found
3. Update the brownfield plan template to support both governance modes

---

## Phase 1: Update Brownfield Plan Command

### Overview
Add constitution file search and loading instructions to the brownfield plan command with graceful fallback.

### Changes Required:

#### 1. Brownfield Plan Command Template
**File**: `templates/commands/plan-brownfield.md`
**Changes**: Add constitution loading step to Context Gathering section

Insert after line 25 (after "Determine output directory" step):

```markdown
### Constitution Loading (with Fallback)

Search for the constitution file in the following locations (in order):
1. `.specify/memory/constitution.md`
2. `memory/constitution.md`
3. `.specify/constitution.md`
4. `constitution.md`

**If constitution file is found:**
- Read the constitution file completely
- Extract Part I (Project Architecture Principles) and Part II (Development Process Principles)
- Use these principles to populate the Constitution Check section in the plan
- Set governance mode to "Full Governance"

**If constitution file is NOT found:**
- Display warning: "No constitution file found. Proceeding with Reduced Governance Mode."
- Inform user: "To add full governance, run `/speckit.constitution` to create a constitution file."
- Use default development process principles (Research-First, Plan-Before-Code, Phase Gates)
- Set governance mode to "Reduced Governance"
- Continue with planning workflow
```

Also update the Key Rules section at line 60 to clarify:

```markdown
## Key Rules
- NO open questions in final plan
- Each phase has clear success criteria
- Automated vs manual verification clearly separated
- Constitution check included (Full Governance if constitution exists, Reduced Governance otherwise)
- Research must precede planning
```

### Success Criteria:

#### Automated Verification:
- [ ] Template file is valid markdown: `cat templates/commands/plan-brownfield.md | head -100`
- [ ] No syntax errors in template structure

#### Manual Verification:
- [ ] Run `/speckit.plan-brownfield` in a project with constitution → sees "Full Governance" message
- [ ] Run `/speckit.plan-brownfield` in a project without constitution → sees warning and "Reduced Governance" message
- [ ] Both scenarios allow planning to proceed

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that the command behaves correctly before proceeding to Phase 2.

---

## Phase 2: Update Brownfield Plan Template

### Overview
Enhance the Constitution Check section in the brownfield plan template to support both governance modes.

### Changes Required:

#### 1. Brownfield Plan Template
**File**: `templates/plan-brownfield-template.md`
**Changes**: Replace the Constitution Check section (lines 36-47) with governance-aware version

Replace lines 36-47 with:

```markdown
## Constitution Check

*GATE: Must pass before implementation begins*

**Governance Mode**: [FULL_GOVERNANCE | REDUCED_GOVERNANCE]

<!--
If FULL_GOVERNANCE: Populate Part I and Part II from constitution file.
If REDUCED_GOVERNANCE: Leave Part I as N/A, use default Part II principles.
-->

### Part I: Project Architecture Principles
<!-- If FULL_GOVERNANCE: List principles from constitution Part I with checkboxes -->
<!-- If REDUCED_GOVERNANCE: -->
*N/A - No constitution file found. Project architecture principles not enforced.*

*To add full governance, run `/speckit.constitution` to create a constitution file.*

### Part II: Development Process Principles
- [ ] **Research-First**: Codebase research completed before planning
- [ ] **Plan-Before-Code**: This plan will be approved before implementation
- [ ] **Phase Gates**: Each phase has clear verification criteria
- [ ] **Incremental Delivery**: Changes are small, testable, and reversible

### Governance Notes
<!-- If REDUCED_GOVERNANCE, include this section: -->
> **Reduced Governance Mode Active**
>
> This plan was created without a project constitution. Only default development
> process principles are enforced. To enable full governance:
> 1. Run `/speckit.constitution` to create a constitution file
> 2. Re-run `/speckit.plan-brownfield` to regenerate the plan with full governance
```

### Success Criteria:

#### Automated Verification:
- [ ] Template file is valid markdown: `cat templates/plan-brownfield-template.md | head -100`
- [ ] Template contains "Governance Mode" placeholder
- [ ] Template contains both FULL_GOVERNANCE and REDUCED_GOVERNANCE instructions

#### Manual Verification:
- [ ] Generated plan with constitution shows populated Part I and Part II from constitution
- [ ] Generated plan without constitution shows "Reduced Governance Mode Active" notice
- [ ] Governance Notes section provides clear actionable guidance

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that generated plans look correct before proceeding to Phase 3.

---

## Phase 3: Update Brownfield Plan Command Detailed Instructions

### Overview
Add detailed instructions to the brownfield plan command for populating the Constitution Check section based on governance mode.

### Changes Required:

#### 1. Brownfield Plan Command - Detailed Plan Writing Section
**File**: `templates/commands/plan-brownfield.md`
**Changes**: Update the "Detailed Plan Writing" section to include constitution handling

Add after line 46 (inside the Detailed Plan Writing section):

```markdown
### Constitution Check Population

Based on the governance mode determined during Context Gathering:

**For Full Governance Mode:**
1. Set "Governance Mode" to "FULL_GOVERNANCE"
2. In Part I, create checkboxes for each principle from the constitution's Part I
3. In Part II, include both constitution's Part II principles AND the default development principles
4. Remove the "Governance Notes" section (not needed for full governance)
5. Evaluate each principle checkbox against the proposed implementation

**For Reduced Governance Mode:**
1. Set "Governance Mode" to "REDUCED_GOVERNANCE"
2. In Part I, write: "*N/A - No constitution file found. Project architecture principles not enforced.*"
3. Add the guidance text: "*To add full governance, run `/speckit.constitution` to create a constitution file.*"
4. In Part II, use only the default development process principles
5. Include the "Governance Notes" section with the reduced governance notice
6. Evaluate default principles against the proposed implementation
```

### Success Criteria:

#### Automated Verification:
- [ ] Template file is valid markdown
- [ ] Contains instructions for both Full Governance and Reduced Governance modes

#### Manual Verification:
- [ ] AI agent correctly populates Constitution Check for full governance case
- [ ] AI agent correctly populates Constitution Check for reduced governance case
- [ ] Principle checkboxes are properly evaluated in generated plans

**Implementation Note**: After completing this phase, the implementation is complete. Run full manual testing.

---

## Testing Strategy

### Unit Tests:
- N/A (template changes only, no code)

### Integration Tests:
- N/A (template changes only)

### Manual Testing Steps:

#### Test Case 1: Project WITH Constitution
1. Create a test project with `.specify/memory/constitution.md`
2. Run `/speckit.plan-brownfield` with a sample feature
3. Verify:
   - No warning about missing constitution
   - Constitution Check shows "FULL_GOVERNANCE"
   - Part I is populated from constitution
   - Part II includes constitution principles + defaults
   - No "Governance Notes" section

#### Test Case 2: Project WITHOUT Constitution
1. Create a test project without any constitution file
2. Run `/speckit.plan-brownfield` with a sample feature
3. Verify:
   - Warning displayed about missing constitution
   - Constitution Check shows "REDUCED_GOVERNANCE"
   - Part I shows N/A message with guidance
   - Part II shows only default principles
   - "Governance Notes" section present with upgrade guidance

#### Test Case 3: Constitution in Alternative Location
1. Create a test project with `constitution.md` at root (not in .specify/memory/)
2. Run `/speckit.plan-brownfield`
3. Verify:
   - Constitution is found via fallback search
   - Full governance mode is activated

## Performance Considerations

No performance impact - only template text changes.

## Migration Notes

- Existing brownfield plans will not be affected
- New plans generated after this change will include governance mode indicators
- Users can regenerate plans at any time to get updated format

## References

- Original research: `thoughts/shared/research/2025-12-13-brownfield-constitution-path-lookup.md`
- Brownfield plan command: `templates/commands/plan-brownfield.md`
- Brownfield plan template: `templates/plan-brownfield-template.md`
- Standard plan command (for comparison): `templates/commands/plan.md:31`
