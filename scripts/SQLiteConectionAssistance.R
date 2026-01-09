# creating a data base for my app


library(RSQLite)
library(DBI)

drv = dbDriver('SQLite')
con = dbConnect(drv, dbname = 'db/USD_practicalFinance.db')
DBI::dbListTables(con)
dbDisconnect(con)
dbReadTable(con, 'df_exchangeUSD_1696132808')

as.POSIXct(1696132808, origin = "1970-01-01")
strftime( as.POSIXct(1696132808, origin = "1970-01-01"), "%Y-%m-%d %H:%M:%S")

as.POSIXct(dbdates, origin = "1970-01-01")
