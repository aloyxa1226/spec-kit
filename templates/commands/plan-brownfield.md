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
