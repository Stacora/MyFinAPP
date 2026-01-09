# Script to check if all required packages are installed
# Run this before trying to run the app

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

cat("Checking required packages...\n\n")

missing_packages <- c()
installed_packages <- c()

for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat("✓", pkg, "- installed\n")
    installed_packages <- c(installed_packages, pkg)
  } else {
    cat("✗", pkg, "- MISSING\n")
    missing_packages <- c(missing_packages, pkg)
  }
}

cat("\n" , rep("=", 50), "\n", sep = "")
cat("Summary:\n")
cat("Installed:", length(installed_packages), "packages\n")
cat("Missing:", length(missing_packages), "packages\n")

if (length(missing_packages) > 0) {
  cat("\nTo install missing packages, run:\n")
  cat("install.packages(c(\n")
  cat(paste0('  "', paste(missing_packages, collapse = '",\n  "'), '"\n'))
  cat("))\n")
  
  cat("\nOr install all at once:\n")
  cat('install.packages(c("shiny", "DT", "stringr", "dplyr", "reticulate", "RSQLite", "DBI", "shinyWidgets", "shinydashboard", "writexl", "ggplot2", "openxlsx", "readxl"))\n')
} else {
  cat("\n✓ All required packages are installed!\n")
  cat("You can now run the app with: shiny::runApp('app.R')\n")
}

