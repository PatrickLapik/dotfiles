SESSION_NAME=${1:-"default"}

# Check if the session already exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Session '$SESSION_NAME' already exists. Attaching to it..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

case "$SESSION_NAME" in
    "kino")
        echo "Creating kinoprojekt session"
        tmux new-session -d -s "$SESSION_NAME" -n "nvim"
        tmux send-keys -t "$SESSION_NAME:1" "cd a4 && clear" C-m 
        tmux new-window -t "$SESSION_NAME:2" -n "docker"
        tmux split-window -h -t "$SESSION_NAME:2"  
        tmux send-keys -t "$SESSION_NAME:2.1" "cd a4 && clear" C-m 
        tmux send-keys -t "$SESSION_NAME:2.2" "cd a4 && clear" C-m 
        tmux new-window -t "$SESSION_NAME:3" -n "btop"
        tmux send-keys -t "$SESSION_NAME:3" "btop" C-m 
    ;;
    "zuzu")
        echo "Creating zuzu session"
        tmux new-session -d -s "$SESSION_NAME" -n "nvim"
        tmux send-keys -t "$SESSION_NAME:1" "cd adon && clear" C-m 
        tmux new-window -t "$SESSION_NAME:2" -n "docker"
        tmux split-window -h -t "$SESSION_NAME:2"  
        tmux send-keys -t "$SESSION_NAME:2.1" "cd adon && clear" C-m 
        tmux send-keys -t "$SESSION_NAME:2.2" "cd adon && clear" C-m 
        tmux new-window -t "$SESSION_NAME:3" -n "btop"
        tmux send-keys -t "$SESSION_NAME:3" "btop" C-m 
    ;;
    "phoenix")
        echo "Creating PhoenixWheels session"
        tmux new-session -d -s "$SESSION_NAME" -n "nvim"
        tmux send-keys -t "$SESSION_NAME:1" "cd phoenixwheels && clear" C-m 
        tmux new-window -t "$SESSION_NAME:2" -n "docker"
        tmux split-window -h -t "$SESSION_NAME:2"  
        tmux send-keys -t "$SESSION_NAME:2.1" "cd phoenixwheels && clear" C-m 
        tmux send-keys -t "$SESSION_NAME:2.2" "cd phoenixwheels && clear" C-m 
        tmux new-window -t "$SESSION_NAME:3" -n "btop"
        tmux send-keys -t "$SESSION_NAME:3" "btop" C-m 
    ;;
    "default")
        echo "Creating default session"
        tmux new-session -d -s "$SESSION_NAME" -n "nvim"
        tmux new-window -t "$SESSION_NAME:2" -n "zsh"
    ;;
    *)
        echo "Creating $SESSION_NAME session"
        tmux new-session -d -s "$SESSION_NAME" -n "nvim"
        tmux new-window -t "$SESSION_NAME:2" -n "zsh"
esac

tmux select-window -t "$SESSION_NAME:1"

tmux attach-session -t "$SESSION_NAME"
