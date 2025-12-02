# AI Shell Command Generator

Generate shell commands from natural language using Google's Gemini API.

## Quick Start

### 1. Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the key

### 2. Install

```bash
# Download and install
curl -o ~/ai-command.sh https://raw.githubusercontent.com/shinjuuichi/ai-generate-cli/main/ai-command.sh
chmod +x ~/ai-command.sh

# Add to your ~/.bashrc
echo "source ~/ai-command.sh" >> ~/.bashrc

# Reload your shell
source ~/.bashrc
```

### 3. First Use

Just run the `ai` command and it will guide you through setting up your API key:

```bash
ai list all pdf files
```

You'll be prompted to:

1. Enter your API key
2. Choose to save it permanently or just for this session

That's it! No manual configuration needed.

## Usage

### Basic Command

```bash
ai <description of what you want to do>
```

The tool will:

1. Generate the command using AI
2. Show you the command
3. Ask if you want to execute it

### Management Commands

```bash
ai-change      # Change your API key
ai-reload      # Reload local script
ai-update      # Update to latest version from GitHub
ai-uninstall   # Uninstall the tool
reload         # Alias for ai-reload
update         # Alias for ai-update
```

### Examples

```bash
# List all PDF files
ai list all pdf files in current directory

# Find large files
ai find files larger than 100MB

# Count lines of code
ai count lines in all python files

# Network operations
ai show my public ip address

# File operations
ai create a backup of all txt files

# Process management
ai show top 10 memory consuming processes

# Git operations
ai show git commits from last week

# Archive operations
ai compress all log files into a tar.gz
```

### Using the Alias

```bash
aicmd list all jpg images
```

## Features

- 🤖 Natural language to shell command conversion
- 💾 Flexible API key storage (permanent or session-based)
- Preview command before execution
- Safe confirmation prompt
- Works with bash and other shells
- OS-aware command generation
- Fast response using Gemini Flash
- Easy management commands (change key, reload, uninstall)
- Secure API key storage with proper file permissions
- Auto-update with `reload` command

## API Key Management

The tool offers flexible options for storing your API key:

### Option 1: Permanent Storage (Recommended)

- Saved in `~/.ai-command-config`
- Encrypted with proper file permissions (600)
- Automatically loaded on each use
- Best for regular use

### Option 2: Session-Only

- Stored in environment variable for current terminal session
- Not saved to disk
- Need to re-enter after closing terminal
- Best for shared machines or temporary use

### Changing Your API Key

````bash
## Uninstalling

To completely remove the tool:

```bash
ai-uninstall
````

This will:

- Remove your saved API key
- Remove the script from your ~/.bashrc
- Clean up all functions and aliases

## Troubleshooting

### "Failed to generate command"

- Check your internet connection
- Verify your API key is valid with `ai-change`
- Check if you've exceeded API quota at [Google AI Studio](https://makersuite.google.com/app/apikey)

### Command doesn't work as expected

- Try being more specific in your description
- Include the OS or shell type in your request
- Rephrase the request differently

### Want to change API key?

```bash
ai-change
```

### Script not loading after install?

```bash
source ~/.bashrc
# or
reload
```

### Want to reload the script?

```bash
reload
# or
ai-reload
```

This will reload the local script file.

### Want to update to the latest version?

```bash
update
# or
ai-update
```

This will automatically download and reload the latest version from GitHub.

## Requirements

- Bash shell (or compatible shell)
- curl command
- grep and sed utilities
- Internet connection
- Valid Gemini API key

## License

MIT
