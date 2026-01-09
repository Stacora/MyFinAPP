new_Data = list(Expenses = baseExpenses,
                Income = baseIncome,
                Creditcards = baseCreditCards,
                Credit_expenses = baseCreditExpenses,
                Debt = baseDebt)

new_Data$Creditcards$limitsLastUpdate = c(1, 2, 3)
new_Data$Creditcards = new_Data$Creditcards[,c('Bank', 'Card_label', 
                                               'limit', 'limitsLastUpdate',
                                               'Billing_Closure', 'Payment_Due_Date',
                                               'Payment_Day')]

new_Data$Expenses$Type = rep(c('a1', 'a2', 'a3'), 3)
new_Data$Expenses = new_Data$Expenses[,c('Date', 'Amount', 'Currency', 'USD_price',
                                         'USD_amount', 'From', 'To', 'Type',
                                         'Description')]

new_Data$Income$Type = rep(c('b1', 'b2', 'b3'), 3)
new_Data$Income = new_Data$Income[,c('Date', 'Amount', 'Currency', 'USD_price',
                                         'USD_amount', 'From', 'To', 'Type',
                                         'Description')]

new_Data$Credit_expenses$Type = rep(c('c1', 'c2', 'c3'), 3)
new_Data$Credit_expenses = new_Data$Credit_expenses[,c('Date', 'Amount', 'Currency', 'USD_price',
                                                       'USD_amount', 'From', 'To', 'Type',
                                                       'Description', 'ITF')]

colnames(new_Data$Debt)

### manoseo de data
library(openxlsx)
library(dplyr)
library(stringr)

write.xlsx(new_Data, file = 'FinApp_planilla.xlsx')




x1 = baseCreditExpenses[,c('Date', 'From', 'USD_amount')] %>% 
  group_by(Date, From) %>% 
  summarize(USD_Expenses = sum(USD_amount, na.rm = T))


x1$From = str_to_lower(x1$From)
(x2 = left_join(x1, baseCreditCards[,c('limit', 'Bank')], by = c('From' = 'Bank')))
x2$limit = ifelse(is.na(x2$limit), 0, x2$limit)


(data <- data.frame(
  categoria = factor(c("Used", "Available Balance")),
  valor = c(unlist(x2[1, 3]), unlist(x2[1, 4]))
))

library(ggplot2)

# Crear el gráfico de anillo
ggplot(data, aes(x = 2, y = valor, fill = categoria)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  theme_void() +
  #theme(legend.position = "right") +
  scale_fill_manual(values = c("#E0E0E0", "#FFA500")) +
  geom_text(aes(label = round(valor, 1)),
            position = position_stack(vjust = 0.5)) +
  xlim(0.5, 2.5) +  # Limitar el rango de x para crear el hueco en el centro
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(title = "Gráfico de proporción vs total")


ok#### Referencia de codigo para modulos 


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