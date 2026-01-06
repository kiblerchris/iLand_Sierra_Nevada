getDatabaseTables <- function(dbname="YOURSQLITEFILE", tableName=NULL){
  library("RSQLite")
  library("purrr")
  con <- dbConnect(drv=RSQLite::SQLite(), dbname=dbname) # connect to db
  on.exit(dbDisconnect(con))
  tables <- dbListTables(con) # list all table names
  
  if (is.null(tableName)){
    # get all tables
    lDataFrames <- map(tables, ~{ dbGetQuery(conn=con, statement=paste("SELECT * FROM '", .x, "'", sep="")) })
    # name tables
    names(lDataFrames) <- tables
    return (lDataFrames)
  }
  else{
    # get specific table
    return(dbGetQuery(conn=con, statement=paste("SELECT * FROM '", tableName, "'", sep="")))
  }
}

# get all tables
lDataFrames <- getDatabaseTables(dbname="YOURSQLITEFILE")

# get specific table
df <- getDatabaseTables(dbname="YOURSQLITEFILE", tableName="YOURTABLE")
df <- getDatabaseTables(dbname="all_species_database.sqlite", tableName="species")

filterDatabaseTables <- function(dbname="YOURSQLITEFILE", tableName=NULL){
  library("RSQLite")
  library("purrr")
  con <- dbConnect(drv=RSQLite::SQLite(), dbname=dbname) # connect to db
  on.exit(dbDisconnect(con))
  tables <- dbListTables(con) # list all table names
  
  if (is.null(tableName)){
    # get all tables
    lDataFrames <- map(tables, ~{ dbGetQuery(conn=con, statement=paste("SELECT * FROM '", .x, "'", sep="")) })
    # name tables
    names(lDataFrames) <- tables
    return (lDataFrames)
  }
  else {
    # get specific table with filter
    filteredData <- dbGetQuery(conn=con, statement=paste("SELECT * FROM '", tableName, "' WHERE name IN ('Pinus contorta [low elevation]', 'Abies lasiocarpa')", sep=""))
    
    # Overwrite the existing table with the filtered data
    dbWriteTable(conn=con, name=tableName, value=filteredData, overwrite=TRUE, row.names=FALSE)
    
    return(filteredData)
  }
}

updateTable <- function(dbname, tableName){
  library(RSQLite)
  library(purrr)
  library(tidyverse)
  con <- dbConnect(drv=RSQLite::SQLite(), dbname=dbname) # connect to db
  on.exit(dbDisconnect(con))
  tables <- dbListTables(con) # list all table names
  
  filteredData <- dbGetQuery(conn=con, statement=paste("SELECT * FROM ", tableName, sep=""))
  
  ###### EDIT TABLE BELOW
  
  non_leap_years <- filteredData %>% filter(month == 12, day == 31) %>% pull(year)
  
  new_rows <- filteredData %>% 
    filter(!(year %in% non_leap_years), month == 12, day == 30) %>% #select leap years
    mutate(day = 31)
  
  filteredData <- rbind(filteredData, new_rows) %>% 
    arrange(year, month, day)
  
  ###### EDIT TABLE ABOVE

  # Overwrite the existing table with the filtered data
  dbWriteTable(conn=con, name=tableName, value=filteredData, overwrite=TRUE, row.names=FALSE)
    
  print("update completed")
}
