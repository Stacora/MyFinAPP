library(shiny)
library(DT)
library(stringr)
library(dplyr)
library(reticulate)
library(RSQLite)
library(DBI)
library(shinyWidgets)
library(shinydashboard)
library(writexl)
library(ggplot2)
library(openxlsx)

# Initialize Python imports with error handling
python_available = tryCatch({
  #reticulate::use_condaenv('base')
  reticulate::import('requests')
  reticulate::import('pandas')
  reticulate::import('datetime')
  TRUE
}, error = function(e) {
  message('Warning: Python modules not available. Currency exchange rates will not work.')
  message('Error: ', e$message)
  FALSE
})

### DataSets format (see APP_NOTES.md for full schema documentation)
# Load currency list
currency_list = tryCatch({
  read.csv('data/reference/currency_list.csv', sep = ',', stringsAsFactors = FALSE)
}, error = function(e) {
  # Fallback to csv2 if csv fails
  read.csv2('data/reference/currency_list.csv', sep = ',', stringsAsFactors = FALSE)
})

# Load base datasets from Excel file
baseExpenses = readxl::read_xlsx('data/raw/FinApp_planilla.xlsx', sheet = 1)
baseIncome = readxl::read_xlsx('data/raw/FinApp_planilla.xlsx', sheet = 2)
baseCreditCards = readxl::read_xlsx('data/raw/FinApp_planilla.xlsx', sheet = 3)
baseCreditExpenses = readxl::read_xlsx('data/raw/FinApp_planilla.xlsx', sheet = 4)
baseDebt = readxl::read_xlsx('data/raw/FinApp_planilla.xlsx', sheet = 5)

generate_empty = function(NAs = F, datasetFormat = NULL, setDefault = T){
  if(is.null(datasetFormat)) stop('generate_empty() needs datasetFormat')
  
  fill_default_data = function(df){
    # browser()
    dateType = c('Date', 'Payment_Due_Date', 'Payment_Day', 'date_of_debt')
    numeric_currencyType = c('Amount', 'USD_price', 'USD_amount', 'ITF',
                             'limit', 'Billing_Closure', 'debt_amount',
                             'paymentInstallment')
    
    ## Assigning date default format
    x_pivot = colnames(df) %in% dateType
    if(any(x_pivot)){
      df[, x_pivot] = strptime(as.character(Sys.Date()), '%Y-%m-%d') %>% 
        format('%Y-%m-%d')
    }
    
    ## Assigning numeric currency
    x_pivot = colnames(df) %in% numeric_currencyType
    if(any(x_pivot)){
      df[, x_pivot] = sprintf('%.2f', 0)
    }
    
    return(df)
  }
  
  values = ifelse(NAs, NA, character(0))
  dimen = dim(datasetFormat)[2]
  matr = matrix(values, 1, dimen) %>% data.frame()
  colnames(matr) = colnames(datasetFormat)
  if(setDefault){
    matr = fill_default_data(matr)
  }
  return(matr)
}

new_Data = list(Expenses = generate_empty(datasetFormat = baseExpenses),
                Income = generate_empty(datasetFormat = baseIncome),
                Creditcards = generate_empty(datasetFormat = baseCreditCards),
                Credit_expenses = generate_empty(datasetFormat = baseCreditExpenses),
                Debt = generate_empty(datasetFormat = baseDebt))


source('R/modules.R')

