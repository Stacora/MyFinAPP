# Script to run the Shiny app
# This script ensures proper setup before running the app

required_packages <- c(
  "shiny", "DT", "stringr", "dplyr", "reticulate",
  "RSQLite", "DBI", "shinyWidgets", "shinydashboard",
  "writexl", "ggplot2", "openxlsx", "readxl"
)

# Check if required packages are installed
cat("Checking required packages...\n")
missing <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing) > 0) {
  cat("\n✗ ERROR: Missing packages:\n")
  cat(paste("  -", missing, collapse = "\n"), "\n\n")
  cat("Please install missing packages first:\n")
  cat("  source('install_packages.R')\n")
  cat("Or manually:\n")
  cat("  install.packages(c(\n")
  cat(paste0('    "', paste(missing, collapse = '",\n    "'), '"\n'))
  cat("  ))\n")
  stop("Missing required packages. Please install them first.")
}

cat("✓ All required packages are installed.\n\n")

# Check if renv is available and should be used
if (file.exists("renv.lock") && requireNamespace("renv", quietly = TRUE)) {
  cat("Activating renv environment...\n")
  tryCatch({
    renv::activate()
    renv::restore(prompt = FALSE)
    cat("✓ renv activated.\n\n")
  }, error = function(e) {
    cat("⚠ Warning: Could not activate renv. Using system packages.\n\n")
  })
}

# Run the app
cat("Starting Shiny application...\n")
shiny::runApp("app.R")

