### modules 

print('Loading modules...')

## Showing modules

### Modules to record inputs into the tables and display them on the hole app
table_suits_UI <- function(id) {
  ns <- NS(id)
  tagList(
    DT::dataTableOutput(ns('mySheet')),
    fluidRow(
      column(2,
             numericInput(ns('indexToDrop'), 'Index', min = 0, value = 0)),
      column(1,
             br(),
             actionButton(ns('dropline'), 'Drop Line')),
      column(6,
             br(),
             actionButton(ns('addline'), 'Add Line'))
    )
  )
}

## in this case, reactivePort will be theFile, because it needs to be check if it is null
table_suits_Server <- function(id, reactivePort, section) { 
  moduleServer(
    id,
    function(input, output, session) {
      ## preparing the display for the data
      
      output$mySheet = renderDT({
        if(!is.null(reactivePort[['data']])){
          file_u = reactivePort[['data']]
          return(file_u[[section]])
        }
      },
      editable = list(target = 'cell', desible = list(columns = c(5))), 
      server = T,
      selection = 'single',
      class = 'cell-border stripe')
      
      ## Adding a line to the dataset
      addme_lines = reactive({
        file_u = reactivePort[['data']][[section]]
        
        new_line = generate_empty(datasetFormat = file_u)
        reactivePort[['data']][[section]] = rbind(file_u, new_line)
        
        updateNumericInput(inputId = 'indexToDrop', 
                           value = nrow(reactivePort[['data']][[section]]))
      })
      
      ## Action to add a line
      observeEvent(input$addline, {
        addme_lines()
      })
      
      ## Action to delete a line
      observeEvent(input$dropline, {
        # The drop line section doesn't conserve the indexes, it reformulates them
        pivot = reactivePort[['data']][[section]]
        if(nrow(pivot) > 1){ ## Can't drop more lines than 1
          if(input$indexToDrop > 1){
            index_delete = input$indexToDrop
          }else{
            index_delete = nrow(pivot)
          }
          
          pivot = pivot[-index_delete, ]
          
          # Reformulating indexes
          rownames(pivot) = 1:nrow(pivot)
          reactivePort[['data']][[section]] = pivot
          updateNumericInput(inputId = 'indexToDrop', 
                             value = nrow(reactivePort[['data']][[section]])) 
        }else{
          showNotification('Can\'t drop more lines!', type = 'warning')
        }
      })
      
      # updating input$indexToDrop to then delete, or drop, a selected line
      observeEvent(input$mySheet_rows_selected, {
        updateNumericInput(inputId = 'indexToDrop',
                           value = input$mySheet_rows_selected)
      })
      
      ## Adicionando y editando datos
      
      observeEvent(input$mySheet_cell_edit, {
        
        info = input$mySheet_cell_edit
        row_dt = info$row
        col_dt = info$col
        value_dt = info$value
        
        file_u = reactivePort[['data']][[section]]
        
        # getting the colname selected
        c_names = colnames(file_u)[col_dt]
        
        ### variables that belong to the evaluation:
        dateType = c('Date', 'Payment_Due_Date', 'Payment_Day', 'date_of_debt')
        numeric_currencyType = c('Amount', 'USD_price', 'USD_amount', 'ITF',
                                 'limit', 'Billing_Closure', 'debt_amount',
                                 'paymentInstallment')
        
        ## If the input doesn't belong to the format, this section stops with a null
        list_values = list(value_dt, c_names)
        if(c_names %in% dateType){
          value_dt = evaluate_data[['Date_type']](list_values)
        }else if(c_names %in% numeric_currencyType){
          value_dt = evaluate_data[['numeric_currency_type']](list_values)
        }
        
        file_u = reactivePort[['data']][[section]]
        
        file_u[row_dt, col_dt] = value_dt
        reactivePort[['data']][[section]] = file_u
        
        if(nrow(file_u) == row_dt){
          addme_lines()
        }
      })
      
      ## Bellow we have a list of functions
      ## one function per variable type (date type, numeric currency type, character type)
      evaluate_data = list(
        Date_type = function(value_list){
          fecha = value_list[[1]]
          fecha_format = strptime(as.character(fecha), '%Y-%m-%d') %>%
            format('%Y-%m-%d')
          gotrep = grepl(pattern = '^\\d{2}/\\d{2}/\\d{4}$', x = fecha)
          
          if(is.na(fecha_format) | !gotrep){
            showNotification('The date format must be YYYY-MM-DD',
                             type = 'warning')
            return(strptime(as.character(Sys.Date()), '%Y-%m-%d') %>%
                     format('%Y-%m-%d'))
          }else{return(fecha)}
        },
        numeric_currency_type = function(value_list){
          value = value_list[[1]] %>% as.numeric()
          if(is.na(value)){
            showNotification('You got to insert a number. Don\'t use a comma',
                             type = 'warning')
            return('0.00')
          }else{return(value)}
        }
      )
      ####
    }
  )
}

