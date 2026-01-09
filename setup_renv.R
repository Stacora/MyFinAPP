# Setup script to initialize renv for this project
# Run this script once to set up the renv environment

# Install renv if not already installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

# Initialize renv (bare = TRUE to avoid auto-restart)
renv::init(bare = TRUE, restart = FALSE)

# Install all required packages
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
  "readxl"  # Used but not explicitly loaded in app.R
)

# Install missing packages
missing_packages <- required_packages[!required_packages %in% rownames(installed.packages())]
if (length(missing_packages) > 0) {
  renv::install(missing_packages)
}

# Snapshot the current state to create renv.lock
renv::snapshot()

cat("renv setup complete! The renv.lock file has been created.\n")
cat("To restore packages in the future, run: renv::restore()\n")

