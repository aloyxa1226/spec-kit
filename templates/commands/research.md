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
