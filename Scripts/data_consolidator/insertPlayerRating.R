# install.packages("RPostgreSQL")
require("RPostgreSQL")

# NOTE: THIS IS THE VARIABLE THAT NEEDS TO BE CONFIGURED TO INDICATE WHICH DATA WE ARE PPULATING THE DATABASE
table_name <- "PlayerRating"


# create a connection
# save the password that we can "hide" it as best as we can by collapsing it
pw <- {
  "aiWohb1auxie9Ahgiu7g"
}

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# creates a connection to the postgres database
con <- dbConnect(drv, dbname = "p62002a",
                 host = "reddwarf.cs.rit.edu", port = 5432,
                 user = "p62002a", password = pw)
rm(pw) # removes the password



# check for the existence of our MatchLocation table
if(dbExistsTable(con,table_name)){
  sql <- paste('TRUNCATE  public."',table_name,'" CASCADE;', sep = "")
  dbGetQuery(con, sql)
}

#if(dbExistsTable(con,table_name)) {dbRemoveTable(con,table_name)}

# Loads data frame
path <- paste ("datasets/formatted_data/", table_name,".csv", sep = "")
csv_file <-read.table(path,sep=",",quote='"',fill = TRUE,header=TRUE)
df <- data.frame(csv_file)
df$player_id <- as.integer(df$player_id)
df$year <- as.integer(df$year)
df$position <- as.integer(df$position)
df$rating <- as.integer(df$rating)
df$pace <- as.integer(df$pace)
df$shoot <- as.integer(df$shoot)
df$pass <- as.integer(df$pass)
df$dribble <- as.integer(df$dribble)
df$defend <- as.integer(df$defend)
df$physical <- as.integer(df$physical)


# writes df to the PostgreSQL database "postgres", table "cartable" 
#dbWriteTable(con, table_name, value = df, append = TRUE, row.names = FALSE)
dbWriteTable(con, table_name, value = df,append = TRUE, row.names = FALSE)

# query the data from postgreSQL
sql_query <- paste('SELECT * from public."',table_name,'"', sep="")
df_postgres <- dbGetQuery(con, sql_query)

# compares the two data.frames
identical(df, df_postgres)




