# Activate renv if available and properly initialized
# This is optional - the app will work without renv if packages are installed globally
suppressWarnings({
  if (file.exists("renv.lock") && requireNamespace("renv", quietly = TRUE)) {
    tryCatch({
      renv::activate()
    }, error = function(e) {
      # Silently fail - app can run without renv
    })
  }
})

