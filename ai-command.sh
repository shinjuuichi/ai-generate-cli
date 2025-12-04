#!/bin/bash

# AI Command Generator using Gemini API
# Compatible with Bash and Zsh
# Add this to your ~/.bashrc or ~/.zshrc or source it: source ~/path/to/ai-command.sh

# Version
VERSION="5.0.8"

# Detect shell type
if [ -n "$BASH_VERSION" ]; then
    CURRENT_SHELL="bash"
elif [ -n "$ZSH_VERSION" ]; then
    CURRENT_SHELL="zsh"
else
    CURRENT_SHELL="unknown"
fi

# Config directory and files
AI_CONFIG_DIR="$HOME/.ai-command"
AI_CONFIG_FILE="$AI_CONFIG_DIR/config"
AI_VERSION_FILE="$AI_CONFIG_DIR/version"
AI_HISTORY_FILE="$AI_CONFIG_DIR/history"
AI_MODEL_FILE="$AI_CONFIG_DIR/model"
AI_CONTEXT_FILE="$AI_CONFIG_DIR/context"
AI_CONTEXT_HISTORY_FILE="$AI_CONFIG_DIR/context-history"
AI_USE_TREE_FILE="$AI_CONFIG_DIR/use-tree"
AI_MAX_TOKENS_FILE="$AI_CONFIG_DIR/max-tokens"
AI_VERSION_CHECK_FILE="$AI_CONFIG_DIR/version-check"

# Create config directory if it doesn't exist
if [ ! -d "$AI_CONFIG_DIR" ]; then
    mkdir -p "$AI_CONFIG_DIR"
fi

# Default Gemini model
DEFAULT_MODEL="gemini-2.5-flash"

# Default max output tokens
DEFAULT_MAX_TOKENS=2000

# Available Gemini models
GEMINI_MODELS=(
    "gemini-2.5-flash"
    "gemini-2.5-flash-lite"
    "gemini-2.5-pro"
    "gemini-2.0-flash"
    "gemini-2.0-flash-lite"
)

# ANSI Color codes
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'

# GitHub repository
GITHUB_OWNER="shinjuuichi"
GITHUB_REPO="ai-generate-cli"

# Reload shell function (reload local file)
ai-reload() {
    echo "Reloading AI Command Generator from local file..."
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        source ~/ai-command.sh 2>/dev/null || . ~/ai-command.sh
    else
        source ~/ai-command.sh
    fi
    echo "Successfully reloaded!"
}

# Shell-compatible read function for single character input
_read_single_char() {
    local prompt="$1"
    local varname="$2"
    
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        # Zsh doesn't support read -n, use read -k instead
        echo -n "$prompt"
        read -k 1 "$varname"
        echo
    else
        # Bash supports read -n
        read -p "$prompt" -n 1 -r "$varname"
        echo
    fi
}

