# pndr Task Runner

## Authentication
Use OAuth2 client credentials to authenticate with pndr:
- Token endpoint: https://pndr.io/oauth/token
- Client ID: [stored in environment variable PNDR_CLIENT_ID]
- Client Secret: [stored in environment variable PNDR_CLIENT_SECRET]
- Grant type: client_credentials

## Workflow
1. Authenticate and get access token
2. Call pndr MCP to list_ideas with tags: ["claude-queue"], status: "active"
3. For each task, read the description and the latest comment (for iterating on work) don't include the comments that are from [claude-code].  
4. If starting to work on a task, move it to In-Progress, and comment prefixing [claude-code] and summarize your game plan before you start doing the work.  
5. If a repo/projects exists in projects.json use the local directory for making code changes.  Also for each feature being worked on, if it's new make a branch.  This may require committing whatever changes were on a previous active branch before switching to a new branch.  It may also requiring continuing to work on the existing branch or staying on the current branch depending upon the scope of the work being done.
6. Add a comment summarizing what was done prefix with [claude-code] using pndr MCP.  Do not comment on an idea if it's tagged "Review".
7. If it's a coding related task, branch, commit, and open a pull request for it when the task is completed.
8. Also tag the idea as "Review" regardless if it's a coding task or not, move it to In-Progress and do not mark is Completed.

## New coding projects
If a task you wind up working on is new, or you get asked to, wire it up to be deployed to Render.  You have access to the command line tool, so you should be able to make a new project.  The github pipeline should be wired up as well to deploy to it on an ongoing basis.  The goal is to be able to preview it quickly without having to stand it up.

## MCP Connection
The pndr MCP server is at https://pndr.io/mcp
Pass the bearer token in the Authorization header.  However it may already be connected.