display_tabIMG = function(id){
  ns <- NS(id)
  tagList(
    tabsetPanel(
      id = ns('display_it'),
      type = 'hidden',
      tabPanel('meanWhileIMG',
               tags$h3('Upload your data to proceed'),
               imageOutput(ns('imagem_meanwhile'))
      ),
      tabPanel('table',
               table_suits_UI(id = ns('teste12'))
      )
    )
  )
}

display_tabIMG_server = function(id, newDoc_in, usersDoc_in,  samplecols,
                                 reactivePort, section){
  # stopifnot(is.reactive(newDoc_in))
  moduleServer(
    id,
    function(input, output, session){
      observeEvent(newDoc_in(), {
        updateTabsetPanel(inputId = 'display_it', selected = 'table')
      })
      
      observeEvent(usersDoc_in(), {
        updateTabsetPanel(inputId = 'display_it', selected = 'table')
      })
      
      output$imagem_meanwhile <- renderImage({
        list(src = "shiba_dance.gif",
             height = 300, 
             width = 300, 
             type = "image/gif",
             style="display: block; margin-left: auto; margin-right: auto;",
             align = "center")
      },deleteFile = F)
      
      table_suits_Server('teste12',
                         reactivePort = reactivePort,
                         section = section)
    }
  )
}

## Total USD output
Total_USD_UI = function(id){
  ns = NS(id)
  tagList(
    uiOutput(ns('totalValue'))
  )
}

Total_USD_Server = function(id, reactivePort){
  moduleServer(
    id,
    function(input, output, session){
      totalUsD = reactive({
        if(is.null(reactivePort[['data']]) || 
           (nrow(reactivePort[['data']][['Expenses']]) == 0 && nrow(reactivePort[['data']][['Income']]) == 0)){
          return('0,00 USD')
        }else{
          pivot_Expenses = reactivePort[['data']][['Expenses']][['USD_amount']] %>%
            as.numeric() %>% sum()
          pivot_Income = reactivePort[['data']][['Income']][['USD_amount']] %>% 
            as.numeric() %>% sum()
          pivot = pivot_Income - pivot_Expenses
          
          total = sprintf('%.2f', sum(pivot, na.rm = TRUE))
          total = paste(total, ' USD')
          return(total)
        }
      })
      
      output$totalValue = renderUI({
        total <- totalUsD()
        color <- ifelse(as.numeric(gsub("[^0-9.-]", "", total)) > 0, "green", 
                        ifelse(as.numeric(gsub("[^0-9.-]", "", total)) < 0, 'red',
                               'black'))
        tags$h1(style = paste("color:", color, ";"), total)
      })
    }
  )
}

## Pyplots for display (solo recibirá las bases listas para ser plotadas)
piePlotBox_ui = function(id){
  ns = NS(id)
  tagList(
    uiOutput('piePlotBox_helper01')
  )
}

pie_plot_bankusd01_server = function(id, plotBase, BoxName){
  moduleServer(
    id,
    function(input, output, session){
      
      output$piePlotBox_helper01 = renderUI({
        box(title = BoxName, solidHeader = T,
            height = '300px', width = '300px',
            plotOutput(ns('pie_plot'))
        )
      })
      
      output$pie_plot = renderPlot({
        ggplot(plotBase, aes(x = 2, y = valor, fill = categoria)) +
          geom_bar(stat = "identity", width = 1) +
          coord_polar("y", start = 0) +
          theme_void() +
          scale_fill_manual(values = c("#E0E0E0", "#FFA500")) +
          geom_text(aes(label = round(valor, 1)),
                    position = position_stack(vjust = 0.5)) +
          xlim(0.5, 2.5) +
          theme(plot.title = element_text(hjust = 0.5))
      })
    }
  )
}


## Row of boxes with plots
rowPiePlotBoxes_ui = function(id){
  ns = NS(id)
  tagList(
    fluidRow(
      column(3,
             box(title = 'Settings', status = 'primary', solidHeader = T,
                 collapsible = T, height = '300px', width = '300px',
                 dateInput(inputId = ns('disDate_pie'),
                           label = 'Month',
                           format = 'mm-yyyy'),
                 selectInput(inputId = ns('disBank_pie01'), 
                             label = 'Bank',
                             choices = c('Select a Bank'),
                             selected = as.character(0)))
      ),
      ## proportions between banks
      column(3,
             piePlotBox_ui('creditcards01')
      ),
      ## proportion bank x per Month
      column(3,
             piePlotBox_ui('creditcards02')
      ),
      ## Total proportion of all banks per month
      column(3,
             piePlotBox_ui('creditcards03')
      )
    )
  )
}

rowPiePlotBoxes_server = function(id, reactivePort){ ## reactive is for theFile
  moduleServer(
    id,
    function(input, output, session){
      # TODO: Implement pie plot boxes server logic
      # This function is incomplete in the original codebase
      # Placeholder to prevent errors
      return(NULL)
    }
  )
}


