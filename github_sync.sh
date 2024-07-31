#!/bin/bash

# github api
API_URL="https://api.github.com/users/$ACCOUNT/repos?per_page=100"

# DATA VARS
DATA_DIR="/var/lib/github_sync"
REPO_FILE="$DATA_DIR/git_repos"

# LOG VARS
LOG_DIR="/var/log/github_sync"
GITHUB_SYNC_RESULT_FILE="$LOG_DIR/result"


notify(){
  if [[ "$HEALTHCHECK" != "" ]]; then
      curl "$HEALTHCHECK"
  fi
  if [[ "$NTFY" != "" ]]; then
      curl "$NTFY" -X POST -d 'done backup of git repos'
  fi
}

if [[ ! -d "$DATA_DIR" ]]; then
    mkdir -p "$DATA_DIR"
fi

if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi

echo "0" > "$GITHUB_SYNC_RESULT_FILE"

# fetch github api
curl "$API_URL" -o "$REPO_FILE" || echo "1" > "$GITHUB_SYNC_RESULT_FILE"

# loop file and clone repos
cat "$REPO_FILE" | jq -r '.[] | .clone_url + " " + .name' | while read URL NAME ; do

    cd "$DATA_DIR"
    git clone "$URL" > /dev/null 2>&1 && echo "repo $NAME fresh cloned"

    # pull if already cloned
    if [[ "$?" != "0" ]]; then
            (cd "$NAME" ; git pull || echo "1" > "$GITHUB_SYNC_RESULT_FILE" )

    fi

done

# run notify action
if [[ "$(cat "$GITHUB_SYNC_RESULT_FILE")" == "0" ]]; then
    notify
fi
