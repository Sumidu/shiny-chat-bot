# Mock ellmer package for testing purposes
# This is a placeholder - replace with actual ellmer package when available
# 
# The ellmer package should provide:
# - chat() function to create a chat object with system_prompt
# - chat_append() to add messages to the chat
# - chat_perform() to get LLM responses
#
# For actual usage, install the real ellmer package according to its documentation

chat <- function(system_prompt = "You are a helpful AI assistant.") {
  structure(
    list(
      system_prompt = system_prompt,
      messages = list()
    ),
    class = "ellmer_chat"
  )
}

chat_append <- function(chat, message) {
  chat$messages <- append(
    chat$messages,
    list(list(role = "user", content = message))
  )
  chat
}

chat_perform <- function(chat) {
  # Mock response - in real implementation, this would call the LLM API
  last_message <- chat$messages[[length(chat$messages)]]
  
  response_content <- paste(
    "This is a mock response from ellmer.",
    "To use a real LLM, please install the ellmer package",
    "and configure your API keys in .Rprofile.",
    "\n\nYou said:", last_message$content
  )
  
  chat$messages <- append(
    chat$messages,
    list(list(role = "assistant", content = response_content))
  )
  
  chat
}

# Export functions
.ellmer_exports <- list(
  chat = chat,
  chat_append = chat_append,
  chat_perform = chat_perform
)
