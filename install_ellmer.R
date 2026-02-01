# Try to install ellmer from different sources
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# First try CRAN
tryCatch({
  install.packages("ellmer")
  cat("ellmer installed from CRAN\n")
}, error = function(e) {
  cat("ellmer not available on CRAN\n")
  cat("Trying GitHub...\n")
  
  # Try from GitHub
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }
  
  tryCatch({
    remotes::install_github("hadley/ellmer")
    cat("ellmer installed from GitHub\n")
  }, error = function(e2) {
    cat("Could not install ellmer from GitHub either\n")
    cat("Error:", conditionMessage(e2), "\n")
  })
})