# Shell-compatible read function for regular input
_read_input() {
    local prompt="$1"
    local varname="$2"
    local silent="$3"
    
    if [ "$silent" = "true" ]; then
        # Silent mode (for passwords)
        if [ "$CURRENT_SHELL" = "zsh" ]; then
            echo -n "$prompt"
            read -s "$varname"
            echo
        else
            read -p "$prompt" -s "$varname"
            echo
        fi
    else
        # Normal mode
        if [ "$CURRENT_SHELL" = "zsh" ]; then
            echo -n "$prompt"
            read "$varname"
        else
            read -p "$prompt" "$varname"
        fi
    fi
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

# Get current model
_get_current_model() {
    if [ -f "$AI_MODEL_FILE" ]; then
        cat "$AI_MODEL_FILE"
    else
        echo "$DEFAULT_MODEL"
    fi
}

# Save model to file
_save_model() {
    local model="$1"
    echo "$model" > "$AI_MODEL_FILE"
}

# Add command to history
_add_to_history() {
    local command="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $command" >> "$AI_HISTORY_FILE"
}

# Get current context (last 5 commands with results)
_get_context() {
    if [ -f "$AI_CONTEXT_HISTORY_FILE" ]; then
        tail -10 "$AI_CONTEXT_HISTORY_FILE" | paste -sd "; " -
    else
        echo ""
    fi
}

# Add to context history with result
_add_to_context() {
    local description="$1"
    local result="$2"
    if [ -n "$result" ]; then
        echo "$description | Result: $result" >> "$AI_CONTEXT_HISTORY_FILE"
    else
        echo "$description" >> "$AI_CONTEXT_HISTORY_FILE"
    fi
}

# Add command execution result to context
_add_execution_result() {
    local command="$1"
    local exit_code="$2"
    local output="$3"
    
    if [ "$exit_code" -eq 0 ]; then
        echo "Executed: $command | SUCCESS" >> "$AI_CONTEXT_HISTORY_FILE"
    else
        # Save error for AI to learn from
        local error_summary=$(echo "$output" | head -3 | tr '\n' ' ')
        echo "Executed: $command | ERROR (exit $exit_code): $error_summary" >> "$AI_CONTEXT_HISTORY_FILE"
    fi
}

# Clear context
_clear_context() {
    if [ -f "$AI_CONTEXT_HISTORY_FILE" ]; then
        rm "$AI_CONTEXT_HISTORY_FILE"
    fi
    if [ -f "$AI_CONTEXT_FILE" ]; then
        rm "$AI_CONTEXT_FILE"
    fi
}

# Check if should use directory tree
_should_use_tree() {
    if [ -f "$AI_USE_TREE_FILE" ]; then
        cat "$AI_USE_TREE_FILE"
    else
        echo ""
    fi
}

# Save tree preference
_save_tree_preference() {
    local use_tree="$1"
    echo "$use_tree" > "$AI_USE_TREE_FILE"
}

# Get current max tokens setting
_get_max_tokens() {
    if [ -f "$AI_MAX_TOKENS_FILE" ]; then
        cat "$AI_MAX_TOKENS_FILE"
    else
        echo "$DEFAULT_MAX_TOKENS"
    fi
}

# Save max tokens setting
_save_max_tokens() {
    local max_tokens="$1"
    echo "$max_tokens" > "$AI_MAX_TOKENS_FILE"
}

# Check if version check was done today
_should_check_version() {
    if [ ! -f "$AI_VERSION_CHECK_FILE" ]; then
        return 0  # Should check
    fi
    
    local last_check=$(cat "$AI_VERSION_CHECK_FILE")
    local today=$(date '+%Y-%m-%d')
    
    if [ "$last_check" != "$today" ]; then
        return 0  # Should check
    fi
    
    return 1  # Already checked today
}

# Mark version check as done today
_mark_version_checked() {
    local today=$(date '+%Y-%m-%d')
    echo "$today" > "$AI_VERSION_CHECK_FILE"
}

# Check for new version and prompt user
_check_for_update() {
    if ! _should_check_version; then
        return 0  # Already checked today
    fi
    
    local current_version=$(_get_current_version)
    
    # Fetch latest release info from GitHub silently
    local release_info=$(curl -s "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/latest")
    local latest_version=$(echo "$release_info" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/"tag_name": *"\(.*\)"/\1/')
    
    if [ -z "$latest_version" ]; then
        # Failed to check, mark as checked to avoid repeated failures
        _mark_version_checked
        return 0
    fi
    
    # Mark as checked regardless of outcome
    _mark_version_checked
    
    # Compare versions (remove 'v' prefix if present)
    local current_clean=$(echo "$current_version" | sed 's/^v//')
    local latest_clean=$(echo "$latest_version" | sed 's/^v//')
    
    if [ "$current_clean" != "$latest_clean" ] && [ "$current_version" != "unknown" ]; then
        echo ""
        _print_colored "$COLOR_YELLOW" "🔔 New version available: $latest_version (current: $current_version)"
        echo ""
        
        # Extract and display release notes/body
        local release_body=$(echo "$release_info" | sed -n '/"body":/,/"draft":/p' | sed '1d;$d' | sed 's/^[[:space:]]*"body": "//;s/",[[:space:]]*$//' | sed 's/\\n/\n/g' | sed 's/\\r//g' | head -20)
        
        if [ -n "$release_body" ]; then
            _print_colored "$COLOR_CYAN" "What's new in $latest_version:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "$release_body"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
        fi
        
        _read_single_char "Would you like to update now? (y/n) [default: n]: " update_reply
        local reply_lower=$(echo "$update_reply" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$reply_lower" == "y" ]]; then
            echo ""
            ai-update "$latest_version"
            return 1  # Return 1 to indicate update was performed
        else
            echo ""
            echo "You can update later using: ai-update"
            echo ""
        fi
    fi
    
    return 0
}

# Get directory tree (limited depth for context)
_get_directory_tree() {
    local max_depth=${1:-2}
    if command -v tree &> /dev/null; then
        tree -L "$max_depth" -a -I '.git|node_modules|venv|__pycache__|*.pyc|.env' 2>/dev/null || echo "Directory tree not available"
    else
        find . -maxdepth "$max_depth" -not -path '*/\.*' -not -path '*/node_modules/*' -not -path '*/venv/*' 2>/dev/null | head -50 || echo "Directory listing not available"
    fi
}

# Colorized output function
_print_colored() {
    local color="$1"
    local text="$2"
    if [ "$USE_COLOR" = "true" ]; then
        echo -e "${color}${text}${COLOR_RESET}"
    else
        echo "$text"
    fi
}

# Escape string for JSON
_escape_json() {
    local string="$1"
    # Replace backslash first (must be first to avoid double-escaping)
    string="${string//\\/\\\\}"
    # Replace double quotes
    string="${string//\"/\\\"}"
    # Replace newlines
    string="${string//$'\n'/\\n}"
    # Replace tabs
    string="${string//$'\t'/\\t}"
    # Replace carriage returns
    string="${string//$'\r'/\\r}"
    echo "$string"
}

# Offline fallback suggestions
_offline_suggest() {
    local description="$1"
    local suggestion=""
    
    case "$description" in
        *"list files"*|*"list file"*|*"show files"*)
            suggestion="ls -lah"
            ;;
        *"delete"*"log"*|*"remove"*"log"*)
            suggestion="find . -name '*.log' -type f -delete"
            ;;
        *"find large"*|*"large files"*)
            suggestion="find . -type f -size +100M -exec ls -lh {} \\;"
            ;;
        *"disk space"*|*"disk usage"*)
            suggestion="df -h"
            ;;
        *"memory"*|*"ram"*)
            suggestion="free -h"
            ;;
        *"process"*|*"running"*)
            suggestion="ps aux"
            ;;
        *"network"*|*"ip"*)
            suggestion="ip addr show"
            ;;
        *"count lines"*)
            suggestion="find . -type f -name '*.py' | xargs wc -l"
            ;;
        *)
            return 1
            ;;
    esac
    
    echo "$suggestion"
    return 0
}

