#!/bin/bash

# github api
API_URL="https://api.github.com/users/$ACCOUNT/repos"

# DATA VARS
DATA_DIR="/var/lib/github_sync"
REPO_FILE="$DATA_DIR/git_repos"

# LOG VARS
LOG_DIR="/var/log/github_sync"
LOG_FILE="$LOG_DIR/github_sync.log"
GITHUB_SYNC_RESULT_FILE="$LOG_DIR/result"


if [[ ! -d "$DATA_DIR" ]]; then
    mkdir -p "$DATA_DIR"
fi

if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi

echo "0" > "$GITHUB_SYNC_RESULT_FILE"

# fetch github api
curl "$API_URL" -o "$REPO_FILE" >> "$LOG_FILE" 2>&1 || echo "1" > "$GITHUB_SYNC_RESULT_FILE"

# loop file and clone repos
cat "$REPO_FILE" | jq -r '.[] | .clone_url + " " + .name' | while read URL NAME ; do

    cd "$DATA_DIR"
    git clone "$URL" >> "$LOG_FILE" 2>&1

    # pull if already cloned
    if [[ "$?" != "0" ]]; then
            (cd "$NAME" ; git pull >> "$LOG_FILE" || echo "1" > "$GITHUB_SYNC_RESULT_FILE" )
    fi

done

# curl healthchek.io
if [[ "$(cat "$GITHUB_SYNC_RESULT_FILE")" == "0" ]]; then
    curl "$HEALTHCHECK" >> "$LOG_FILE" 2>&1
fi
