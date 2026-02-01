# Shiny Chat Bot

A Shiny dashboard application that provides an interactive chat interface for Large Language Models (LLMs) using the ellmer package.

## Features

- **Interactive Chat Interface**: Continuous conversation with LLMs
- **Two-Tab Design**: 
  - **Chat Tab**: Main conversation interface with chat history sidebar
  - **Settings Tab**: Configure system prompts and view LLM configuration
- **System Prompt Customization**: Add custom instructions to modify the AI's behavior
- **Chat Management**: 
  - Create multiple chat sessions
  - Switch between different conversations
  - Fork conversations at any message point to explore alternative discussion paths
- **Tidyverse Style**: Clean, readable code following tidyverse conventions
- **No Custom CSS/JavaScript**: Uses standard Shiny and bslib components

## Installation

### Prerequisites

1. R (>= 4.0.0)
2. Required R packages:
   - shiny
   - bslib
   - ellmer (for actual LLM integration)
   - dplyr
   - purrr

### Install Dependencies

```r
# Install required packages
install.packages(c("shiny", "bslib", "dplyr", "purrr"))

# For ellmer LLM integration:
# The ellmer package provides the LLM interface functionality.
# If not available, the app will use a mock implementation for testing.
# Check the ellmer package repository for actual installation instructions:
# - GitHub: https://github.com/hadley/ellmer (or appropriate repository)
# - CRAN: install.packages("ellmer")  # if available
```

**Note**: The application includes a mock implementation of ellmer (`ellmer_mock.R`) that allows you to test the interface without the actual ellmer package. When ellmer is not available, the app will automatically use the mock version and display placeholder responses. For production use with real LLMs, you must install the actual ellmer package and configure your API keys.

## Configuration

### LLM Setup

The application reads LLM configuration from your `.Rprofile` file. Create or edit your `.Rprofile` with your preferred LLM provider settings:

#### Example for OpenAI:
```r
options(ellmer_provider = "openai")
options(ellmer_model = "gpt-3.5-turbo")
Sys.setenv(OPENAI_API_KEY = "your-api-key-here")
```

#### Example for Anthropic:
```r
options(ellmer_provider = "anthropic")
options(ellmer_model = "claude-3-sonnet-20240229")
Sys.setenv(ANTHROPIC_API_KEY = "your-api-key-here")
```

#### Example for Ollama (local models):
```r
options(ellmer_provider = "ollama")
options(ellmer_model = "llama2")
```

A sample configuration file is provided as `.Rprofile.example`.

## Usage

### Running the Application

```r
# From R console or RStudio
shiny::runApp("app.R")
```

Or run directly:
```r
R -e "shiny::runApp('app.R')"
```

### Using the Chat Interface

1. **Start a Chat**: The app creates an initial chat on startup
2. **Send Messages**: Type in the text input and click "Send" or press Enter
3. **Create New Chat**: Click "New Chat" to start a fresh conversation
4. **Switch Chats**: Click on any chat in the sidebar to switch between conversations
5. **Fork Conversations**: Click "Fork from here" next to any user message to create a new chat branching from that point

### Customizing System Prompts

1. Navigate to the **Settings** tab
2. Enter additional instructions in the "Add to System Prompt" field
3. Click "Update System Prompt" to apply changes
4. The current system prompt will be displayed for review

## Features in Detail

### Chat Forking

The fork feature allows you to explore alternative conversation paths:
- Click "Fork from here" on any user message
- Creates a new chat session with all messages up to that point
- Continue the conversation in a different direction
- Original chat remains unchanged

### Chat History Management

- All chats are preserved in the sidebar
- Switch between chats seamlessly
- Current chat is highlighted
- Chat state is maintained across switches

### System Prompt Manipulation

- Base prompt: "You are a helpful AI assistant."
- Add custom instructions to modify AI behavior
- Changes apply to new messages in the current session
- View the complete system prompt in the Settings tab

## Architecture

The application follows tidyverse style guidelines:
- Clean, readable code structure
- Functional programming approach with `purrr`
- Data manipulation with `dplyr`
- Reactive programming with Shiny
- Modern UI with `bslib` and Bootstrap 5

## Troubleshooting

### LLM Connection Issues

If you encounter connection errors:
1. Verify your `.Rprofile` configuration
2. Check that API keys are valid and active
3. Ensure you have network connectivity
4. Review error messages in the notification panel

### Package Installation

If packages fail to install:
```r
# Update R and try again
update.packages(ask = FALSE)

# Install from specific repository
install.packages("ellmer", repos = "https://cloud.r-project.org")
```

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.