# Fetch and display release notes for a specific version
_show_release_notes() {
    local version="$1"
    
    echo ""
    _print_colored "$COLOR_CYAN" "📋 What's new in $version:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Fetch release info from GitHub
    local release_info=$(curl -s "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/tags/$version")
    
    if [ -z "$release_info" ] || echo "$release_info" | grep -q '"message": *"Not Found"'; then
        _print_colored "$COLOR_YELLOW" "⚠ Release notes not available for this version"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        return 1
    fi
    
    # Extract release body (changelog)
    local release_body=$(echo "$release_info" | sed -n '/"body":/,/"draft":/p' | sed '1d;$d' | sed 's/^[[:space:]]*"body": "//;s/",[[:space:]]*$//' | sed 's/\\n/\n/g' | sed 's/\\r//g')
    
    if [ -n "$release_body" ]; then
        echo "$release_body"
    else
        _print_colored "$COLOR_YELLOW" "No detailed changelog available"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    return 0
}

# List available versions from GitHub releases
ai-ls() {
    local show_details="$1"
    
    echo "Fetching available versions from GitHub..."
    local releases=$(curl -s "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases")
    
    if [ -z "$releases" ] || [ "$releases" = "[]" ]; then
        echo "No releases found."
        return 1
    fi
    
    echo ""
    echo "Available versions:"
    echo "=================="
    
    # Parse and display versions
    local version_list=$(echo "$releases" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\(.*\)"/\1/')
    local count=1
    
    while IFS= read -r version; do
        if [ -n "$version" ]; then
            printf "%2d) %s" "$count" "$version"
            
            # Show brief description if available
            if [ "$show_details" = "-d" ] || [ "$show_details" = "--details" ]; then
                local release_name=$(echo "$releases" | grep -A 2 "\"tag_name\": \"$version\"" | grep '"name":' | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/')
                if [ -n "$release_name" ] && [ "$release_name" != "$version" ]; then
                    echo " - $release_name"
                else
                    echo ""
                fi
            else
                echo ""
            fi
            
            count=$((count + 1))
        fi
    done <<< "$version_list"
    
    echo ""
    echo "Use 'ai-ls -d' to see release names"
    echo "Use 'ai-update <version>' to see full changelog and install"
}

# Alias for backward compatibility
alias ai-list-versions='ai-ls'

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
        echo "1) Update to latest version ($latest_version) [default]"
        echo "2) Choose specific version"
        echo "3) Cancel"
        _read_single_char "Choose option (1/2/3) [default: 1]: " update_option
        
        # Default to option 1 if Enter is pressed or empty
        if [[ -z "$update_option" ]] || [[ "$update_option" == $'\n' ]] || [[ "$update_option" == "" ]]; then
            update_option="1"
        fi
        
        if [[ $update_option == "1" ]]; then
            target_version="$latest_version"
        elif [[ $update_option == "2" ]]; then
            echo ""
            echo "Available versions:"
            echo "$releases" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\(.*\)"/\1/' | nl
            echo ""
            _read_input "Enter version (e.g., v1.0.0 or 1.0.0): " target_version false
            
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
    
    # Show release notes before downloading
    _show_release_notes "$target_version"
    
    # Ask for confirmation before proceeding with download
    _read_single_char "Proceed with update to $target_version? (Y/n) [default: Y]: " proceed_reply
    local proceed_lower=$(echo "$proceed_reply" | tr '[:upper:]' '[:lower:]')
    
    if [[ -n "$proceed_reply" ]] && [[ "$proceed_lower" == "n" ]]; then
        echo "Update cancelled."
        return 0
    fi
    
    echo ""
    echo "Downloading version $target_version..."
    
    # Download from release with -L flag to follow redirects
    local download_url="https://github.com/$GITHUB_OWNER/$GITHUB_REPO/releases/download/$target_version/ai-command.sh"
    local temp_file="/tmp/ai-command-download-$$.sh"
    local http_code=$(curl -L -s -o "$temp_file" -w "%{http_code}" "$download_url")
    
    if [ "$http_code" != "200" ]; then
        echo "Error: Version $target_version not found or download failed (HTTP $http_code)"
        echo "Use 'ai-ls' to see available versions."
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
    echo "Use 'ai-ls' to see all available versions"
    echo "Use 'ai-update' to update or change version"
    echo "Use 'ai-update <version>' to install specific version (e.g., ai-update 1.0.0)"
}

# Show help
ai-help() {
    echo "AI Command Generator - Help"
    echo "============================"
    echo ""
    echo "BASIC USAGE:"
    echo "  ai <description>              Generate and optionally run a command"
    echo "  ai -y <description>           Auto-run without confirmation"
    echo "  ai --pretty <description>     Use colored output"
    echo "  ai --help                     Show this help message"
    echo ""
    echo "SCRIPT GENERATION:"
    echo "  ai-script <description>       Generate a full shell script"
    echo ""
    echo "COMMAND EXPLANATION:"
    echo "  ai-explain \"<command>\"        Explain what a command does"
    echo ""
    echo "MULTIPLE OPTIONS:"
    echo "  ai-multi <description>        Generate 3 different command variants"
    echo ""
    echo "HISTORY:"
    echo "  ai-history                    Show command history"
    echo "  ai-history -n <number>        Show last N commands"
    echo "  ai-history --clear            Clear history"
    echo ""
    echo "CONTEXT MANAGEMENT:"
    echo "  ai-new                        Clear context and start fresh topic"
    echo "  ai-tree [depth]               Show directory structure"
    echo ""
    echo "  Note: AI automatically learns from your commands!"
    echo "  Use 'ai-new' when switching to a different topic."
    echo ""
    echo "MODEL MANAGEMENT:"
    echo "  ai-model                      Show current model"
    echo "  ai-model ls                   List available Gemini models"
    echo "  ai-model <name>               Switch to a specific model"
    echo ""
    echo "API USAGE:"
    echo "  ai-usage                      Check API quota and rate limits"
    echo ""
    echo "CONFIGURATION:"
    echo "  ai-change                     Change API key"
    echo "  ai-reload                     Reload local script"
    echo "  ai-version                    Show version info"
    echo ""
    echo "UPDATE & MAINTENANCE:"
    echo "  ai-update                     Update to latest version (shows changelog)"
    echo "  ai-update <version>           Install specific version (shows changelog)"
    echo "  ai-ls                         List all available versions"
    echo "  ai-ls -d                      List versions with details"
    echo "  ai-uninstall                  Uninstall the tool"
    echo ""
    echo "EXAMPLES:"
    echo "  ai list all pdf files"
    echo "  ai -y delete old logs"
    echo "  ai-explain \"rm -rf /var/log/*\""
    echo "  ai-script backup home directory daily"
    echo ""
    echo "CONTEXT EXAMPLES (automatic learning):"
    echo "  ai install hydra                          # AI learns about hydra"
    echo "  ai brute force ssh                        # AI remembers context"
    echo "  ai wordlist for passwords                 # Still knows hydra"
    echo "  ai-new                                    # Start fresh topic"
    echo "  ai install nmap                           # New context begins"
    echo "  ai-tree 3                                 # Show directory structure"
    echo "  ai-multi list large files"
}

# View command history
ai-history() {
    if [ ! -f "$AI_HISTORY_FILE" ]; then
        echo "No command history found."
        return 0
    fi
    
    case "$1" in
        --clear)
            _read_single_char "Clear all command history? (y/n): " REPLY
            local reply_lower=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
            if [[ "$reply_lower" == "y" ]]; then
                rm "$AI_HISTORY_FILE"
                echo "Command history cleared."
            else
                echo "Operation cancelled."
            fi
            ;;
        -n)
            if [ -z "$2" ]; then
                echo "Error: Please specify number of commands to show"
                echo "Usage: ai-history -n <number>"
                return 1
            fi
            tail -n "$2" "$AI_HISTORY_FILE"
            ;;
        *)
            cat "$AI_HISTORY_FILE"
            ;;
    esac
}

