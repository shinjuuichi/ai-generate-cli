#!/bin/bash

# AI Command Generator using Gemini API
# Add this to your ~/.bashrc or source it: source ~/path/to/ai-command.sh

# Version
VERSION="1.0.3"

# Config file location
AI_CONFIG_FILE="$HOME/.ai-command-config"
AI_VERSION_FILE="$HOME/.ai-command-version"

# GitHub repository
GITHUB_OWNER="shinjuuichi"
GITHUB_REPO="ai-generate-cli"

# Reload shell function (reload local file)
ai-reload() {
    echo "Reloading AI Command Generator from local file..."
    source ~/ai-command.sh
    echo "Successfully reloaded!"
}

# Get current installed version
_get_current_version() {
    if [ -f "$AI_VERSION_FILE" ]; then
        cat "$AI_VERSION_FILE"
    else
        echo "unknown"
    fi
}

# Save version to file
_save_version() {
    local version="$1"
    echo "$version" > "$AI_VERSION_FILE"
}

# List available versions from GitHub releases
ai-list-versions() {
    echo "Fetching available versions from GitHub..."
    local releases=$(curl -s "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases")
    
    if [ -z "$releases" ] || [ "$releases" = "[]" ]; then
        echo "No releases found."
        return 1
    fi
    
    echo ""
    echo "Available versions:"
    echo "=================="
    echo "$releases" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\(.*\)"/\1/' | nl
}

# Update function (fetch specific version or latest from GitHub releases)
ai-update() {
    local target_version="$1"
    local current_version=$(_get_current_version)
    
    echo "Current version: $current_version"
    echo ""
    
    if [ -z "$target_version" ]; then
        echo "Fetching available versions..."
        local releases=$(curl -s "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases")
        
        if [ -z "$releases" ] || [ "$releases" = "[]" ]; then
            echo "No releases found. Trying main branch..."
            curl -s -o ~/ai-command.sh "https://raw.githubusercontent.com/$GITHUB_OWNER/$GITHUB_REPO/main/ai-command.sh"
            chmod +x ~/ai-command.sh
            source ~/ai-command.sh
            echo "Successfully updated from main branch!"
            return 0
        fi
        
        # Get latest release
        local latest_version=$(echo "$releases" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/"tag_name": *"\(.*\)"/\1/')
        
        echo "Latest version available: $latest_version"
        echo ""
        echo "Options:"
        echo "1) Update to latest version ($latest_version)"
        echo "2) Choose specific version"
        echo "3) Cancel"
        read -p "Choose option (1/2/3): " -n 1 -r update_option
        echo ""
        
        if [[ $update_option == "1" ]]; then
            target_version="$latest_version"
        elif [[ $update_option == "2" ]]; then
            echo ""
            echo "Available versions:"
            echo "$releases" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\(.*\)"/\1/' | nl
            echo ""
            read -p "Enter version (e.g., v1.0.0 or 1.0.0): " target_version
            
            # Add 'v' prefix if not present
            if [[ ! "$target_version" =~ ^v ]]; then
                target_version="v$target_version"
            fi
        else
            echo "Update cancelled."
            return 0
        fi
    else
        # Add 'v' prefix if not present
        if [[ ! "$target_version" =~ ^v ]]; then
            target_version="v$target_version"
        fi
    fi
    
    echo ""
    echo "Downloading version $target_version..."
    
    # Download from release with -L flag to follow redirects
    local download_url="https://github.com/$GITHUB_OWNER/$GITHUB_REPO/releases/download/$target_version/ai-command.sh"
    local temp_file="/tmp/ai-command-download-$$.sh"
    local http_code=$(curl -L -s -o "$temp_file" -w "%{http_code}" "$download_url")
    
    if [ "$http_code" != "200" ]; then
        echo "Error: Version $target_version not found or download failed (HTTP $http_code)"
        echo "Use 'ai-list-versions' to see available versions."
        echo ""
        echo "Download URL attempted: $download_url"
        rm -f "$temp_file"
        return 1
    fi
    
    # Check if downloaded file is valid
    if [ ! -s "$temp_file" ]; then
        echo "Error: Downloaded file is empty"
        rm -f "$temp_file"
        return 1
    fi
    
    # Check if it's a valid shell script
    if ! head -n 1 "$temp_file" | grep -q "^#!/bin/bash"; then
        echo "Error: Downloaded file is not a valid bash script"
        rm -f "$temp_file"
        return 1
    fi
    
    # Move to final location
    mv "$temp_file" ~/ai-command.sh
    chmod +x ~/ai-command.sh
    _save_version "$target_version"
    source ~/ai-command.sh
    
    echo "Successfully updated to version $target_version!"
}

# Show current version
ai-version() {
    local current_version=$(_get_current_version)
    echo "AI Command Generator"
    echo "===================="
    echo "Current version: $current_version"
    echo "Script version: $VERSION"
    echo ""
    echo "Use 'ai-list-versions' to see all available versions"
    echo "Use 'ai-update' to update or change version"
    echo "Use 'ai-update <version>' to install specific version (e.g., ai-update 1.0.0)"
}

# Aliases for convenience
alias reload='ai-reload'
alias update='ai-update'
alias ai-ver='ai-version'

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
    echo "  - Remove the version file"
    echo "  - Remove the script file (~/ai-command.sh)"
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
        echo "Removed config file"
    fi
    
    # Remove version file
    if [ -f "$AI_VERSION_FILE" ]; then
        rm "$AI_VERSION_FILE"
        echo "Removed version file"
    fi
    
    # Remove from bashrc
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/source.*ai-command\.sh/d' "$HOME/.bashrc"
        echo "Removed from ~/.bashrc"
    fi
    
    # Unset functions and aliases
    unset -f ai aicmd ai-change ai-uninstall ai-reload ai-update ai-version ai-list-versions _load_api_key _save_api_key _get_current_version _save_version
    unalias aicmd 2>/dev/null
    unalias reload 2>/dev/null
    unalias update 2>/dev/null
    unalias ai-ver 2>/dev/null
    
    # Remove the script file itself
    if [ -f "$HOME/ai-command.sh" ]; then
        rm "$HOME/ai-command.sh"
        echo "Removed script file"
    fi
    
    echo ""
    echo "AI Command Generator uninstalled successfully!"
    echo "All files have been removed."
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
        echo "  ai-change          - Change API key"
        echo "  ai-reload          - Reload local script"
        echo "  ai-update          - Update to latest version or choose specific version"
        echo "  ai-update <ver>    - Install specific version (e.g., ai-update 1.0.0)"
        echo "  ai-version         - Show current version"
        echo "  ai-list-versions   - List all available versions"
        echo "  ai-uninstall       - Uninstall this tool"
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

    # Check for API key error first
    if echo "$response" | grep -q "API_KEY_INVALID\|API key not valid"; then
        echo "Error: Invalid API key"
        echo ""
        echo "Your API key is not valid or has expired."
        echo "Please update your API key to continue."
        echo ""
        read -p "Would you like to change your API key now? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ai-change
            echo ""
            echo "Please try your command again."
        else
            echo "You can change your API key anytime using: ai-change"
        fi
        return 1
    fi

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
