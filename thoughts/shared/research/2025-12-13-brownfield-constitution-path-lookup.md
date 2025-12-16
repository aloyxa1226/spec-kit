---
date: 2025-12-13T16:26:17-08:00
researcher: Claude
git_commit: 5e914fc873038e8536c47a6ebf81f93dc5ed28ed
branch: fork-main
repository: spec-kit
topic: "Brownfield Constitution File Path Lookup"
tags: [research, codebase, brownfield, constitution, plan-template]
status: complete
last_updated: 2025-12-13
last_updated_by: Claude
---

# Research: Brownfield Constitution File Path Lookup

**Date**: 2025-12-13 16:26:17 PST
**Researcher**: Claude
**Git Commit**: 5e914fc873038e8536c47a6ebf81f93dc5ed28ed
**Branch**: fork-main
**Repository**: spec-kit

## Research Question

Document how the brownfield planning workflow and plan template look for the constitution file, and identify where the path lookup occurs.

## Summary

The brownfield planning workflow references the constitution file through hardcoded paths in templates. The standard plan workflow uses `/memory/constitution.md` which gets transformed to `.specify/memory/constitution.md` during deployment. The brownfield plan template includes a "Constitution Check" section but relies on the same path transformation logic. There is no dynamic search mechanism to find the constitution file in alternative locations within the `.specify` directory or its subdirectories.

## Detailed Findings

### Constitution File Path References

The following files reference the constitution file location:

#### 1. Standard Plan Command (`templates/commands/plan.md:31`)
```markdown
2. **Load context**: Read FEATURE_SPEC and `/memory/constitution.md`. Load IMPL_PLAN template (already copied).
```

#### 2. Constitution Command (`templates/commands/constitution.md:19,23,64,82`)
```markdown
You are updating the project constitution at `/memory/constitution.md`.
...
1. Load the existing constitution template at `/memory/constitution.md`.
...
7. Write the completed constitution back to `/memory/constitution.md` (overwrite).
...
Do not create a new template; always operate on the existing `/memory/constitution.md` file.
```

#### 3. Analyze Command (`templates/commands/analyze.md:24,68`)
```markdown
**Constitution Authority**: The project constitution (`/memory/constitution.md`) is **non-negotiable**...
...
- Load `/memory/constitution.md` for principle validation
```

### Path Transformation Logic

When templates are deployed to a target project, paths are rewritten by the CLI (`src/specify_cli/__init__.py:807-809`):

```python
body = re.sub(r'(/?)memory/', r'.specify/memory/', body)
body = re.sub(r'(/?)scripts/', r'.specify/scripts/', body)
body = re.sub(r'(/?)templates/', r'.specify/templates/', body)
```

This transforms:
- `/memory/constitution.md` → `.specify/memory/constitution.md`
- `memory/constitution.md` → `.specify/memory/constitution.md`

### Brownfield Plan Template Constitution Check

The brownfield plan template (`templates/plan-brownfield-template.md:36-47`) includes a Constitution Check section:

```markdown
## Constitution Check

*GATE: Must pass before implementation begins*

### Part I: Project Architecture Principles
[Check relevant principles from constitution Part I]

### Part II: Development Process Principles
- [ ] Research-First: Codebase research completed before planning
- [ ] Plan-Before-Code: This plan will be approved before implementation
- [ ] Phase Gates: Each phase has clear verification criteria
```

### Brownfield Plan Command

The brownfield plan command (`templates/commands/plan-brownfield.md:60`) lists "Constitution check included" as a key rule but does not specify the lookup path:

```markdown
## Key Rules
- NO open questions in final plan
- Each phase has clear success criteria
- Automated vs manual verification clearly separated
- Constitution check included
- Research must precede planning
```

### Output Directory Detection

The `spec-metadata.sh` script (`scripts/bash/spec-metadata.sh:22-26`) determines the output base directory:

```bash
if [ -d ".specify" ]; then
  OUTPUT_BASE=".specify"
else
  OUTPUT_BASE="thoughts/shared"
fi
```

### Current Directory Structure

The spec-kit repository itself does not contain a `memory/` directory or `.specify/` directory (confirmed via glob search). These are created when the CLI deploys templates to a target project.

Expected deployed structure:
```
project-root/
├── .specify/
│   ├── memory/
│   │   └── constitution.md    # Expected constitution location
│   ├── scripts/
│   │   └── bash/ or powershell/
│   ├── templates/
│   │   └── *.md
│   └── plans/
│       └── *.md
└── .claude/ (or other agent folder)
    └── commands/
        └── speckit.*.md
```

## Code References

- `templates/commands/plan.md:31` - Standard plan constitution reference
- `templates/commands/constitution.md:19,23,64,82` - Constitution command path references
- `templates/commands/analyze.md:24,68` - Analyze command constitution loading
- `templates/commands/plan-brownfield.md:60` - Brownfield key rules mention
- `templates/plan-brownfield-template.md:36-47` - Constitution Check section in template
- `src/specify_cli/__init__.py:807-809` - Path transformation regex
- `scripts/bash/spec-metadata.sh:22-26` - Output directory detection

## Architecture Documentation

### Constitution File Lookup Flow

1. **Template authoring**: Templates use `/memory/constitution.md` as the reference path
2. **CLI deployment**: Path transformation regex rewrites to `.specify/memory/constitution.md`
3. **Runtime**: Commands expect constitution at the transformed hardcoded path
4. **No search**: There is no fallback search mechanism if the file is not at the expected location

### Brownfield Workflow Relationship

The brownfield workflow commands were added to support existing codebases:
- `/speckit.research` - Document existing codebase
- `/speckit.plan-brownfield` - Create implementation plan
- `/speckit.implement-plan` - Execute plan with phase gates
- `/speckit.handoff-create` - Create session handoff
- `/speckit.handoff-resume` - Resume from handoff

These commands follow the same constitution reference pattern as the standard workflow.

## Historical Context (from thoughts/)

Related research documents:
- `thoughts/shared/research/2025-12-11-extending-spec-kit-for-brownfield.md` - Initial brownfield extension research
- `thoughts/shared/research/2025-12-12-brownfield-cli-deployment-investigation.md` - CLI deployment investigation
- `thoughts/shared/plans/2025-12-11-extending-spec-kit-brownfield.md` - Brownfield extension plan
- `thoughts/shared/plans/2025-12-12-enable-brownfield-fork-deployment.md` - Fork deployment enablement plan

## Related Research

- `thoughts/shared/research/2025-12-11-extending-spec-kit-for-brownfield.md`
- `thoughts/shared/research/2025-12-12-brownfield-cli-deployment-investigation.md`

## Open Questions

1. What happens when the constitution file does not exist at `.specify/memory/constitution.md`?
2. Should there be a search mechanism to check alternative locations (e.g., `.specify/constitution.md`, `constitution.md`)?
3. How should the brownfield workflow handle projects that don't have a constitution file?