# Model management
ai-model() {
    if [ -z "$1" ]; then
        local current_model=$(_get_current_model)
        echo "Current model: $current_model"
        echo ""
        echo "Use 'ai-model ls' to list available models"
        echo "Use 'ai-model <name>' to switch model"
        return 0
    fi
    
    if [ "$1" = "ls" ] || [ "$1" = "list" ]; then
        echo "Available Gemini models:"
        echo "========================"
        local current_model=$(_get_current_model)
        for model in "${GEMINI_MODELS[@]}"; do
            if [ "$model" = "$current_model" ]; then
                echo "* $model (current)"
            else
                echo "  $model"
            fi
        done
        echo ""
        echo "Use 'ai-model <name>' to switch model"
        return 0
    fi
    
    # Check if model is valid
    local new_model="$1"
    local valid=0
    for model in "${GEMINI_MODELS[@]}"; do
        if [ "$model" = "$new_model" ]; then
            valid=1
            break
        fi
    done
    
    if [ $valid -eq 0 ]; then
        echo "Error: Invalid model name '$new_model'"
        echo ""
        echo "Available models:"
        for model in "${GEMINI_MODELS[@]}"; do
            echo "  $model"
        done
        return 1
    fi
    
    _save_model "$new_model"
    echo "Model changed to: $new_model"
}

# Start new context (clear old context)
ai-new() {
    local old_context=$(_get_context)
    _clear_context
    
    if [ -z "$old_context" ]; then
        _print_colored "$COLOR_GREEN" "✓ Starting fresh session"
    else
        _print_colored "$COLOR_YELLOW" "Previous context cleared"
        _print_colored "$COLOR_GREEN" "✓ Starting fresh session"
    fi
    
    echo ""
    echo "AI will learn from your new commands automatically."
    echo "Use 'ai-new' again when you want to start a different topic."
}

# Show directory tree for context
ai-tree() {
    local depth=${1:-2}
    echo "Directory structure (depth: $depth):"
    echo "====================================="
    _get_directory_tree "$depth"
    echo ""
    echo "Use 'ai-tree <depth>' to see more levels"
    echo "This structure helps AI understand your project"
}

