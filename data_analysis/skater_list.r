fun.postgres_connect <- function(db.name, db.host, db.user){
  #DECRIPTION: Creates a connection to a PostgreSQL Server
  #ARGUMENTS: 
  #db.name = The name of the database to connect to
  #db.host = The host ("localhost" or IP Address)
  #db.user = The name of the user to connect with
  
  require(RPostgreSQL)
  
  #Set the connection drive for PostgreSQL
  db.drv <- dbDriver("PostgreSQL")
  
  #Prompt for Password
  db.pw <- readline(prompt = "Enter your Password: ")
  
  #Create Connection
  db.con <- 
    dbConnect(db.drv, 
              dbname = as.character(db.name), 
              host = as.character(db.host), 
              port = 5432, 
              user = as.character(db.user), 
              password = db.pw)
  
  #Clear the pasword entered above
  rm(db.pw)
  
  return(db.con)
}

library(plyr)
library(dplyr)

if(!exists("db.conn")){
  db <- readline(prompt = "Enter Database Name: ")
  host <- readline(prompt = "Enter Host: ")
  user <- readline(prompt = "Enter User: ")
  
  db.conn <- fun.postgres_connect(db, host, user)
}

select_columns <- 
  paste("skater_stats.season",
        "skater_stats.game_id",
        "skater_stats.player",
        "skater_bios.date_of_birth",
        "skater_bios.draft_year",
        "skater_stats.gs", 
        sep = ", ")

join_columns <- 
  paste("skater_stats.player = skater_bios.player", 
        " AND ", 
        "skater_stats.team = skater_bios.team")

filter_columns <- 
  paste("skater_bios.draft_year >= '2007'",
        " OR ",
        "skater_bios.date_of_birth >= '1989-1-1'")

sql.join_query <- 
  paste0("SELECT ", 
         select_columns, 
         " FROM skater_stats LEFT JOIN skater_bios ON ",
         join_columns,
         " WHERE ",
         filter_columns,
         ";")

#Need to use fun.postgres_connect to create db.conn first
df.joined_skaters <- dbGetQuery(db.conn, sql.join_query)
