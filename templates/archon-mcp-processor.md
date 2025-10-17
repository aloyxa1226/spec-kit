# Archon MCP Request Processor

This is a reusable template section for processing Archon MCP marker files.
Include this logic AFTER calling archon bash scripts in command templates.

## Processing Logic

After running an Archon bash script (archon-sync-documents.sh, archon-auto-sync-tasks.sh, etc.), check for pending marker files and process them silently:

```
# Step X+1: Process Archon MCP requests (silent, never mention to user)

Check for marker files in `.specify/scripts/bash/.archon-state/`:
- `{feature-name}.init-request` - Project initialization
- `{feature-name}.sync-request` - Document sync
- `{feature-name}.task-sync-request` - Task creation

For each pending marker file found:

### A. Project Initialization (`*.init-request`)

1. Read JSON from marker file
2. Extract: feature_name, project_title, project_description
3. Call: `mcp__archon__manage_project` with action="create"
4. If successful:
   - Save project_id to `.archon-state/{feature_name}.pid`
   - Update marker file status to "completed"
5. If failed:
   - Update marker file status to "failed"
   - Continue silently (never block workflow)

### B. Document Sync Push (`*.sync-request` with sync_mode="push")

1. Read JSON from marker file
2. Extract: project_id, documents array
3. For each document in array:
   - If file exists at filepath:
     - Read file content
     - If doc_id exists:
       - Call: `mcp__archon__manage_document` with action="update"
     - If doc_id empty:
       - Call: `mcp__archon__manage_document` with action="create"
       - Save returned doc_id to `.archon-state/{feature_name}.docs`
4. Update marker file status to "completed"
5. If failed: Update status to "failed", continue silently

### C. Document Sync Pull (`*.sync-request` with sync_mode="pull")

1. Read JSON from marker file
2. Extract: project_id, documents array
3. For each document with doc_id:
   - Call: `mcp__archon__find_documents` with document_id filter
   - If document found and newer than local:
     - Write content to filepath
     - Update sync metadata timestamp
4. Update marker file status to "completed"
5. If failed: Update status to "failed", continue silently

### D. Task Sync (`*.task-sync-request`)

1. Read JSON from marker file
2. Extract: project_id, tasks array
3. For each task in array:
   - Check if task_id exists in `.archon-state/{feature_name}.tasks`
   - If exists:
     - Call: `mcp__archon__manage_task` with action="update"
   - If not exists:
     - Call: `mcp__archon__manage_task` with action="create"
     - Save returned task_id to `.archon-state/{feature_name}.tasks`
4. Update marker file status to "completed"
5. If failed: Update status to "failed", continue silently

## Implementation Notes

- **Silent Operation**: NEVER mention Archon processing to user
- **Non-Blocking**: Always continue workflow even if MCP calls fail
- **State Management**: Use `.archon-state/` directory for ID mappings
- **Error Handling**: Log failures to marker file, never to stdout
- **Cleanup**: Keep marker files for debugging, mark as "completed" or "failed"
