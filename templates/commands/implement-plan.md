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
