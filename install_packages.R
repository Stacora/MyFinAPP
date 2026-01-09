# Script to install all required packages
# Run this if packages are missing

cat("Installing required packages...\n\n")

required_packages <- c(
  "shiny",
  "DT",
  "stringr",
  "dplyr",
  "reticulate",
  "RSQLite",
  "DBI",
  "shinyWidgets",
  "shinydashboard",
  "writexl",
  "ggplot2",
  "openxlsx",
  "readxl"
)

# Install missing packages
missing <- required_packages[!required_packages %in% rownames(installed.packages())]

if (length(missing) > 0) {
  cat("Installing", length(missing), "missing packages...\n")
  install.packages(missing, repos = "https://cloud.r-project.org")
  cat("\n✓ Installation complete!\n")
} else {
  cat("✓ All packages are already installed!\n")
}

# Verify installation
cat("\nVerifying installation...\n")
all_installed <- all(sapply(required_packages, requireNamespace, quietly = TRUE))

if (all_installed) {
  cat("✓ All packages are ready!\n")
  cat("You can now run: shiny::runApp('app.R')\n")
} else {
  cat("✗ Some packages failed to install. Please check the error messages above.\n")
}