# Check API usage and quota limits
ai-usage() {
    _load_api_key
    
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Error: Gemini API key not found. Please run 'ai' first to set up your API key."
        return 1
    fi
    
    local current_model=$(_get_current_model)
    
    _print_colored "$COLOR_CYAN" "Checking API usage and rate limits..."
    echo ""
    
    # Test API with a minimal request to check if it's working
    local test_response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1/models/${current_model}:generateContent?key=$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -d '{
            "contents": [{
                "parts": [{
                    "text": "Say OK"
                }]
            }],
            "generationConfig": {
                "temperature": 0.1,
                "maxOutputTokens": 10
            }
        }')
    
    # Check for various error types
    if echo "$test_response" | grep -q "API_KEY_INVALID\|API key not valid"; then
        _print_colored "$COLOR_RED" "Status: Invalid API Key"
        echo ""
        echo "Your API key is not valid or has expired."
        echo "Please update your API key using: ai-change"
        return 1
    elif echo "$test_response" | grep -q "RESOURCE_EXHAUSTED\|quota exceeded\|rate limit"; then
        _print_colored "$COLOR_RED" "Status: Rate Limit Reached"
        echo ""
        echo "You have exceeded your API quota or rate limit."
        echo ""
        
        # Extract rate limit info if available
        local error_message=$(echo "$test_response" | grep -o '"message": *"[^"]*"' | head -1 | sed 's/"message": *"\(.*\)"/\1/')
        if [ -n "$error_message" ]; then
            _print_colored "$COLOR_YELLOW" "Error details:"
            echo "$error_message"
            echo ""
        fi
        
        echo "Rate limit information:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Gemini API uses the following limits:"
        echo ""
        echo "Free tier limits (may vary by model):"
        echo "  • Requests per minute: 15"
        echo "  • Requests per day: 1,500"
        echo "  • Tokens per minute: ~32,000"
        echo ""
        echo "What you can do:"
        echo "  1. Wait a few minutes and try again"
        echo "  2. Check your usage at: https://aistudio.google.com/"
        echo "  3. Consider upgrading to a paid plan"
        echo "  4. Switch to a different model with: ai-model ls"
        echo "  5. Change to a different API key"
        echo ""
        _read_single_char "Would you like to change your API key now? (y/n): " REPLY
        local reply_lower=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
        if [[ "$reply_lower" == "y" ]]; then
            ai-change
            echo ""
            echo "Please try your command again with the new API key."
        fi
        return 1
    elif echo "$test_response" | grep -q '"candidates"' && echo "$test_response" | grep -q '"content"'; then
        # Successfully got a response with content
        _print_colored "$COLOR_GREEN" "✓ Status: API Key Active & Working"
        echo ""
        
        # Extract token usage from response
        local prompt_tokens=$(echo "$test_response" | grep -o '"promptTokenCount": *[0-9]*' | grep -o '[0-9]*' | head -1)
        local candidates_tokens=$(echo "$test_response" | grep -o '"candidatesTokenCount": *[0-9]*' | grep -o '[0-9]*' | head -1)
        local total_tokens=$(echo "$test_response" | grep -o '"totalTokenCount": *[0-9]*' | grep -o '[0-9]*' | head -1)
        
        echo "API Information:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Current model: $current_model"
        echo "API Key: ${GEMINI_API_KEY:0:10}...${GEMINI_API_KEY: -4}"
        echo ""
        
        # Display token usage from test request
        if [ -n "$total_tokens" ]; then
            echo "Test Request Token Usage:"
            echo "  • Input tokens: ${prompt_tokens:-0}"
            echo "  • Output tokens: ${candidates_tokens:-0}"
            echo "  • Total tokens: $total_tokens"
            echo ""
        fi
        
        echo "Rate Limits (Free Tier):"
        echo "  • Requests per minute: ~15"
        echo "  • Requests per day: ~1,500"
        echo "  • Tokens per minute: ~32,000"
        echo ""
        
        # Calculate approximate remaining tokens for the day
        local daily_limit=1500
        echo "Daily Request Estimates:"
        echo "  • Total requests available: ~$daily_limit requests/day"
        echo "  • This varies by account and model tier"
        echo ""
        
        echo "Note: Actual limits may vary by model and account type."
        echo "      Google does not provide a direct API to check remaining quota."
        echo ""
        _print_colored "$COLOR_CYAN" "Monitor your usage at:"
        echo "https://aistudio.google.com/"
        echo ""
        _print_colored "$COLOR_YELLOW" "Tip: If you hit rate limits, try:"
        echo "  • Waiting a few minutes between requests"
        echo "  • Using 'ai-model' to switch to a lighter model"
        echo "  • Checking usage dashboard for detailed metrics"
        return 0
    else
        _print_colored "$COLOR_YELLOW" "⚠ Status: Unknown Response"
        echo ""
        echo "Received an unexpected response from the API."
        echo ""
        _print_colored "$COLOR_YELLOW" "Response details (first 10 lines):"
        echo "$test_response" | head -10
        echo ""
        _print_colored "$COLOR_YELLOW" "Full response length:"
        echo "$test_response" | wc -c
        echo ""
        echo "This might indicate:"
        echo "  • API service issues"
        echo "  • Network connectivity problems"
        echo "  • API endpoint changes"
        echo ""
        return 1
    fi
}

# Explain a command
ai-explain() {
    _load_api_key
    
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Error: Gemini API key not found. Please run 'ai' first to set up your API key."
        return 1
    fi
    
    if [ -z "$*" ]; then
        echo "Usage: ai-explain \"<command>\""
        echo "Example: ai-explain \"rm -rf /var/log/*\""
        return 1
    fi
    
    local command_to_explain="$*"
    local current_model=$(_get_current_model)
    
    local prompt="Explain this shell command in detail. Include:
1. What it does
2. Each part/flag explained
3. Potential risks or warnings
4. Example output (if applicable)

Command: $command_to_explain"

    # Escape prompt for JSON
    local escaped_prompt=$(_escape_json "$prompt")

    _print_colored "$COLOR_CYAN" "Analyzing command..."
    echo ""
    
    local response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1/models/${current_model}:generateContent?key=$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "{
            \"contents\": [{
                \"parts\": [{
                    \"text\": \"$escaped_prompt\"
                }]
            }],
            \"generationConfig\": {
                \"temperature\": 0.3,
                \"maxOutputTokens\": 2000
            }
        }")
    
    if echo "$response" | grep -q "API_KEY_INVALID\|API key not valid"; then
        echo "Error: Invalid API key. Use 'ai-change' to update your key."
        return 1
    fi
    
    local explanation=$(echo "$response" | grep -o '"text": *"[^"]*"' | head -1 | sed 's/"text": *"\(.*\)"/\1/' | sed 's/\\n/\n/g')
    
    if [ -z "$explanation" ]; then
        echo "Error: Failed to get explanation"
        return 1
    fi
    
    echo "$explanation"
}

