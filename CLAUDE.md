# pndr Task Runner

## Authentication
Use OAuth2 client credentials to authenticate with pndr:
- Token endpoint: https://pndr.io/oauth/token
- Client ID: [stored in environment variable PNDR_CLIENT_ID]
- Client Secret: [stored in environment variable PNDR_CLIENT_SECRET]
- Grant type: client_credentials

## Workflow
1. Authenticate and get access token
2. Call pndr MCP to list_ideas with tags: ["claude-queue"], status: "active". If additional tags are specified (e.g., "work" or "personal"), only pick up tasks that have BOTH "claude-queue" AND all the specified additional tags.
3. For each task, read the description and the latest comment (for iterating on work) don't include the comments that are from [claude-code].

### Planning Phase
4. Move the task to In-Progress.
5. Explore the codebase to understand the relevant files, patterns, and architecture.
6. Design an implementation plan and immediately post it as a comment prefixed with [claude-code] using the pndr MCP add_comment tool. Do NOT wait for approval - proceed directly to execution after posting.

### Execution Phase
7. If a repo/project exists in projects.json, use the local directory for making code changes. For new features, create a branch. This may require committing changes on a previous active branch before switching, or continuing work on an existing branch depending on scope.
8. Execute the plan in a single pass - make all the code changes.
9. Run tests (`npm test`) and build (`npm run build`) before committing. Fix any failures before proceeding.
10. Add a comment summarizing what was done, prefixed with [claude-code]. Do not comment on an idea if it's tagged "Review".
11. If it's a coding related task, commit and open a pull request when completed.
12. Tag the idea as "Review", keep it In-Progress, and do not mark it Completed.

## Important
- Do NOT use EnterPlanMode - it requires user approval which blocks autonomous execution.
- Always post comments using the pndr MCP tools, not just output text.
- After posting the plan comment, immediately proceed to execution in the same session.

## New coding projects
If a task you wind up working on is new, or you get asked to, wire it up to be deployed to Render.  You have access to the command line tool, so you should be able to make a new project.  The github pipeline should be wired up as well to deploy to it on an ongoing basis.  The goal is to be able to preview it quickly without having to stand it up.

## MCP Connection
The pndr MCP server is at https://pndr.io/mcp
Pass the bearer token in the Authorization header.  However it may already be connected.
