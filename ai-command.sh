#!/bin/bash

# AI Command Generator using Gemini API
# Add this to your ~/.bashrc or source it: source ~/path/to/ai-command.sh

# Config file location
AI_CONFIG_FILE="$HOME/.ai-command-config"

# Reload shell function
ai-reload() {
    echo "Reloading AI Command Generator..."
    curl -s -o ~/ai-command.sh https://raw.githubusercontent.com/shinjuuichi/ai-generate-cli/main/ai-command.sh
    chmod +x ~/ai-command.sh
    source ~/ai-command.sh
    echo "✓ Successfully reloaded!"
}

# Alias for convenience
alias reload='ai-reload'

# Load API key from config file
_load_api_key() {
    if [ -f "$AI_CONFIG_FILE" ]; then
        source "$AI_CONFIG_FILE"
    fi
}

# Save API key to config file
_save_api_key() {
    local api_key="$1"
    echo "export GEMINI_API_KEY='$api_key'" > "$AI_CONFIG_FILE"
    chmod 600 "$AI_CONFIG_FILE"
    echo "API key saved permanently to $AI_CONFIG_FILE"
}

# Change API key
ai-change() {
    echo "Change Gemini API Key"
    echo "===================="
    read -p "Enter new API key: " -s new_key
    echo ""
    if [ -z "$new_key" ]; then
        echo "Error: API key cannot be empty"
        return 1
    fi
    
    echo ""
    echo "How would you like to save this key?"
    echo "1) Save permanently (recommended)"
    echo "2) Use for this session only"
    read -p "Choose option (1/2): " -n 1 -r save_option
    echo ""
    
    if [[ $save_option == "1" ]]; then
        _save_api_key "$new_key"
        export GEMINI_API_KEY="$new_key"
    elif [[ $save_option == "2" ]]; then
        export GEMINI_API_KEY="$new_key"
        echo "API key set for current session only"
    else
        echo "Invalid option. API key not saved."
        return 1
    fi
    
    echo "API key updated successfully!"
}

# Uninstall tool
ai-uninstall() {
    echo "Uninstall AI Command Generator"
    echo "==============================="
    echo "This will:"
    echo "  - Remove the saved API key"
    echo "  - Remove lines from ~/.bashrc"
    echo ""
    read -p "Are you sure? (y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        return 0
    fi
    
    # Remove config file
    if [ -f "$AI_CONFIG_FILE" ]; then
        rm "$AI_CONFIG_FILE"
        echo "✓ Removed config file"
    fi
    
    # Remove from bashrc
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/source.*ai-command\.sh/d' "$HOME/.bashrc"
        echo "✓ Removed from ~/.bashrc"
    fi
    
    # Unset functions and aliases
    unset -f ai aicmd ai-change ai-uninstall ai-reload _load_api_key _save_api_key
    unalias aicmd 2>/dev/null
    unalias reload 2>/dev/null
    
    echo ""
    echo "AI Command Generator uninstalled successfully!"
    echo "Please restart your terminal or run: source ~/.bashrc"
}

ai() {
    # Load API key from config if exists
    _load_api_key
    
    # Check if GEMINI_API_KEY is set, if not prompt for it
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Gemini API key not found."
        echo ""
        read -p "Enter your Gemini API key: " -s api_key
        echo ""
        if [ -z "$api_key" ]; then
            echo "Error: API key cannot be empty"
            return 1
        fi
        
        echo ""
        echo "How would you like to save this key?"
        echo "1) Save permanently (recommended)"
        echo "2) Use for this session only"
        read -p "Choose option (1/2): " -n 1 -r save_option
        echo ""
        
        if [[ $save_option == "1" ]]; then
            _save_api_key "$api_key"
            export GEMINI_API_KEY="$api_key"
        elif [[ $save_option == "2" ]]; then
            export GEMINI_API_KEY="$api_key"
            echo "API key set for current session only"
        else
            echo "Invalid option. Using key for this session only."
            export GEMINI_API_KEY="$api_key"
        fi
        echo ""
    fi

    # Check if user provided a description
    if [ -z "$*" ]; then
        echo "Usage: ai <description of what you want to do>"
        echo "Example: ai list all pdf files in current directory"
        echo ""
        echo "Other commands:"
        echo "  ai-change     - Change API key"
        echo "  ai-reload     - Reload/update the script"
        echo "  ai-uninstall  - Uninstall this tool"
        return 1
    fi

    # Get the user's shell command description
    local description="$*"
    
    # Detect the shell and OS
    local shell_type=$(basename "$SHELL")
    local os_type=$(uname -s)
    
    # Create the prompt for Gemini
    local prompt="You are a shell command expert. Generate ONLY the shell command for $shell_type on $os_type that does the following: $description

Rules:
- Return ONLY the command, no explanations
- No markdown formatting, no code blocks
- No extra text before or after
- Make it a single line command when possible
- Use common, safe commands"

    # Make API call to Gemini
    local response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "{
            \"contents\": [{
                \"parts\": [{
                    \"text\": \"$prompt\"
                }]
            }],
            \"generationConfig\": {
                \"temperature\": 0.2,
                \"maxOutputTokens\": 2000
            }
        }")

    # Extract the command from the response
    local command=$(echo "$response" | grep -o '"text": *"[^"]*"' | head -1 | sed 's/"text": *"\(.*\)"/\1/' | sed 's/\\n/ /g')

    # Check if we got a valid response
    if [ -z "$command" ]; then
        echo "Error: Failed to generate command"
        echo "API Response: $response"
        return 1
    fi

    # Display the generated command
    echo "Generated command:"
    echo "$command"
    echo ""
    
    # Ask user if they want to execute it
    read -p "Execute this command? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        eval "$command"
    else
        echo "Command not executed. You can copy it from above."
    fi
}

# Alias for convenience
alias aicmd='ai'