# Generate multiple command options
ai-multi() {
    _load_api_key
    
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Error: Gemini API key not found. Please run 'ai' first to set up your API key."
        return 1
    fi
    
    if [ -z "$*" ]; then
        echo "Usage: ai-multi <description>"
        echo "Example: ai-multi list large files"
        return 1
    fi
    
    local description="$*"
    local shell_type=$(basename "$SHELL")
    local os_type=$(uname -s)
    local current_model=$(_get_current_model)
    
    local prompt="Generate 3 different shell command variants for $shell_type on $os_type that accomplish: $description

Format your response as:
Option 1: [command]
Option 2: [command]
Option 3: [command]

Each command should use a different approach or tool.
Keep commands concise and on one line each."

    # Escape prompt for JSON
    local escaped_prompt=$(_escape_json "$prompt")

    _print_colored "$COLOR_CYAN" "Generating multiple options..."
    echo ""
    
    local response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1/models/${current_model}:generateContent?key=$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "{
            \"contents\": [{
                \"parts\": [{
                    \"text\": \"$escaped_prompt\"
                }]
            }],
            \"generationConfig\": {
                \"temperature\": 0.5,
                \"maxOutputTokens\": 2000
            }
        }")
    
    if echo "$response" | grep -q "API_KEY_INVALID\|API key not valid"; then
        echo "Error: Invalid API key. Use 'ai-change' to update your key."
        return 1
    fi
    
    local options=$(echo "$response" | grep -o '"text": *"[^"]*"' | head -1 | sed 's/"text": *"\(.*\)"/\1/' | sed 's/\\n/\n/g')
    
    if [ -z "$options" ]; then
        echo "Error: Failed to generate options"
        return 1
    fi
    
    echo "$options"
    echo ""
    _read_input "Enter option number to execute (1-3), or press Enter to skip: " choice false
    
    if [[ "$choice" =~ ^[1-3]$ ]]; then
        local selected_command=$(echo "$options" | grep "^Option $choice:" | sed "s/Option $choice: //")
        if [ -n "$selected_command" ]; then
            echo ""
            _print_colored "$COLOR_GREEN" "Executing: $selected_command"
            eval "$selected_command"
            _add_to_history "$selected_command"
        fi
    fi
}

# Generate a full script
ai-script() {
    _load_api_key
    
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Error: Gemini API key not found. Please run 'ai' first to set up your API key."
        return 1
    fi
    
    if [ -z "$*" ]; then
        echo "Usage: ai-script <description>"
        echo "Example: ai-script backup home directory daily"
        return 1
    fi
    
    local description="$*"
    local shell_type=$(basename "$SHELL")
    local os_type=$(uname -s)
    local current_model=$(_get_current_model)
    
    local prompt="Generate a complete, production-ready POSIX-compatible shell script for $shell_type on $os_type that accomplishes: $description

Requirements:
- Include #!/bin/bash shebang
- Add error handling
- Include comments explaining each section
- Make it executable and safe
- Use best practices
- Return ONLY the script code, no explanations outside the script"

    # Escape prompt for JSON
    local escaped_prompt=$(_escape_json "$prompt")

    _print_colored "$COLOR_CYAN" "Generating script..."
    echo ""
    
    local response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1/models/${current_model}:generateContent?key=$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "{
            \"contents\": [{
                \"parts\": [{
                    \"text\": \"$escaped_prompt\"
                }]
            }],
            \"generationConfig\": {
                \"temperature\": 0.3,
                \"maxOutputTokens\": 4000
            }
        }")
    
    if echo "$response" | grep -q "API_KEY_INVALID\|API key not valid"; then
        echo "Error: Invalid API key. Use 'ai-change' to update your key."
        return 1
    fi
    
    local script=$(echo "$response" | grep -o '"text": *"[^"]*"' | head -1 | sed 's/"text": *"\(.*\)"/\1/' | sed 's/\\n/\n/g' | sed 's/```bash//g' | sed 's/```//g')
    
    if [ -z "$script" ]; then
        echo "Error: Failed to generate script"
        return 1
    fi
    
    echo "$script"
    echo ""
    _read_single_char "Save this script to a file? (y/n): " REPLY
    local reply_lower=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$reply_lower" == "y" ]]; then
        _read_input "Enter filename (e.g., backup.sh): " filename false
        if [ -n "$filename" ]; then
            echo "$script" > "$filename"
            chmod +x "$filename"
            _print_colored "$COLOR_GREEN" "Script saved to: $filename"
            _print_colored "$COLOR_GREEN" "Made executable. Run with: ./$filename"
        fi
    fi
}

# Aliases for convenience
alias reload='ai-reload'
alias update='ai-update'
alias ai-ver='ai-version'
alias aihelp='ai-help'

# Load API key from config file
_load_api_key() {
    if [ -f "$AI_CONFIG_FILE" ]; then
        source "$AI_CONFIG_FILE"
    fi
}

# Save API key to config file
_save_api_key() {
    local api_key="$1"
    mkdir -p "$AI_CONFIG_DIR"
    echo "export GEMINI_API_KEY='$api_key'" > "$AI_CONFIG_FILE"
    chmod 600 "$AI_CONFIG_FILE"
    echo "API key saved permanently to $AI_CONFIG_FILE"
}

