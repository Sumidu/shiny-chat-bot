library(shiny)

# Set options for non-interactive mode
options(shiny.launch.browser = FALSE)

# Run the app on a specific port
runApp(appDir = ".", port = 8080, host = "0.0.0.0")
