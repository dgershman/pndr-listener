#!/bin/bash

# pndr Queue Processor
# Wakes up periodically and processes the claude-queue
# Automatically refreshes OAuth token before expiry (tokens last 60 min)

INTERVAL_MINUTES=15                              # How often to process the queue
INTERVAL=$((INTERVAL_MINUTES * 60))              # Auto-calculated seconds
TOKEN_EXPIRY_MINUTES=60                          # OAuth token lifetime
TOKEN_REFRESH=$(((TOKEN_EXPIRY_MINUTES - 10) * 60))  # Refresh 10 min before expiry
CLAUDE_CONFIG="$HOME/.claude.json"

# Load credentials from .env
PNDR_DIR="$(dirname "$0")"
if [ -f "$PNDR_DIR/.env" ]; then
    export $(grep -E "^PNDR_CLIENT_(ID|SECRET)=" "$PNDR_DIR/.env" | xargs)
fi

# Verify credentials exist
if [ -z "$PNDR_CLIENT_ID" ] || [ -z "$PNDR_CLIENT_SECRET" ]; then
    echo "Error: PNDR_CLIENT_ID and PNDR_CLIENT_SECRET must be set in .env"
    exit 1
fi

LAST_TOKEN_REFRESH=0

refresh_token() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Refreshing OAuth token..."

    # Get new token from pndr
    RESPONSE=$(curl -s -X POST https://pndr.io/oauth/token \
        -H "Content-Type: application/json" \
        -d "{
            \"grant_type\": \"client_credentials\",
            \"client_id\": \"$PNDR_CLIENT_ID\",
            \"client_secret\": \"$PNDR_CLIENT_SECRET\"
        }")

    TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

    if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
        echo "Error: Failed to get access token"
        echo "Response: $RESPONSE"
        return 1
    fi

    # Update Claude config with new token
    # Update both global and project-specific pndr configs
    if [ -f "$CLAUDE_CONFIG" ]; then
        # Create backup
        cp "$CLAUDE_CONFIG" "$CLAUDE_CONFIG.bak"

        # Update all pndr MCP server configs with the new token
        jq --arg token "Bearer $TOKEN" '
            # Update global mcpServers if exists
            if .mcpServers.pndr then
                .mcpServers.pndr.headers = {"Authorization": $token}
            else . end |
            # Update project-specific configs
            .projects |= (if . then map_values(
                if .mcpServers.pndr then
                    .mcpServers.pndr.headers = {"Authorization": $token}
                else . end
            ) else . end)
        ' "$CLAUDE_CONFIG.bak" > "$CLAUDE_CONFIG"

        echo "$(date '+%Y-%m-%d %H:%M:%S') - Token refreshed successfully"
        LAST_TOKEN_REFRESH=$(date +%s)
        return 0
    else
        echo "Error: Claude config not found at $CLAUDE_CONFIG"
        return 1
    fi
}

# Initial token refresh
refresh_token

while true; do
    CURRENT_TIME=$(date +%s)
    TIME_SINCE_REFRESH=$((CURRENT_TIME - LAST_TOKEN_REFRESH))

    # Refresh token if needed (every 50 minutes)
    if [ $TIME_SINCE_REFRESH -ge $TOKEN_REFRESH ]; then
        refresh_token
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Processing queue..."
    echo "----------------------------------------"

    claude -p "process the queue" --dangerously-skip-permissions --verbose 2>&1 | while IFS= read -r line; do
        echo "$line"
    done

    echo "----------------------------------------"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Done. Sleeping for $INTERVAL_MINUTES minutes..."
    sleep $INTERVAL
done