# Change API key
ai-change() {
    echo "Change Gemini API Key"
    echo "===================="
    _read_input "Enter new API key: " new_key true
    if [ -z "$new_key" ]; then
        echo "Error: API key cannot be empty"
        return 1
    fi
    
    echo ""
    echo "How would you like to save this key?"
    echo "1) Save permanently (recommended) [default]"
    echo "2) Use for this session only"
    _read_single_char "Choose option (1/2) [default: 1]: " save_option
    
    # Default to option 1 if Enter is pressed or empty
    if [[ -z "$save_option" ]] || [[ "$save_option" == $'\n' ]] || [[ "$save_option" == "" ]]; then
        save_option="1"
    fi
    
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
    echo "  - Remove all configuration files"
    echo "  - Remove command history and context"
    echo "  - Remove the config directory (~/.ai-command/)"
    echo "  - Remove the script file (~/ai-command.sh)"
    echo "  - Remove lines from ~/.bashrc and ~/.zshrc (if present)"
    echo ""
    _read_single_char "Are you sure? (y/n): " REPLY
    local reply_lower=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
    
    if [[ ! "$reply_lower" == "y" ]]; then
        echo "Uninstall cancelled."
        return 0
    fi
    
    # Remove entire config directory
    if [ -d "$AI_CONFIG_DIR" ]; then
        rm -rf "$AI_CONFIG_DIR"
        echo "Removed config directory: $AI_CONFIG_DIR"
    fi
    
    # Remove from bashrc
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/source.*ai-command\.sh/d' "$HOME/.bashrc"
        echo "Removed from ~/.bashrc"
    fi
    
    # Remove from zshrc
    if [ -f "$HOME/.zshrc" ]; then
        sed -i '/source.*ai-command\.sh/d' "$HOME/.zshrc"
        echo "Removed from ~/.zshrc"
    fi
    
    # Unset functions and aliases
    unset -f ai aicmd ai-change ai-uninstall ai-reload ai-update ai-version ai-list-versions ai-help ai-history ai-model ai-usage ai-explain ai-multi ai-script ai-new ai-tree _load_api_key _save_api_key _get_current_version _save_version _get_current_model _save_model _add_to_history _print_colored _offline_suggest _get_context _add_to_context _add_execution_result _clear_context _should_use_tree _save_tree_preference _get_directory_tree
    unalias aicmd 2>/dev/null
    unalias reload 2>/dev/null
    unalias update 2>/dev/null
    unalias ai-ver 2>/dev/null
    unalias aihelp 2>/dev/null
    
    # Remove the script file itself
    if [ -f "$HOME/ai-command.sh" ]; then
        rm "$HOME/ai-command.sh"
        echo "Removed script file"
    fi
    
    echo ""
    echo "AI Command Generator uninstalled successfully!"
    echo "All files have been removed."
    echo ""
    echo "Reloading shell configuration..."
    
    # Automatically reload shell configuration
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        source ~/.zshrc 2>/dev/null || echo "Note: Please restart your terminal to complete uninstallation"
    else
        source ~/.bashrc 2>/dev/null || echo "Note: Please restart your terminal to complete uninstallation"
    fi
    
    echo "Uninstallation complete!"
}

