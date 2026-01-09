# renv activation script
# This file will be sourced by .Rprofile to activate renv
# Note: This is a simplified version. For full renv functionality,
# run setup_renv.R first to properly initialize renv.

# Check if renv package is available
if (requireNamespace("renv", quietly = TRUE)) {
  # Try to activate renv
  tryCatch({
    renv::activate()
  }, error = function(e) {
    # If activation fails, renv is not initialized
    # User should run setup_renv.R first
    message("renv is not initialized. Run source('setup_renv.R') to set it up.")
  })
} else {
  # renv package is not installed
  message("renv package is not installed. Install it with: install.packages('renv')")
  message("Or run source('setup_renv.R') to set up the environment.")
}
