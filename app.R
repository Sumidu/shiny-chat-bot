# Shiny Chat Bot with LLM Integration
# Uses ellmer package for LLM interaction
# Tidyverse style coding

library(shiny)
library(bslib)

# Try to load ellmer, use mock if not available
if (!requireNamespace("ellmer", quietly = TRUE)) {
  message("ellmer package not found, using mock implementation for testing")
  source("ellmer_mock.R")
} else {
  library(ellmer)
}

library(dplyr)
library(purrr)

# Initialize reactive values for chat management
# Chat structure: list of chat sessions, each with messages and fork history

# UI Definition
ui <- page_navbar(
  title = "Chat Bot",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  
  # Chat Tab
  nav_panel(
    title = "Chat",
    layout_sidebar(
      sidebar = sidebar(
        title = "Chat History",
        width = 300,
        actionButton("new_chat", "New Chat", class = "btn-primary w-100 mb-2"),
        uiOutput("chat_history_ui")
      ),
      card(
        card_header("Chat Messages"),
        div(
          style = "height: 500px; overflow-y: auto; padding: 10px; border: 1px solid #ddd; margin-bottom: 10px;",
          uiOutput("chat_messages")
        ),
        layout_columns(
          col_widths = c(10, 2),
          textInput(
            "user_input",
            label = NULL,
            placeholder = "Type your message...",
            width = "100%"
          ),
          actionButton(
            "send_message",
            "Send",
            class = "btn-success",
            style = "margin-top: 0px;"
          )
        )
      )
    )
  ),
  
  # Settings Tab
  nav_panel(
    title = "Settings",
    layout_columns(
      col_widths = c(12),
      card(
        card_header("System Prompt Configuration"),
        textAreaInput(
          "system_prompt_additions",
          "Add to System Prompt:",
          value = "",
          placeholder = "Add additional instructions to the system prompt...",
          rows = 5,
          width = "100%"
        ),
        textAreaInput(
          "current_system_prompt",
          "Current System Prompt:",
          value = "You are a helpful AI assistant.",
          rows = 10,
          width = "100%"
        ),
        actionButton("update_prompt", "Update System Prompt", class = "btn-primary")
      ),
      card(
        card_header("LLM Configuration"),
        verbatimTextOutput("llm_config_display")
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Reactive values for chat state
  chat_state <- reactiveValues(
    chats = list(),
    current_chat_id = NULL,
    system_prompt = "You are a helpful AI assistant.",
    chat_counter = 0
  )
  
  # Initialize LLM chat object
  llm_chat <- reactiveVal(NULL)
  
  # Initialize first chat on startup
  observe({
    if (length(chat_state$chats) == 0) {
      create_new_chat()
    }
  })
  
  # Function to create a new chat
  create_new_chat <- function(fork_from = NULL, fork_at_index = NULL) {
    chat_state$chat_counter <- chat_state$chat_counter + 1
    chat_id <- paste0("chat_", chat_state$chat_counter)
    
    messages <- list()
    if (!is.null(fork_from) && !is.null(fork_at_index)) {
      # Fork from existing chat
      parent_chat <- chat_state$chats[[fork_from]]
      messages <- parent_chat$messages[1:fork_at_index]
    }
    
    chat_state$chats[[chat_id]] <- list(
      id = chat_id,
      name = paste("Chat", chat_state$chat_counter),
      messages = messages,
      created_at = Sys.time(),
      parent_id = fork_from,
      fork_at = fork_at_index
    )
    
    chat_state$current_chat_id <- chat_id
    
    # Initialize new LLM chat
    tryCatch({
      llm_chat(chat(system_prompt = chat_state$system_prompt))
    }, error = function(e) {
      showNotification(
        paste("Error initializing LLM:", e$message),
        type = "error",
        duration = 5
      )
    })
  }
  
  # Create new chat button
  observeEvent(input$new_chat, {
    create_new_chat()
  })
  
  # Send message
  observeEvent(input$send_message, {
    req(input$user_input != "")
    req(chat_state$current_chat_id)
    
    user_message <- input$user_input
    updateTextInput(session, "user_input", value = "")
    
    # Get LLM response
    tryCatch({
      if (is.null(llm_chat())) {
        llm_chat(chat(system_prompt = chat_state$system_prompt))
      }
      
      response <- llm_chat() %>%
        chat_append(user_message) %>%
        chat_perform()
      
      assistant_message <- response$messages[[length(response$messages)]]$content
      
      # Add user message to current chat
      current_chat <- chat_state$chats[[chat_state$current_chat_id]]
      current_chat$messages <- append(
        current_chat$messages,
        list(list(role = "user", content = user_message))
      )
      current_chat$messages <- append(
        current_chat$messages,
        list(list(role = "assistant", content = assistant_message))
      )
      chat_state$chats[[chat_state$current_chat_id]] <- current_chat
      
      # Update the llm_chat object
      llm_chat(response)
      
    }, error = function(e) {
      showNotification(
        paste("Error communicating with LLM:", e$message),
        type = "error",
        duration = 5
      )
      
      # Add error message to chat
      current_chat <- chat_state$chats[[chat_state$current_chat_id]]
      current_chat$messages <- append(
        current_chat$messages,
        list(list(role = "assistant", content = paste("Error:", e$message)))
      )
      chat_state$chats[[chat_state$current_chat_id]] <- current_chat
    })
  })
  
  # Render chat messages
  output$chat_messages <- renderUI({
    req(chat_state$current_chat_id)
    current_chat <- chat_state$chats[[chat_state$current_chat_id]]
    
    if (length(current_chat$messages) == 0) {
      return(div(
        style = "text-align: center; padding: 50px; color: #999;",
        h4("No messages yet"),
        p("Start a conversation by typing a message below.")
      ))
    }
    
    message_divs <- map(seq_along(current_chat$messages), function(i) {
      msg <- current_chat$messages[[i]]
      
      if (msg$role == "user") {
        div(
          style = "margin-bottom: 15px; text-align: right;",
          div(
            style = "display: inline-block; background-color: #007bff; color: white; padding: 10px 15px; border-radius: 10px; max-width: 70%; text-align: left;",
            msg$content
          ),
          div(
            style = "margin-top: 5px; font-size: 0.8em;",
            actionLink(
              paste0("fork_", chat_state$current_chat_id, "_", i),
              "Fork from here",
              style = "color: #6c757d;"
            )
          )
        )
      } else {
        div(
          style = "margin-bottom: 15px; text-align: left;",
          div(
            style = "display: inline-block; background-color: #e9ecef; color: black; padding: 10px 15px; border-radius: 10px; max-width: 70%;",
            msg$content
          )
        )
      }
    })
    
    do.call(tagList, message_divs)
  })
  
  # Render chat history
  output$chat_history_ui <- renderUI({
    if (length(chat_state$chats) == 0) {
      return(div("No chats yet"))
    }
    
    chat_buttons <- map(names(chat_state$chats), function(chat_id) {
      chat_obj <- chat_state$chats[[chat_id]]
      is_current <- chat_id == chat_state$current_chat_id
      
      div(
        style = "margin-bottom: 5px;",
        actionButton(
          paste0("select_chat_", chat_id),
          chat_obj$name,
          class = if (is_current) "btn-primary w-100" else "btn-outline-primary w-100",
          style = "text-align: left;"
        )
      )
    })
    
    do.call(tagList, chat_buttons)
  })
  
  # Dynamic chat selection observers
  observe({
    lapply(names(chat_state$chats), function(chat_id) {
      observeEvent(input[[paste0("select_chat_", chat_id)]], {
        chat_state$current_chat_id <- chat_id
        
        # Reinitialize LLM chat with current messages
        tryCatch({
          new_chat <- chat(system_prompt = chat_state$system_prompt)
          current_chat <- chat_state$chats[[chat_id]]
          
          # Replay messages to rebuild chat state
          for (msg in current_chat$messages) {
            if (msg$role == "user") {
              new_chat <- new_chat %>% chat_append(msg$content)
            } else if (msg$role == "assistant") {
              # For assistant messages, we need to manually add them
              new_chat$messages <- append(
                new_chat$messages,
                list(list(role = "assistant", content = msg$content))
              )
            }
          }
          
          llm_chat(new_chat)
        }, error = function(e) {
          showNotification(
            paste("Error loading chat:", e$message),
            type = "warning",
            duration = 3
          )
        })
      })
    })
  })
  
  # Dynamic fork observers
  observe({
    req(chat_state$current_chat_id)
    current_chat <- chat_state$chats[[chat_state$current_chat_id]]
    
    lapply(seq_along(current_chat$messages), function(i) {
      fork_id <- paste0("fork_", chat_state$current_chat_id, "_", i)
      observeEvent(input[[fork_id]], {
        create_new_chat(
          fork_from = chat_state$current_chat_id,
          fork_at_index = i
        )
        showNotification(
          "Chat forked successfully!",
          type = "message",
          duration = 2
        )
      })
    })
  })
  
  # Update system prompt
  observeEvent(input$update_prompt, {
    base_prompt <- "You are a helpful AI assistant."
    additions <- input$system_prompt_additions
    
    if (additions != "") {
      chat_state$system_prompt <- paste(base_prompt, additions, sep = "\n\n")
    } else {
      chat_state$system_prompt <- base_prompt
    }
    
    updateTextAreaInput(
      session,
      "current_system_prompt",
      value = chat_state$system_prompt
    )
    
    # Reinitialize LLM chat with new prompt
    # Note: This resets the LLM context. Previous messages in chat_state are preserved,
    # but the LLM will start fresh with the new prompt for subsequent messages.
    if (!is.null(chat_state$current_chat_id)) {
      tryCatch({
        llm_chat(chat(system_prompt = chat_state$system_prompt))
        showNotification(
          "System prompt updated! Note: LLM context reset. Previous messages preserved in history.",
          type = "message",
          duration = 3
        )
      }, error = function(e) {
        showNotification(
          paste("Error updating prompt:", e$message),
          type = "error",
          duration = 5
        )
      })
    }
  })
  
  # Display LLM configuration
  output$llm_config_display <- renderPrint({
    tryCatch({
      # Try to get configuration from ellmer
      cat("LLM Configuration:\n")
      cat("------------------\n")
      cat("Configuration is loaded from .Rprofile\n")
      cat("Default provider: Available providers from ellmer package\n")
      cat("\nNote: Configure your LLM settings in your .Rprofile file\n")
      cat("Example:\n")
      cat('  options(ellmer_provider = "openai")\n')
      cat('  Sys.setenv(OPENAI_API_KEY = "your-api-key")\n')
    }, error = function(e) {
      cat("Error reading LLM configuration:", e$message)
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
