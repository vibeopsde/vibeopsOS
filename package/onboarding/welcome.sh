#!/bin/bash
set -e

USERNAME=$(logname 2>/dev/null || who | awk '{print $1}' | head -1 || echo "ubuntu")
USER_HOME=$(eval echo ~$USERNAME)
TEMPLATES_DIR="$USER_HOME/vibeops/templates"

echo "=============================================="
echo "       Welcome to vibeopsOS!"
echo "=============================================="
echo ""
echo "OpenCode AI coding agent is ready."
echo "Your development environment is set up."
echo ""
echo "Project templates available at:"
echo "  ~/vibeops/templates/"
echo ""
echo "What would you like to create?"
echo ""
PS3="Select project type (1-4): "
options=("Web Project" "Python Project" "General Project" "Skip for now")
select opt in "${options[@]}"
do
    case $opt in
        "Web Project")
            echo "Creating web project..."
            mkdir -p "$USER_HOME/projects/my-web-app"
            cp -r "$TEMPLATES_DIR/web/"* "$USER_HOME/projects/my-web-app/"
            echo "  -> ~/projects/my-web-app/"
            break
            ;;
        "Python Project")
            echo "Creating python project..."
            mkdir -p "$USER_HOME/projects/my-python-app"
            cp -r "$TEMPLATES_DIR/python/"* "$USER_HOME/projects/my-python-app/"
            echo "  -> ~/projects/my-python-app/"
            break
            ;;
        "General Project")
            echo "Creating general project..."
            mkdir -p "$USER_HOME/projects/my-project"
            cp -r "$TEMPLATES_DIR/general/"* "$USER_HOME/projects/my-project/"
            echo "  -> ~/projects/my-project/"
            break
            ;;
        "Skip for now")
            echo "You can run 'opencode' anytime to start."
            break
            ;;
    esac
done

echo ""
echo "Ready! Run 'opencode .' in your project folder to start coding."
