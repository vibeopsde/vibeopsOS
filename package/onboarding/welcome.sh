#!/bin/bash
set -e

USER_HOME=$(eval echo ~$(logname 2>/dev/null || echo "ubuntu"))

echo "=============================================="
echo "       Welcome to vibeopsOS!"
echo "=============================================="
echo ""
echo "OpenCode AI coding agent is ready."
echo "Your development environment is set up."
echo ""
echo "Project templates available at:"
echo "  ~/vibeops/projects/"
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
            mkdir -p $USER_HOME/projects/web-new
            cp -r $USER_HOME/vibeops/projects/web/* $USER_HOME/projects/web-new/
            break
            ;;
        "Python Project")
            echo "Creating python project..."
            mkdir -p $USER_HOME/projects/python-new
            cp -r $USER_HOME/vibeops/projects/python/* $USER_HOME/projects/python-new/
            break
            ;;
        "General Project")
            echo "Creating general project..."
            mkdir -p $USER_HOME/projects/general-new
            cp -r $USER_HOME/vibeops/projects/general/* $USER_HOME/projects/general-new/
            break
            ;;
        "Skip for now")
            echo "You can run 'opencode' anytime to start."
            break
            ;;
    esac
done

echo ""
echo "Ready! Run 'opencode' to start coding."