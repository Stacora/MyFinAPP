---
editor_options: 
  markdown: 
    wrap: 72
---

# FinApp - Practical Finance Shiny Application

A Shiny application for managing personal finances, tracking expenses,
income, credit cards, and debts with multi-currency support.

## Project Structure

```         
FinApp_RShiny/
├── app.R                    # Main Shiny application entry point
├── .Rprofile                # Auto-loads renv on R startup
├── setup_renv.R             # Script to initialize renv environment
├── README.md                # This file
├── .gitignore               # Git ignore rules
│
├── R/                       # R source code
│   └── modules.R            # Shiny modules (UI and server components)
│
├── scripts/                 # Helper scripts (non-app code)
│   ├── SQLiteConectionAssistance.R
│   └── py_to_R.R
│
├── python/                  # Python scripts
│   └── openexchangerates_api.py  # Currency exchange rate API script
│
├── data/                    # Data files
│   ├── raw/                 # Original/backup data files
│   │   ├── FinApp_planilla.xlsx
│   │   └── backup_data/
│   ├── processed/           # Processed/exports
│   │   └── FinApp_planilla/
│   └── reference/           # Reference data
│       └── currency_list.csv
│
├── db/                      # Database files
│   ├── USD_practicalFinance.db
│   └── TheDataLake.db
│
├── www/                     # Static assets (images, CSS, JS)
│   └── shiba_dance.gif
│
└── renv/                    # renv environment (dependency management)
    ├── activate.R
    └── settings.json
```

## Setup Instructions

### Prerequisites

-   R (version 4.0 or higher recommended)
-   Python 3.x (for currency exchange rate API)
-   Required Python packages: `requests`, `pandas`, `datetime`

### Initial Setup

1.  **Clone or download this repository**

2.  **Set up renv (Reproducible R Environment)**

    Open R in the project directory and run:

    ``` r
    source("setup_renv.R")
    ```

    This will:

    -   Install renv if needed
    -   Initialize the renv environment
    -   Install all required R packages
    -   Create `renv.lock` with exact package versions

3.  **Set up Python environment (if needed)**

    The application uses Python scripts for currency exchange rates.
    Ensure you have:

    -   Python 3.x installed
    -   Required packages: `requests`, `pandas`

    You can install them via:

    ``` bash
    pip install requests pandas
    ```

    Or if using conda:

    ``` bash
    conda install requests pandas
    ```

4.  **Configure Python path (if needed)**

    If R cannot find Python automatically, you may need to configure it
    in `app.R`:

    ``` r
    # Uncomment and adjust if needed:
    # reticulate::use_condaenv('base')
    # or
    # reticulate::use_python('/path/to/python')
    ```

### Running the Application

**IMPORTANT: First check if packages are installed**

Before running the app, check if all required packages are installed:

``` r
source("check_packages.R")
```

If packages are missing, install them:

``` r
source("install_packages.R")
```

**Then run the app:**

**Option 1: Using the helper script (Recommended)**

``` r
source("RUN_APP.R")
```

**Option 2: Direct execution (in R or RStudio)**

``` r
shiny::runApp("app.R")
```

**Option 3: From RStudio** - Open `app.R` in RStudio - Click the "Run
App" button in the top right of the editor

**Option 4: From command line (if packages are installed)**

``` bash
Rscript RUN_APP.R
```

**Troubleshooting:**

If you get "there is no package called 'shiny'" error: 1. Make sure
you're running R (not just Rscript) 2. Install packages:
`source("install_packages.R")` 3. Or install manually:
`install.packages("shiny")`

If you encounter errors with `.Rprofile` and renv: - Temporarily rename
`.Rprofile` to `.Rprofile.bak` - Or run the app directly:
`shiny::runApp("app.R")` (it will work if packages are installed
globally)

**If renv is set up:**

``` r
# Restore packages first
renv::restore()

# Then run the app
shiny::runApp("app.R")
```

