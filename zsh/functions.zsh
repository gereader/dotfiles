# Git worktree helper function, create worktree directory, checkout/create branch specified
new-worktree() {
    local branch_name=$1
    local current_pwd=$(pwd)
    
    # If we're inside a worktrees directory, go up to the main repo
    if [[ "$current_pwd" == *"/worktrees/"* ]]; then
        # Extract everything before "/worktrees/" 
        local main_repo=$(echo "$current_pwd" | sed 's|/worktrees/.*||')
    else
       local main_repo="$current_pwd"
    fi

    # Pull latest changes on main/master
    echo "Pulling main/master branch..."
    git -C "$main_repo" pull origin main 2>/dev/null || git -C "$main_repo" pull origin master 2>/dev/null

    # Create worktrees directory at repo root
    mkdir -p "$main_repo/worktrees"
    
    if git show-ref --verify --quiet refs/heads/$branch_name; then
        git worktree add "$main_repo/worktrees/$branch_name" $branch_name
    else
        git worktree add "$main_repo/worktrees/$branch_name" -b $branch_name
    fi
    

    # Auto-add safe directory after creating worktree
    git config --global --add safe.directory "$main_repo/worktrees/$branch_name"

    echo "Created worktree at: $main_repo/worktrees/$branch_name"
}

# Remove worktree and the associated branch
rm-worktree() {
    local branch_name=$1
    local current_pwd=$(pwd)

    # If we're inside a worktrees directory, go up to the main repo
    if [[ "$current_pwd" == *"/worktrees/"* ]]; then
        # Extract everything before "/worktrees/" 
        local main_repo=$(echo "$current_pwd" | sed 's|/worktrees/.*||')
    else
       local main_repo="$current_pwd"
    fi

    # Move back to root
    cd "$main_repo"

    if [[ -d "$repo_root/worktrees/$branch_name" ]]; then
        git worktree remove "$main_repo/worktrees/$branch_name"
        echo "Removed worktree: $branch_name"
    else
        echo "Worktree '$main_repo/worktrees/$branch_name' not found"
    fi
}

# Stock price lookup, provide ticker symbol, case insensitive, this requires a finnhub api key
stonks() {
    TICKER=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    echo -n "$TICKER Current Price: \$" && curl -s "https://finnhub.io/api/v1/quote?symbol=$TICKER&token=$FINNHUB_API_KEY" | jq -r .c
}

# Wireshark opener, used to open multiple instances of Wireshark on a mac
wireshark-open() {
    (wireshark -r "$1" > /dev/null 2>&1 &)
}