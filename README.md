# pndr-listener

A task runner that connects Claude Code to pndr for autonomous task processing.

## Overview

This project enables Claude Code to automatically pick up and execute tasks from your pndr queue. Tasks tagged with `claude-queue` are processed on a configurable interval, with support for additional tag filtering (e.g., `work` or `personal`).

## How It Works

1. **Authentication**: Uses OAuth2 client credentials to authenticate with pndr
2. **Task Discovery**: Polls pndr for active tasks tagged `claude-queue` (plus any additional filter tags)
3. **Planning**: For each task, Claude enters plan mode to explore the codebase and design an approach
4. **Execution**: Posts the plan as a comment, then executes it
5. **Completion**: Creates PRs for code changes, tags tasks as "Review" for human follow-up

## Setup

1. Create a `.env` file with your pndr credentials:
   ```
   PNDR_CLIENT_ID=your_client_id
   PNDR_CLIENT_SECRET=your_client_secret
   ```

2. Create a `projects.json` file mapping project names to local paths:
   ```json
   {
     "my-project": {
       "repo": "https://github.com/user/my-project",
       "localPath": "/path/to/local/my-project"
     }
   }
   ```

3. Run the queue processor:
   ```bash
   ./process-queue.sh              # All claude-queue tasks
   ./process-queue.sh work         # Only tasks also tagged "work"
   ./process-queue.sh personal     # Only tasks also tagged "personal"
   ```

## Task Workflow

1. Tag a task in pndr with `claude-queue` (and optionally `work`/`personal`)
2. The processor picks it up and moves it to In-Progress
3. Claude posts a plan as a comment prefixed with `[claude-code]`
4. Claude executes the plan, commits code, and opens a PR if applicable
5. Task is tagged "Review" for human verification

## Configuration

- `INTERVAL_MINUTES`: How often to check for new tasks (default: 15)
- Token auto-refreshes before expiry (tokens last 60 minutes)