# Define UI for application that draws a histogram
ui = dashboardPage(
  dashboardHeader(
    title = 'Practical Sheet',
    titleWidth = 220
  ),
  dashboardSidebar(
    width = 220,
    sidebarMenu(
      menuItem('Input Your Data', tabName = 'inputdata'),
      menuItem('Display Your Data', tabName = 'displaydata')
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'inputdata',
              fluidPage(
                fluidRow(column(8,
                                br(),
                                selectInput('currency_list1',
                                            label = 'Currency',
                                            choices = currency_list$currency)
                ),
                column(4,
                       #tags$h1(textOutput('totalValue')),
                       Total_USD_UI('totalUSD'),
                       tags$h6(textOutput('USD_pricing'))
                )
                ),
                tabsetPanel(type = 'tabs',
                            br(),
                            tabPanel('Upload',
                                     fixedRow(
                                       column(6,
                                              column(4,
                                                     fileInput('inputData', 'Upload your Data')),
                                              column(2,
                                                     br(),
                                                     actionButton('newDoc', 'New file')),
                                              column(4,
                                                     selectInput('sampleSheet', label = 'Sheets:',
                                                                 choices = c('Upload your file'),
                                                                 selected = character(0))),
                                              column(2,
                                                     ## this button could be put more to the right
                                                     br(),
                                                     downloadButton('downloadData', 'Download'))
                                       )
                                     ),
                                     DT::dataTableOutput('sampleMyFiles')
                            ),
                            tabPanel('Expenses',
                                     display_tabIMG('expense_input')
                            ),
                            tabPanel('Income',
                                     display_tabIMG('income_input')
                            ),
                            tabPanel('Credit',
                                     shinyWidgets::verticalTabsetPanel(
                                       id = 'creditCards',
                                       verticalTabPanel(
                                         title = 'My Cards',
                                         # tags$h1('Here comes the credit cards record'),
                                         display_tabIMG('creditCards_input'),
                                         box_height = "50px"
                                       ),
                                       verticalTabPanel(
                                         title = 'My Expenses',
                                         # tags$h1('Here comes the credit expenses')
                                         display_tabIMG('creditExpenses_input')
                                       )
                                     )),
                            tabPanel('Debt',
                                     # tags$h1('Here comes the debt records')
                                     display_tabIMG('Debt_input'))
                            
                )
              )
      ),
      tabItem(tabName = 'displaydata',
              ## Credit 01
              tags$h1('Credit'),
              fluidRow(
                column(3,
                       box(title = 'Settings', status = 'primary', solidHeader = T,
                           collapsible = T, height = '300px', width = '300px',
                           dateInput(inputId = 'disDate_pie01',label = 'Month',format = 'mm-yyyy'),
                           selectInput(inputId = 'disBank_pie01', label = 'Bank',
                                       choices = c('Select a Bank'), selected = as.character(0)))
                       ),
                column(3,
                       box(title = 'Proportion by bank', solidHeader = T, 
                           height = '300px', width = '300px',
                           plotOutput('pie_proportion_by_bank01'))
                       ),
                column(3,
                       box(title = 'Spent by bank', solidHeader = T, 
                           height = '300px', width = '300px',
                           plotOutput('pie_spend_by_bank01'))
                       ),
                column(3,
                       box(title = 'Total spent', solidHeader = T,
                           height = '300px', width = '300px',
                           plotOutput('pie_total_spent01'))
                       )
                ),
              tags$h1('Debit'),
              fluidRow(
                column(3,
                       box(title = 'Settings', status = 'primary', solidHeader = T,
                           collapsible = T, height = '300px', width = '300px',
                           dateInput(inputId = 'disDate_pie02',label = 'Month',format = 'mm-yyyy'),
                           selectInput(inputId = 'disBank_pie02', label = 'Bank',
                                       choices = c('Select a Bank'), selected = as.character(0)))
                ),
                column(3,
                       box(title = 'Proportion by bank', solidHeader = T, height = '300px', width = '300px',
                           plotOutput('pie_proportion_by_bank02'))
                ),
                column(3,
                       box(title = 'Spent by bank', solidHeader = T, height = '300px', width = '300px',
                           plotOutput('pie_spend_by_bank02'))
                ),
                column(3,
                       box(title = 'Total spent', solidHeader = T, height = '300px', width = '300px',
                           plotOutput('pie_total_spent02'))
                )
              ),
              )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  ###### Auxiliar functions ####################
  ## creating the universal value
  theFile = reactiveValues(data = NULL, other = NULL)
  
  ## creating a notification function personalized
  show_semaforo = function(message, RedYellowGreenBlue = NULL){
    messagetype = c('error', 'warning', 'success', 'message')
    colorme = messagetype[RedYellowGreenBlue]
    if(is.na(colorme)){
      showNotification(message)
    }else{
      showNotification(message, type = colorme)
    }
    
  }
  
  ## A function for checking the data format
  dataset_checking = function(a_file, the_file){
    action_boolean = ifelse(all(colnames(a_file) == colnames(the_file)), T, F)
    return(action_boolean)
  }
  
  ## ----------------------------------------------------------------------------------------- ##
  
  ###### Upload/New Data Section ####################
  
  ## displaying a sample of the data uploaded
  
  ## prepare new data
  ### Here we generate new datasets and assign it to a reactive value as a list
  observeEvent(input$newDoc, {
    theFile$data = new_Data
    updateSelectInput(inputId = 'sampleSheet', choices = c(names(theFile$data)))
  })
  
  ## upload user's data
  ###--### prepare it for multiple datasets upload
  observeEvent(input$inputData, {
    if(tools::file_ext(input$inputData$datapath) == 'xlsx'){
      updateTabsetPanel(inputId = 'display_it', selected = 'table') ## this one if for expenses only
      sheets_names = readxl::excel_sheets(input$inputData$datapath)
      file_u = list()
      for(i in sheets_names){
        file_u[[i]] = readxl::read_xlsx(input$inputData$datapath,sheet = i) %>%
          data.frame()
      }
      names(file_u) = stringr::str_to_sentence(sheets_names)
      theFile$data = file_u
      print(names(theFile$data))
      updateSelectInput(inputId = 'sampleSheet', choices = c(names(file_u)))
    }else{
      show_semaforo('It must be an excel file', 1)
    }
    updateSelectInput(inputId = 'sampleSheet', choices = c(names(theFile$data)))
  })
  
  sampleSheetData <- reactive({
    input$newDoc  # trigger dependency on input$newDoc
    input$inputData  # trigger dependency on input$inputData
    
    input$sampleSheet  # trigger dependency on input$sampleSheet
    
    if (is.null(theFile$data)) {
      return(NULL)
    }
    
    tail(theFile$data[[input$sampleSheet]])
  })
  
  ### Este módulo se está ejecutando dos veces, porque?
  output$sampleMyFiles = renderDT({
    # return(return_sample())
    sampleSheetData()
  }, selection = 'none')
  
  ## ----------------------------------------------------------------------------------------- ##
  
  ## Display of #Expenses section
  # file_piv = 
  display_tabIMG_server(id = 'expense_input',
                        newDoc_in = reactive(input$newDoc),
                        usersDoc_in = reactive(input$inputData),
                        samplecols = reactive(input$sampleSheet),
                        reactivePort = theFile,
                        section = 'Expenses')
  
  ## Display of #Income section
  # file_piv =
  display_tabIMG_server(id = 'income_input',
                        newDoc_in = reactive(input$newDoc),
                        usersDoc_in = reactive(input$inputData),
                        samplecols = reactive(input$sampleSheet),
                        reactivePort = theFile,
                        section = 'Income')
  
  
  ## Display of #Credit section
  ### #CreditCards.
  # file_piv =
  display_tabIMG_server(id = 'creditCards_input',
                        newDoc_in = reactive(input$newDoc),
                        usersDoc_in = reactive(input$inputData),
                        samplecols = reactive(input$sampleSheet),
                        reactivePort = theFile,
                        section = 'Creditcards')
  
  ### #CreditExpenses
  # file_piv =
  display_tabIMG_server(id = 'creditExpenses_input',
                        newDoc_in = reactive(input$newDoc),
                        usersDoc_in = reactive(input$inputData),
                        samplecols = reactive(input$sampleSheet),
                        reactivePort = theFile,
                        section = 'Credit_expenses')
  
  ### #Debt
  # file_piv =
  display_tabIMG_server(id = 'Debt_input',
                        newDoc_in = reactive(input$newDoc),
                        usersDoc_in = reactive(input$inputData),
                        samplecols = reactive(input$sampleSheet),
                        reactivePort = theFile,
                        section = 'Debt')
  
  # observe({theFile = file_piv()})
  
  ### To Download the data
  output$downloadData <- downloadHandler(
    filename = function() {
      # Use the selected dataset as the suggested file name
      paste0('myData', ".xlsx")
    },
    content = function(file) {
      # Write the dataset to the `file` that will be downloaded
      if(is.null(theFile$data)){
        show_semaforo('There is no data to save', 1)
        return(NULL)
      }else{
        writexl::write_xlsx(theFile$data, file)
        # write.csv(theFile$data, file)
      }
    }
  )
  
  
  ## To output the amount of total USD
  Total_USD_Server('totalUSD', reactivePort = theFile)
  
  
  ### Price of the dollar
  # Initialize df_exchange and df_meta as reactive values
  exchange_data = reactiveValues(df_exchange = NULL, df_meta = NULL)
  
  import_pythonscript = function(){
    if(!python_available){
      message('Python is not available. Cannot fetch exchange rates.')
      return(FALSE)
    }
    tryCatch({
      reticulate::source_python('python/openexchangerates_api.py', envir = globalenv())
      return(TRUE)
    }, error = function(e) {
      message('Error importing Python script: ', e$message)
      return(FALSE)
    })
  }
  
  pricing_output = eventReactive(input$currency_list1,{
    if(is.null(exchange_data$df_exchange) || nrow(exchange_data$df_exchange) == 0){
      return(NULL)
    }
    if(is.null(input$currency_list1) || input$currency_list1 == ''){
      return(NULL)
    }
    pivot = exchange_data$df_exchange[exchange_data$df_exchange[['Currency']] == input$currency_list1, ]
    if(nrow(pivot) == 0){
      return(NULL)
    }
    return(pivot[1, 'USD_price'])
  })
  
  USDprice_timer = reactiveTimer(3600*(10**3))
  
  ### The process bellow not only download the data from the API
  ## It also saves the data to the data lake
  observe({
    USDprice_timer()
    
    # Ensure db directory exists
    if(!dir.exists('db')){
      dir.create('db', recursive = TRUE)
    }
    
    # opening the dataset
    drv = dbDriver('SQLite')
    db_path = 'db/USD_practicalFinance.db'
    con = dbConnect(drv, dbname = db_path)
    
    # Check if database has any tables
    dbtables = dbListTables(con)
    needs_update = TRUE
    
    if(length(dbtables) > 0){
      # Parse table names to get timestamps (look for df_exchangeUSD_* tables)
      exchange_tables = dbtables[grepl('^df_exchangeUSD_', dbtables)]
      if(length(exchange_tables) > 0){
        # Extract timestamps from table names
        timestamps = suppressWarnings(as.numeric(gsub('^df_exchangeUSD_', '', exchange_tables)))
        timestamps = timestamps[!is.na(timestamps)]
        
        if(length(timestamps) > 0){
          max_timestamp = max(timestamps)
          dbdates = as.POSIXct(max_timestamp, origin = "1970-01-01") + 3600
          needs_update = dbdates < Sys.time()
          
          if(!needs_update){
            # Use existing data
            tryCatch({
              exchange_data$df_exchange = dbReadTable(con, paste0('df_exchangeUSD_', max_timestamp))
              exchange_data$df_meta = dbReadTable(con, paste0('df_metaUSD_', max_timestamp))
            }, error = function(e) {
              message('Error reading from database: ', e$message)
              needs_update = TRUE
            })
          }
        }
      }
    }
    
    if(needs_update){
      message('Fetching data from the API')
      if(import_pythonscript()){
        # Check if df_exchange and df_meta were created by Python script
        if(exists('df_exchange', envir = globalenv()) && exists('df_meta', envir = globalenv())){
          df_exchange = get('df_exchange', envir = globalenv())
          df_meta = get('df_meta', envir = globalenv())
          
          if(!is.null(df_exchange) && nrow(df_exchange) > 0 && 'timestamp' %in% colnames(df_exchange)){
            #### creating the names for the tables to be saved
            timestamp_val = df_exchange[1, 'timestamp']
            df_exchange_name = paste0('df_exchangeUSD_', timestamp_val)
            
            # Get timestamp from df_meta if available
            if(!is.null(df_meta) && 'keys' %in% colnames(df_meta) && 'values' %in% colnames(df_meta)){
              meta_timestamp = df_meta[df_meta[['keys']] == 'timestamp', 'values']
              if(length(meta_timestamp) > 0){
                timestamp_val = meta_timestamp[[1]]
              }
            }
            df_meta_name = paste0('df_metaUSD_', timestamp_val)
            
            if(!dbExistsTable(con, df_exchange_name)){
              dbWriteTable(con, df_exchange_name, df_exchange)
            }
            
            if(!dbExistsTable(con, df_meta_name) && !is.null(df_meta)){
              df_meta_to_save = df_meta
              if('values' %in% colnames(df_meta_to_save)){
                df_meta_to_save[['values']] = unlist(df_meta_to_save[['values']])
              }
              dbWriteTable(con, df_meta_name, df_meta_to_save)
            }
            
            # Update reactive values
            exchange_data$df_exchange = df_exchange
            exchange_data$df_meta = df_meta
          }
        }
      }
    }
    
    DBI::dbDisconnect(con)
  })
  
  output$USD_pricing = renderText({
    if(is.null(exchange_data$df_meta) || nrow(exchange_data$df_meta) == 0){
      return('Loading exchange rates...')
    }
    
    pivot = pricing_output()
    if(is.null(pivot)){
      return('Loading exchange rates...')
    }
    
    tryCatch({
      date_it = exchange_data$df_meta[exchange_data$df_meta[['keys']] == 'date', 'values'][[1]]
      if(length(date_it) > 0 && !is.na(date_it)){
        date_it = as.Date(date_it, format = '%d-%m-%Y')
        expr = "^([0-9]{2}):([0-9]{1}):([0-9]{1})$"
        time = exchange_data$df_meta[exchange_data$df_meta[['keys']] == 'time', 'values']
        if(length(time) > 0 && !is.na(time)){
          time = str_replace(time, expr, "\\1:00:00")
          the_message = paste(pivot, 'at', date_it, time)
          return(the_message)
        }
      }
      return(paste(pivot, 'USD'))
    }, error = function(e) {
      return(paste(pivot, 'USD'))
    })
  })
  
  
  ## Credit Section
  observe({
    expenses = theFile$data$Credit_expenses
    cards = theFile$data$Creditcards
    
    print('Credit expenses: ==========================================')
    print(head(expenses))
    print('')
    print('Credit cards: =============================================')
    print(head(cards))
    
    banks = unique(cards$Bank)
  })
  
}

shinyApp(ui = ui, server = server)