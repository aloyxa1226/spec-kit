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

### 3. Constitution Loading (with Fallback)

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
- Use default development process principles (Research-First, Plan-Before-Code, Phase Gates, Incremental Delivery)
- Set governance mode to "Reduced Governance"
- Continue with planning workflow

### 4. Research (if not already done)
- If no research document exists, conduct research first
- Use codebase-locator, codebase-analyzer, codebase-pattern-finder
- Document findings before planning

### 5. Interactive Planning
- Present initial understanding of the task
- Ask clarifying questions if needed
- Get user feedback on approach

### 6. Plan Structure Development
- Propose phase breakdown
- Get feedback on phasing
- Iterate until structure is approved

### 7. Detailed Plan Writing
- Use the brownfield plan template
- Include specific file paths and code snippets
- Separate automated and manual verification criteria
- Include phase gates with pause points

#### Constitution Check Population

Based on the governance mode determined in step 3:

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

### 8. Output
- Write plan to determined directory
- Present plan location to user
- Iterate based on feedback

## Key Rules
- NO open questions in final plan
- Each phase has clear success criteria
- Automated vs manual verification clearly separated
- Constitution check included (Full Governance if constitution exists, Reduced Governance otherwise)
- Research must precede planning
