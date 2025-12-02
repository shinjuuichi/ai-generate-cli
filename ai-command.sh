#!/bin/bash

# AI Command Generator using Gemini API
# Add this to your ~/.bashrc or source it: source ~/path/to/ai-command.sh

ai() {
    # Check if GEMINI_API_KEY is set, if not prompt for it
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Gemini API key not found in environment."
        read -p "Enter your Gemini API key: " -s api_key
        echo ""
        if [ -z "$api_key" ]; then
            echo "Error: API key cannot be empty"
            return 1
        fi
        GEMINI_API_KEY="$api_key"
    fi

    # Check if user provided a description
    if [ -z "$*" ]; then
        echo "Usage: ai <description of what you want to do>"
        echo "Example: ai list all pdf files in current directory"
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