ai() {
    # Parse flags
    local auto_run=false
    local use_pretty=false
    local args=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes)
                auto_run=true
                shift
                ;;
            --pretty)
                use_pretty=true
                shift
                ;;
            --help|-h)
                ai-help
                return 0
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done
    
    # Set color usage
    if [ "$use_pretty" = true ]; then
        USE_COLOR=true
    else
        USE_COLOR=false
    fi
    
    # Check for updates (only once per day)
    _check_for_update
    if [ $? -eq 1 ]; then
        # Update was performed, script was reloaded
        return 0
    fi
    
    # Load API key from config if exists
    _load_api_key
    
    # Check if GEMINI_API_KEY is set, if not prompt for it
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Gemini API key not found."
        echo ""
        _read_input "Enter your Gemini API key: " api_key true
        if [ -z "$api_key" ]; then
            echo "Error: API key cannot be empty"
            return 1
        fi
        
        echo ""
        echo "How would you like to save this key?"
        echo "1) Save permanently (recommended) [default]"
        echo "2) Use for this session only"
        _read_single_char "Choose option (1/2) [default: 1]: " save_option
        
        # Default to option 1 if Enter is pressed or empty
        if [[ -z "$save_option" ]] || [[ "$save_option" == $'\n' ]] || [[ "$save_option" == "" ]]; then
            save_option="1"
        fi
        
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
    if [ ${#args[@]} -eq 0 ]; then
        ai-help
        return 1
    fi

    # Get the user's shell command description
    local description="${args[*]}"
    
    # Detect the shell and OS
    local shell_type=$(basename "$SHELL")
    local os_type=$(uname -s)
    local current_model=$(_get_current_model)
    local current_context=$(_get_context)
    local use_tree=$(_should_use_tree)
    
    # First time use - ask about directory tree
    if [ -z "$use_tree" ]; then
        echo ""
        _print_colored "$COLOR_CYAN" "First time setup:"
        echo "Would you like AI to use your directory structure for better context?"
        echo "This helps AI understand your project and provide more relevant commands."
        echo ""
        _read_single_char "Use directory structure? (Y/n) [default: Y]: " tree_reply
        local tree_reply_lower=$(echo "$tree_reply" | tr '[:upper:]' '[:lower:]')
        
        if [[ -z "$tree_reply" ]] || [[ "$tree_reply_lower" == "y" ]] || [[ "$tree_reply" == $'\n' ]]; then
            _save_tree_preference "yes"
            use_tree="yes"
            echo "✓ Directory structure enabled"
        else
            _save_tree_preference "no"
            use_tree="no"
            echo "✓ Directory structure disabled"
        fi
        echo ""
    fi
    
    # Build context-aware prompt
    local context_hint=""
    if [ -n "$current_context" ]; then
        context_hint="\n\nPrevious commands and their results: $current_context"
        context_hint="$context_hint\nUse this context to understand what the user is working on, what succeeded, what failed, and provide relevant commands. If previous commands had errors, suggest fixes."
    fi
    
    # Add directory tree if enabled
    local tree_hint=""
    if [ "$use_tree" = "yes" ]; then
        local dir_structure=$(_get_directory_tree 2)
        if [ -n "$dir_structure" ] && [ "$dir_structure" != "Directory tree not available" ]; then
            tree_hint="\n\nCurrent directory structure:\n$dir_structure"
        fi
    fi
    
    # Save current description to context
    _add_to_context "$description"
    
    # Create the prompt for Gemini
    local prompt="You are a shell command expert. Generate ONLY the shell command for $shell_type on $os_type that does the following: $description${context_hint}${tree_hint}

Rules:
- Return ONLY the command, no explanations
- No markdown formatting, no code blocks
- No extra text before or after
- Make it a single line command when possible
- Use common, safe commands"

    # Escape prompt for JSON
    local escaped_prompt=$(_escape_json "$prompt")

    # Get max tokens setting
    local max_tokens=$(_get_max_tokens)

    # Make API call to Gemini
    local response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1/models/${current_model}:generateContent?key=$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "{
            \"contents\": [{
                \"parts\": [{
                    \"text\": \"$escaped_prompt\"
                }]
            }],
            \"generationConfig\": {
                \"temperature\": 0.2,
                \"maxOutputTokens\": $max_tokens
            }
        }")

    # Check for API key error first
    if echo "$response" | grep -q "API_KEY_INVALID\|API key not valid"; then
        echo "Error: Invalid API key"
        echo ""
        echo "Your API key is not valid or has expired."
        echo "Please update your API key to continue."
        echo ""
        _read_single_char "Would you like to change your API key now? (y/n): " REPLY
        local reply_lower=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
        if [[ "$reply_lower" == "y" ]]; then
            ai-change
            echo ""
            echo "Please try your command again."
        else
            echo "You can change your API key anytime using: ai-change"
        fi
        return 1
    fi

    # Check for MAX_TOKENS error (output limit exceeded)
    if echo "$response" | grep -q '"finishReason": *"MAX_TOKENS"'; then
        local current_limit=$(_get_max_tokens)
        _print_colored "$COLOR_RED" "Error: Token limit exceeded"
        echo ""
        echo "The API response was truncated because it exceeded the maximum token limit."
        echo "Current limit: $current_limit tokens"
        echo ""
        echo "What would you like to do?"
        echo "1) Increase limit by 1000 tokens (to $((current_limit + 1000))) [default]"
        echo "2) Set custom limit"
        echo "3) Clear context and retry with current limit"
        echo "4) Cancel"
        _read_single_char "Choose option (1/2/3/4) [default: 1]: " limit_option
        
        # Default to option 1 if Enter is pressed or empty
        if [[ -z "$limit_option" ]] || [[ "$limit_option" == $'\n' ]] || [[ "$limit_option" == "" ]]; then
            limit_option="1"
        fi
        
        if [[ $limit_option == "1" ]]; then
            local new_limit=$((current_limit + 1000))
            _save_max_tokens "$new_limit"
            _print_colored "$COLOR_GREEN" "✓ Token limit increased to $new_limit"
            echo "Please try your command again."
        elif [[ $limit_option == "2" ]]; then
            _read_input "Enter new token limit (current: $current_limit): " new_limit false
            if [[ "$new_limit" =~ ^[0-9]+$ ]] && [ "$new_limit" -gt 0 ]; then
                _save_max_tokens "$new_limit"
                _print_colored "$COLOR_GREEN" "✓ Token limit set to $new_limit"
                echo "Please try your command again."
            else
                echo "Invalid input. Token limit not changed."
            fi
        elif [[ $limit_option == "3" ]]; then
            _clear_context
            _print_colored "$COLOR_GREEN" "✓ Context cleared"
            echo "Please try your command again."
        else
            echo "Operation cancelled."
        fi
        return 1
    fi

    # Extract the command from the response
    local command=$(echo "$response" | grep -o '"text": *"[^"]*"' | head -1 | sed 's/"text": *"\(.*\)"/\1/' | sed 's/\\n/ /g')

    # Check if we got a valid response
    if [ -z "$command" ]; then
        _print_colored "$COLOR_YELLOW" "API request failed. Trying offline suggestion..."
        command=$(_offline_suggest "$description")
        if [ $? -ne 0 ]; then
            echo "Error: Failed to generate command and no offline suggestion available"
            echo "API Response: $response"
            return 1
        fi
        _print_colored "$COLOR_YELLOW" "Using offline suggestion:"
    fi

    # Display the generated command
    if [ "$use_pretty" = true ]; then
        _print_colored "$COLOR_GREEN" "Generated command:"
        _print_colored "$COLOR_CYAN" "$command"
    else
        echo "Generated command:"
        echo "$command"
    fi
    echo ""
    
    # Save to history
    _add_to_history "$command"
    
    # Execute based on auto_run flag
    if [ "$auto_run" = true ]; then
        _print_colored "$COLOR_GREEN" "Executing automatically..."
        # Capture output and exit code
        local output
        local exit_code
        output=$(eval "$command" 2>&1)
        exit_code=$?
        echo "$output"
        # Save execution result to context
        _add_execution_result "$command" "$exit_code" "$output"
    else
        # Ask user if they want to execute it
        _read_single_char "Execute this command? (Y/n) [default: Y]: " REPLY
        # Default to Yes if Enter is pressed or empty, case-insensitive Y
        local reply_lower=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
        if [[ -z "$REPLY" ]] || [[ "$REPLY" == $'\n' ]] || [[ "$REPLY" == "" ]] || [[ "$reply_lower" == "y" ]]; then
            # Capture output and exit code
            local output
            local exit_code
            output=$(eval "$command" 2>&1)
            exit_code=$?
            echo "$output"
            # Save execution result to context
            _add_execution_result "$command" "$exit_code" "$output"
        else
            echo "Command not executed. You can copy it from above."
        fi
    fi
}

# Alias for convenience
alias aicmd='ai'