## Dependencies

### R Packages

-   `shiny` - Shiny web framework
-   `DT` - DataTables for R/Shiny
-   `stringr` - String manipulation
-   `dplyr` - Data manipulation
-   `reticulate` - R interface to Python
-   `RSQLite` - SQLite database interface
-   `DBI` - Database interface
-   `shinyWidgets` - Enhanced widgets for Shiny
-   `shinydashboard` - Dashboard layout for Shiny
-   `writexl` - Write Excel files
-   `ggplot2` - Graphics
-   `openxlsx` - Read/write Excel files
-   `readxl` - Read Excel files

### Python Packages

-   `requests` - HTTP library
-   `pandas` - Data manipulation
-   `datetime` - Date/time handling

## Features

-   **Multi-currency support**: Track expenses and income in different
    currencies with automatic USD conversion
-   **Credit card management**: Track credit cards, limits, billing
    cycles, and expenses
-   **Debt tracking**: Manage debts and payment schedules
-   **Data visualization**: Charts and graphs for financial analysis\
    **Note**: Several charts and visualizations are still under active
    development. Some plots may not appear yet or may exhibit incomplete
    behavior.
-   **Excel import/export**: Import data from Excel files and export
    results

## Data Structure

The application expects Excel files with the following sheets: 1.
**Expenses**: Date, Amount, Currency, USD_price, USD_amount, From, To,
Description 2. **Income**: Same structure as Expenses 3.
**Creditcards**: Bank, Card_label, limit, Billing_Closure,
Payment_Due_Date, Payment_Day 4. **Credit_expenses**: Similar to
Expenses with additional ITF field 5. **Debt**: from_who, to_whom,
date_of_debt, debt_amount, USD_price, USD_amount, paymentInstallment,
Payment_Due_Date

## Sample Data

The repository includes a sample workbook that can be used to explore
and test the application:

-   **File**: `data/raw/FinApp_planilla.xlsx`
-   **Purpose**: Example dataset with synthetic/personal test data used
    to validate the app's behavior.
-   **Sheets**:
    -   `Expenses` (Sheet 1)
    -   `Income` (Sheet 2)
    -   `Creditcards` (Sheet 3)
    -   `Credit_expenses` (Sheet 4)
    -   `Debt` (Sheet 5)

There is also a backup copy located at:

-   `data/raw/backup_data/FinApp_planilla.xlsx`

You can duplicate this workbook and adjust the contents to match your
own financial data, as long as you preserve the same column structure
described above (see also `APP_NOTES.md` for detailed schema notes).

## Notes

-   The application requires internet connection for currency exchange
    rate updates
-   Currency rates are cached in SQLite database
    (`db/USD_practicalFinance.db`) for offline use
-   Exchange rates are updated hourly from openexchangerates.org API

## Technical Debt / Legacy Patterns

The following patterns were preserved from the original codebase (as
requested):

1.  **PATITO sections**: Code sections marked with "PATITO" comments are
    provisional and may need future updates
2.  **Global assignments**: Some variables use `<<-` operator (e.g.,
    `df_exchange`, `df_meta`)
3.  **Commented code**: Several commented-out sections remain for
    reference
4.  **Hardcoded API key**: The openexchangerates.org API key is
    hardcoded in `python/openexchangerates_api.py` (consider moving to
    environment variable)
5.  **readxl namespace usage**: `readxl` package is used via namespace
    (`readxl::read_xlsx`) but not explicitly loaded

## Troubleshooting

### renv issues

-   If renv doesn't activate automatically, run `renv::activate()`
-   To restore packages: `renv::restore()`
-   To update packages: `renv::update()`

### Python/reticulate issues

-   Ensure Python is installed and accessible
-   Check Python path: `reticulate::py_config()`
-   Verify Python packages: `reticulate::py_list_packages()`

### Database issues

-   Database files are created automatically in `db/` directory
-   If database is locked, ensure no other process is using it
