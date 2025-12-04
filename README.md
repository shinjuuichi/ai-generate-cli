# AI Shell Command Generator

Generate shell commands from natural language using Google's Gemini API.

## Quick Start

### 1. Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the key

### 2. Install

#### For Bash (Ubuntu, Debian, etc.)

##### Quick Install (Latest Version)

```bash
bash -c 'VERSION=$(curl -s https://api.github.com/repos/shinjuuichi/ai-generate-cli/releases/latest | grep "tag_name" | sed -E "s/.*\"([^\"]+)\".*/\1/") && \
curl -L -o ~/ai-command.sh "https://github.com/shinjuuichi/ai-generate-cli/releases/download/$VERSION/ai-command.sh" && \
chmod +x ~/ai-command.sh && \
echo "source ~/ai-command.sh" >> ~/.bashrc' && source ~/.bashrc && source ~/ai-command.sh
```

##### Install Specific Version

View all available versions: [Releases](https://github.com/shinjuuichi/ai-generate-cli/releases)

```bash
# You can replace v1.0.0 with any version tag you want to install
VERSION="v1.0.0" bash -c 'curl -L -o ~/ai-command.sh "https://github.com/shinjuuichi/ai-generate-cli/releases/download/$VERSION/ai-command.sh" && \
chmod +x ~/ai-command.sh && \
echo "source ~/ai-command.sh" >> ~/.bashrc' && source ~/.bashrc && source ~/ai-command.sh
```

#### For Zsh (Kali Linux, macOS, etc.)

##### Quick Install (Latest Version)

```zsh
zsh -c 'VERSION=$(curl -s https://api.github.com/repos/shinjuuichi/ai-generate-cli/releases/latest | grep "tag_name" | sed -E "s/.*\"([^\"]+)\".*/\1/") && \
curl -L -o ~/ai-command.sh "https://github.com/shinjuuichi/ai-generate-cli/releases/download/$VERSION/ai-command.sh" && \
chmod +x ~/ai-command.sh && \
echo "source ~/ai-command.sh" >> ~/.zshrc' && source ~/.zshrc && source ~/ai-command.sh
```

##### Install Specific Version

View all available versions: [Releases](https://github.com/shinjuuichi/ai-generate-cli/releases)

```zsh
# You can replace v2.0.0 with any version tag you want to install
VERSION="v2.0.0" zsh -c 'curl -L -o ~/ai-command.sh "https://github.com/shinjuuichi/ai-generate-cli/releases/download/$VERSION/ai-command.sh" && \
chmod +x ~/ai-command.sh && \
echo "source ~/ai-command.sh" >> ~/.zshrc' && source ~/.zshrc && source ~/ai-command.sh
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

### Basic Commands

```bash
# Standard usage
ai <description of what you want to do>

# Auto-run without confirmation
ai -y <description>

# Pretty colored output
ai --pretty <description>

# Show help
ai --help
```

The basic `ai` tool will:

1. Generate the command using AI
2. Show you the command
3. Ask if you want to execute it (unless using `-y` flag)

### 📜 Command History

Track and review all commands you've generated:

```bash
# View all history
ai-history

# View last 10 commands
ai-history -n 10

# Clear history
ai-history --clear
```

### 📝 Script Generation

Generate complete, production-ready shell scripts:

```bash
ai-script <description>

# Example
ai-script backup home directory daily
ai-script monitor system resources and send email alerts
ai-script batch convert images to webp format
```

The generated script will include:

- Shebang and proper structure
- Error handling
- Comments and documentation
- Best practices

### 🔍 Command Explanation

Understand what a command does before running it:

```bash
ai-explain "<command>"

# Examples
ai-explain "rm -rf /var/log/*"
ai-explain "find . -type f -name '*.log' -mtime +30 -delete"
ai-explain "curl -X POST https://api.example.com/data"
```

Returns:

- What the command does
- Explanation of each part/flag
- Potential risks and warnings
- Example output

### 🎯 Multiple Command Options

Get 3 different ways to accomplish the same task:

```bash
ai-multi <description>

# Example
ai-multi list large files
ai-multi find duplicate files
ai-multi monitor disk usage
```

Choose which variant to execute interactively.

### 🤖 Model Management

Switch between different Gemini models for speed vs. capability:

```bash
# Show current model
ai-model

# List available models
ai-model ls

# Switch model
ai-model gemini-2.5-pro
ai-model gemini-2.5-flash
```

Available models:

- `gemini-2.5-flash` (default) - Best price-performance, ideal for large scale processing and agentic tasks
- `gemini-2.5-flash-lite` - Fastest model optimized for cost-efficiency and high throughput
- `gemini-2.5-pro` - Advanced thinking model for complex reasoning in code, math, and STEM
- `gemini-2.0-flash` - Second generation workhorse with 1M token context window
- `gemini-2.0-flash-lite` - Second generation fast model with 1M token context window

### 🧠 Context Management

AI automatically learns from your commands - no manual setup needed!

```bash
# Just use AI normally - it learns automatically
ai install hydra
ai brute force ssh                    # AI remembers you're working with hydra
ai check wordlist                     # Still in hydra context
ai save results                       # Knows what you're doing

# AI learns from errors too!
ai configure hydra                    # ERROR: command fails
ai fix it                             # AI remembers the error and suggests a fix

# Start fresh topic when switching tasks
ai-new
ai install docker                     # Fresh context, focuses on docker
ai list containers                    # AI knows you're in docker context now

# View directory structure (helps AI understand your project)
ai-tree           # Shows 2 levels deep
ai-tree 3         # Shows 3 levels deep
```

**How it works:**

- **Automatic Learning**: AI remembers your last 10 commands with their results (success/errors)
- **Smart Context**: Each command builds on previous ones, including what worked and what failed
- **Error Awareness**: If a command fails, AI knows and can suggest fixes automatically
- **Easy Reset**: Use `ai-new` when switching to a different topic or tool
- **Directory Awareness**: First time you use `ai`, it asks if you want to use directory structure for better context
- **No Manual Setup**: Just use `ai` normally, context is automatic!

**Example workflow:**

```bash
# Penetration testing session
ai install hydra                  # AI learns: working with hydra
ai brute force ssh port 22        # Context: hydra + ssh
ai use rockyou wordlist           # Context: hydra + wordlists
ai save output to file            # Context: hydra + results

# If a command fails, AI learns and helps fix it
ai install hydra                  # ERROR: package not found
ai fix the error                  # AI knows about the error and suggests: apt update && apt install hydra

# Switch to different task
ai-new                            # Clear old context
ai create docker container        # New context starts
ai mount volume                   # Remembers docker context
```

**First-time setup:**
When you first use `ai`, you'll be asked:

> "Would you like AI to use your directory structure for better context?"

This helps AI understand your project structure and provide more relevant commands.

### 📊 API Usage Check

Monitor your API key status and rate limits:

```bash
ai-usage
```

This command will:

- Check if your API key is valid and active
- Display current rate limits for your tier
- Show which model you're currently using
- Provide helpful information if you've hit rate limits
- Give tips on managing API quota

Perfect for:

- Checking why requests are failing
- Monitoring before bulk operations
- Understanding your current API limits

### Management Commands

```bash
ai-change            # Change your API key
ai-usage             # Check API usage and rate limits
ai-reload            # Reload local script
ai-update            # Update to latest version (shows changelog)
ai-update <version>  # Install specific version (shows changelog)
ai-version           # Show current version
ai-ls                # List all available versions
ai-ls -d             # List versions with details
ai-uninstall         # Uninstall the tool
reload               # Alias for ai-reload
update               # Alias for ai-update
ai-ver               # Alias for ai-version
```

### Examples

#### Basic Usage

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
```

#### Advanced Usage

```bash
# Auto-run mode (no confirmation)
ai -y delete log files older than 30 days

# Pretty output with colors
ai --pretty show disk usage by directory

# Check API usage and limits
ai-usage

# Generate a script
ai-script create daily backup with rotation

# Explain a dangerous command
ai-explain "dd if=/dev/zero of=/dev/sda"

# Get multiple options
ai-multi compress large files
```

#### Git Operations

```bash
ai show git commits from last week
ai create a new branch from main
ai revert last commit safely
```

#### Archive Operations

```bash
ai compress all log files into a tar.gz
ai extract tar.gz file preserving permissions
```

### Using the Alias

```bash
aicmd list all jpg images
aihelp  # Show help
```

## Features

### Core Features

- Natural language to shell command conversion
- **Shell Compatibility** - Works with both Bash and Zsh
- Preview command before execution
- Safe confirmation prompt
- OS-aware command generation (Linux, macOS, etc.)
- Fast response using Gemini models

### Other Features

- **Zsh Support** - Full compatibility with Zsh (Kali Linux, macOS default)
- **Shell Auto-detection** - Automatically detects and adapts to your shell
- Improved installation for both Bash and Zsh users
- **Automatic Context Learning** - AI learns from commands AND their results (success/errors)
- **Error-Aware AI** - AI remembers failures and can suggest fixes
- **Command History Tracking** - Never lose a generated command
- **Auto-run Mode** - Skip confirmation with `-y` flag
- **Script Generation** - Create full scripts, not just one-liners
- **Command Explanation** - Understand risks before running
- **Multiple Options** - See different approaches to the same task
- **Directory Tree Integration** - AI understands your project structure
- **Offline Fallback** - Basic suggestions when API is down
- **Pretty Output** - Color-coded display with `--pretty`
- **Model Selection** - Choose the right model for your needs

### Version Management

- Easy upgrade/downgrade between versions
- List all available versions
- Install specific version directly
- Auto-update with `reload` command

### Security

- Flexible API key storage (permanent or session-based)
- Secure API key storage with proper file permissions (600)
- Command preview before execution
- Risk warnings in explanations

## 🔌 Offline Fallback

When the API is unavailable, the tool provides basic suggestions for common tasks:

- List files
- Delete logs
- Find large files
- Check disk space
- View memory usage
- Show processes
- Network info
- Count lines of code

## API Key Management

The tool offers flexible options for storing your API key:

### Option 1: Permanent Storage (Recommended)

- Saved in `~/.ai-command/config`
- All config files organized in `~/.ai-command/` directory
- Encrypted with proper file permissions (600)
- Automatically loaded on each use
- Best for regular use

### Option 2: Session-Only

- Stored in environment variable for current terminal session
- Not saved to disk
- Need to re-enter after closing terminal
- Best for shared machines or temporary use

### Changing Your API Key

```bash
ai-change
```

## Uninstalling

To completely remove the tool:

```bash
ai-uninstall
```

This will:

- Remove your saved API key
- Remove command history
- Remove model configuration
- Remove context data
- Remove the config directory (`~/.ai-command/`)
- Remove the script from your ~/.bashrc
- Clean up all functions and aliases

## Troubleshooting

### "Failed to generate command"

- Check your internet connection
- Verify your API key is valid with `ai-change`
- Check if you've exceeded API quota at [Google AI Studio](https://makersuite.google.com/app/apikey)

### Command doesn't work as expected

### "Failed to generate command"

- Check your internet connection
- Verify your API key is valid with `ai-change`
- Check if you've exceeded API quota at [Google AI Studio](https://makersuite.google.com/app/apikey)
- If offline, the tool will try to provide a basic suggestion

### Command doesn't work as expected

- Try being more specific in your description
- Include the OS or shell type in your request
- Rephrase the request differently
- Try `ai-multi` to see alternative approaches
- Use `ai-explain` to understand what the command does first

### Want to see what a command does?

```bash
ai-explain "command here"
```

### Want multiple options for the same task?

```bash
ai-multi your task description
```

### Want to check command history?

```bash
ai-history          # View all
ai-history -n 20    # Last 20
ai-history --clear  # Clear history
```

### Want to change API key?

```bash
ai-change
```

### Want to switch Gemini model?

```bash
ai-model ls          # List available models
ai-model gemini-1.5-pro  # Switch to specific model
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

This will:

- Show you what's new in the version (changelog)
- Let you choose to update to latest, pick a specific version, or cancel
- Display release notes before downloading

### Want to install a specific version or downgrade?

```bash
# Interactive selection with changelog
ai-update

# Direct version install (shows changelog before download)
ai-update 1.1.0
# or
ai-update v1.1.0

# List all available versions first
ai-ls

# List versions with details
ai-ls -d
```

### Want to check your current version?

```bash
ai-version
# or
ai-ver
```

## Command Reference

### Main Commands

| Command              | Description                           |
| -------------------- | ------------------------------------- |
| `ai <desc>`          | Generate and optionally run a command |
| `ai -y <desc>`       | Auto-run without confirmation         |
| `ai --pretty <desc>` | Use colored output                    |
| `ai --help`          | Show help message                     |
| `ai-script <desc>`   | Generate a full shell script          |
| `ai-explain "<cmd>"` | Explain a command with risks          |
| `ai-multi <desc>`    | Generate 3 command variants           |
| `ai-history`         | View command history                  |
| `ai-model`           | Manage Gemini models                  |
| `ai-new`             | Clear context, start fresh            |
| `ai-tree`            | Show directory structure              |

### Management Commands

| Command        | Description       |
| -------------- | ----------------- |
| `ai-change`    | Change API key    |
| `ai-reload`    | Reload script     |
| `ai-update`    | Update version    |
| `ai-version`   | Show version info |
| `ai-ls`        | List all versions |
| `ai-uninstall` | Remove the tool   |

## Requirements

- **Bash or Zsh shell**
  - Bash (Ubuntu, Debian, most Linux distributions)
  - Zsh (Kali Linux, macOS default, Oh My Zsh users)
- curl command
- grep and sed utilities
- Internet connection
- Valid Gemini API key

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#troubleshooting) section
2. View command help with `ai --help`
3. Open an issue on [GitHub](https://github.com/shinjuuichi/ai-generate-cli/issues)
