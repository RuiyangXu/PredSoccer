# install.packages("RPostgreSQL")
require("RPostgreSQL")

# NOTE: THIS IS THE VARIABLE THAT NEEDS TO BE CONFIGURED TO INDICATE WHICH DATA WE ARE PPULATING THE DATABASE
table_name <- "MatchLocation"


# create a connection
# save the password that we can "hide" it as best as we can by collapsing it
pw <- {
  "aiWohb1auxie9Ahgiu7g"
}

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "p62002a",
                 host = "reddwarf.cs.rit.edu", port = 5432,
                 user = "p62002a", password = pw)
rm(pw) # removes the password



# check for the existence of our MatchLocation table and truncate
if(dbExistsTable(con,table_name)){
  sql <- paste('TRUNCATE  public."',table_name,'" CASCADE;', sep = "")
  dbGetQuery(con, sql)
}


# Loads data frame
path <- paste ("datasets/formatted_data/", table_name,"_new.csv", sep = "")
csv_file <-read.table(path,sep=",",quote='"',fill = TRUE,header=TRUE)
df <- data.frame(csv_file)
df$id <- as.integer(df$id)
df$name <- as.character(df$name)
df$latitude <- as.double(df$latitude)
df$longitude <- as.double(df$longitude)


# writes df to the PostgreSQL database "postgres", table "cartable" 
#dbWriteTable(con, table_name, value = df, append = TRUE, row.names = FALSE)
dbWriteTable(con, table_name, value = df,append = TRUE, row.names = FALSE)

# query the data from postgreSQL
sql_query <- paste('SELECT * from public."',table_name,'"', sep="")
df_postgres <- dbGetQuery(con, sql_query)

# compares the two data.frames
identical(df, df_postgres)