# AI Shell Command Generator

Generate shell commands from natural language using Google's Gemini API.

## Setup

### 1. Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the key

### 2. Download the Script

```bash
curl -o ~/ai-command.sh https://raw.githubusercontent.com/shinjuuichi/ai-generate-cli/main/ai-command.sh
chmod +x ~/ai-command.sh
```

```bash
# reload shell
source ~/ai-command.sh
```

### Set API Key (Flexible)

You have three options:

**Option A: Set it when needed**

- Just run `ai` command - it will prompt you for the key

**Option B: Set for current session**

```bash
export GEMINI_API_KEY='your-api-key-here'
```

**Option C: Add to ~/.bashrc (permanent)**

```bash
export GEMINI_API_KEY='your-api-key-here'
```

## Usage

### Basic Usage

```bash
ai <description of what you want to do>
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
- ✅ Preview command before execution
- 🛡️ Safe confirmation prompt
- 🔄 Works with bash and other shells
- 🌍 OS-aware command generation
- ⚡ Fast response using Gemini Flash

## Configuration

The script uses these settings:

- **Model**: gemini-2.5-flash (fast and efficient)
- **Temperature**: 0.2 (more deterministic outputs)
- **Max tokens**: 2000 (sufficient for commands)

## Security Notes

- ⚠️ Always review the generated command before executing
- ⚠️ Never store API keys in version control
- ⚠️ Use environment variables for sensitive data
- ⚠️ The script asks for confirmation before execution

## Troubleshooting

### "GEMINI_API_KEY is not set"

Make sure you've exported the API key:

```bash
export GEMINI_API_KEY='your-actual-key'
```

### "Failed to generate command"

- Check your internet connection
- Verify your API key is valid
- Check if you've exceeded API quota

### Command doesn't work as expected

- Try being more specific in your description
- Include the OS or shell type in your request
- Rephrase the request differently

## Requirements

- Bash shell (or compatible shell)
- curl command
- grep and sed utilities
- Internet connection
- Valid Gemini API key

## License

MIT
