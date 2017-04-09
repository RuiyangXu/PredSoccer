getDBConnection <- function(){
  # install.packages("RPostgreSQL")
  require("RPostgreSQL")
  
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
  con
}

getLocations <- function(con){
  if(dbExistsTable(con, "MatchLocation")){
    # query the data from postgreSQL 
    locations <- dbReadTable(con, "MatchLocation")
  }
  locations
}

getTeams <- function(con, team_name) {
  if(dbExistsTable(con, "Team")){
    # query the data from postgreSQL 
    Team <- dbReadTable(con, "Team")
  }
  Team
}
getMatchDataFromDB <- function(con){
  
  # check for the cartable
  if(dbExistsTable(con, "Match")){
    # query the data from postgreSQL 
    matchData <- dbReadTable(con, "Match")
  }
  matchData
}

# Returns statistics of teams (percentage of wins of Team A, percentages of wins of team B)
getTeamsStatistics <- function(con, teamA, teamB){
  df_features_teamAteamB <- dbGetQuery(con, paste("SELECT * FROM team_statistics(",teamA,",",teamB,")",sep=""))
  df_features_teamAteamB
}

predict_byMatch <- function(teamA, teamB, location){ 
  library(randomForest)
  library(caret)
  library(dplyr)
  library(e1071)
  con <- getDBConnection()
  rankings <- read.table("datasets/rankings.txt", header = TRUE)[,1:2]
  rankA <- subset(rankings, Team == teamA)[,1]
  rankB <- subset(rankings, Team == teamB)[,1]
  rankA <- ifelse(is.na(rankA),200,rankA)
  rankB <- ifelse(is.na(rankB),200,rankB)
  matchData <- getMatchDataFromDB(con)
  matchData$location_id[is.na(matchData$location)] <- 0
  teams <- getTeams(con)
  locations <- getLocations(con)
  location_ID <- locations$id[locations$name==location]

  teamA_ID <- teams$id[teams$country==teamA]
  teamB_ID <- teams$id[teams$country==teamB]
  matchData <- matchData[matchData$home_team_id == teamA_ID|matchData$home_team_id == teamB_ID |
                           matchData$away_team_id == teamA_ID|matchData$away_team_id == teamB_ID,  ]
  dataset1 <-matchData[matchData$home_team_id == teamA_ID|matchData$away_team_id == teamA_ID,]
  dataset2 <-matchData[matchData$home_team_id == teamB_ID|matchData$away_team_id == teamB_ID,]
  
  
  dataset1 <- mutate(dataset1, win = ifelse(home_team_id == teamA_ID & home_team_score > away_team_score, 1, 
                                            ifelse(away_team_id == teamA_ID & home_team_score < away_team_score,1,
                                                   ifelse(home_team_score == away_team_score,0,-1))))
  dataset2 <- mutate(dataset2, win = ifelse(home_team_id == teamB_ID & home_team_score > away_team_score, 1, 
                                            ifelse(away_team_id == teamB_ID & home_team_score < away_team_score,1,
                                                   ifelse(home_team_score == away_team_score,0,-1))))
  
  dataset <-dataset1[dataset1$home_team_id == teamB_ID|dataset1$away_team_id == teamB_ID ,]
  dataset11 <- dataset1[order(dataset1$match_date, decreasing = TRUE),]
  dataset22 <- dataset2[order(dataset2$match_date, decreasing = TRUE),]
  dataset <- dataset[order(dataset$match_date, decreasing = TRUE),]
  dataset <- dataset[!duplicated(dataset),]
  dataset11$match_date <- as.Date(dataset11$match_date)
  dataset22$match_date <- as.Date(dataset22$match_date)
  dataset$match_date <- as.Date(dataset$match_date)
  final_dataset <- data.frame()
  # location data 
  teamA_match_locations <- dataset1[dataset1$location_id == location_ID,] # all locations a played
  teamB_match_locations <- dataset2[dataset2$location_id == location_ID,] # all locations b played
  totalHomeWinPercent <- nrow(dataset11[dataset11$win==1,])/nrow(dataset11)
  totalAwayWinPercent <- nrow(dataset22[dataset22$win==1,])/nrow(dataset22)

  
  teamsStats = getTeamsStatistics(con,teamA_ID,teamB_ID) # get percentage of wons to team A and team B
  teamsStats$home_team_wons = as.double(teamsStats$home_team_wons)
  teamsStats$away_team_wons = as.double(teamsStats$away_team_wons)
  print("HERE")
  print(teamsStats)
  # get percentage of matches won by all teams in all locations 
  bothTeamStats <- c(teamsStats$home_team_wons, teamsStats$away_team_wons)
  
  for (i in 1:nrow(dataset)){
    match_date <- as.Date(dataset[i,'match_date'])
    bothTeamData <- (1/rankA) * (1/rankB) * 5 * exp(dataset[dataset$match_date<match_date,][1:3,'win'])
    
    #==================== Create Home Team Data Rows =====================================#
    if(length(teamA_match_locations) != 0){
      teamA_wins_at_location <- teamA_match_locations[teamA_match_locations$win == 1,]
      # get percentage of matches won by teamA at location
      teamAWinPercent <- 0 #initialize at 0
      if(length(teamA_wins_at_location) != 0){
        teamAWinPercent <- nrow(teamA_wins_at_location)/nrow(teamA_match_locations)
        #print(paste("team A wins: ",length(teamA_wins_at_location)," team A all: ", length(teamA_match_locations)))
      }
      # weight the data based on wins at location
      home_team_idData <- (1/rankA) * (teamAWinPercent*nrow(teamA_match_locations)) * exp(dataset11[dataset11$match_date < match_date,][1:5,'win'])
    }
    else{
      # weight the data based on all matches won in all games
      home_team_idData <- (1/rankA) * totalHomeWinPercent * exp(dataset11[dataset11$match_date < match_date,][1:5,'win'])
    }
    #==================== Create Away Team Data Rows =====================================#
    if(length(teamB_match_locations) != 0){
      teamB_wins_at_location <- teamB_match_locations[teamB_match_locations$win == 1,]
      
      # get percentage of matches won by teamB at location
      teamBWinPercent <- 0 #initialize at 0
      if(length(teamB_wins_at_location) != 0){
        teamBWinPercent <- nrow(teamB_wins_at_location)/nrow(teamB_match_locations)
        #print(paste("team B wins: ",length(teamB_wins_at_location)," team b all: ", length(teamB_match_locations)))
      }
      # weight the data based on wins at location
      awayTeamData <- (1/rankB) * (teamBWinPercent*nrow(teamB_match_locations)) * exp(dataset22[dataset22$match_date < match_date,][1:5,'win'])
    }
    else{
      # weight the data based on all matches won in all games
      awayTeamData <- (1/rankB) * totalAwayWinPercent * exp(dataset22[dataset22$match_date < match_date,][1:5,'win'])
    }

    data <- c(home_team_idData, awayTeamData, bothTeamData, bothTeamStats , dataset[i,]$win)
    data[is.na(data)] <- 0
    if(sum(data)==0){
      data <- NULL
    }
    final_dataset <- rbind(final_dataset, data)
  }
  if(nrow(final_dataset)>0){
    names(final_dataset) <- c('home_1','home_2','home_3', 'home_4', 'home_5', 
                              'away_1','away_2','away_3', 'away_4', 'away_5', 
                              'both_1','both_2','both_3', 'home_team_wons', 'away_team_wons',
                              'win')
    final_dataset$win <- as.factor(final_dataset$win)
  }
  if(nrow(final_dataset) < 10){
  
    homeProb <- (rankB/(rankA + rankB)) * totalHomeWinPercent
    awayProb <- (rankA/(rankA + rankB)) * totalAwayWinPercent
    predicted <- data.frame(homeProb, awayProb, 1 - homeProb - awayProb)
    names(predicted) <- c("1","-1","0")
  } else {
    seed <- 7
    set.seed(seed)
    home_team_idData <- (rankA/(rankA + rankB)) * exp(unlist(dataset11[1:5,'win']))
    awayTeamData <- (rankA/(rankA + rankB)) * exp(unlist(dataset22[1:5,'win']))
    bothTeamData <- (1/rankA) * (1/rankB) * 5 * exp(dataset[1:3,'win'])
    data <- c(home_team_idData, awayTeamData, bothTeamData,bothTeamStats, 0)
    data[is.na(data)] <- 0
    testing_set <- subset(final_dataset, FALSE)
    testing_set <- rbind(testing_set, data)
    names(testing_set) <- names(final_dataset)
    if (nrow(final_dataset) <= 30){
      final_model <- naiveBayes(win ~ ., data = final_dataset)
      type = 'raw'
    } else {
      mtry <- sqrt(ncol(final_dataset))
      tunegrid <- expand.grid(.mtry=mtry, ntree = 1000)
      modelcontrol <- trainControl(method="repeatedcv", number=5, repeats=3, search="random")
      final_model <- train(win ~ ., method = "rf", data = final_dataset, tunegrid=tunegrid, trControl = modelcontrol)
      type = 'prob'
    }
    predicted <- predict(final_model, newdata = testing_set, type= type)
  }
  dbDisconnect(con)
  return(round(predicted,3))
}

getHeadtoHead <- function(teamA, teamB){ 
  library(dplyr)
  con <- getDBConnection()
  
  matchData <- getMatchDataFromDB(con)
  teams <- getTeams(con)
  teamA_ID <- teams$id[teams$country==teamA]
  teamB_ID <- teams$id[teams$country==teamB]
  matchData <- matchData[matchData$home_team_id == teamA_ID|matchData$away_team_id == teamA_ID ,  ]
  matchData <-matchData[matchData$home_team_id == teamB_ID|matchData$away_team_id == teamB_ID ,]
  matchData <- mutate(matchData, win = ifelse(home_team_id == teamA_ID & home_team_score > away_team_score, 'W', 
                                            ifelse(away_team_id == teamA_ID & home_team_score < away_team_score,'W',
                                                   ifelse(home_team_score == away_team_score,'D','L'))))
  matchData$match_date <- as.Date(matchData$match_date)
  matchData <- matchData[order(matchData$match_date, decreasing = TRUE),]
  head2head <- paste(matchData[1:5,"win"], collapse = " ")
  dbDisconnect(con)
  head2head
}


getRecentForm <- function(teamA){
  library(dplyr)
  con <- getDBConnection()
  
  matchData <- getMatchDataFromDB(con)
  teams <- getTeams(con)
  teamA_ID <- teams$id[teams$country==teamA]
  matchData <- matchData[matchData$home_team_id == teamA_ID|matchData$away_team_id == teamA_ID ,  ]
  
  matchData <- mutate(matchData, win = ifelse(home_team_id == teamA_ID & home_team_score > away_team_score, 'W', 
                                              ifelse(away_team_id == teamA_ID & home_team_score < away_team_score,'W',
                                                     ifelse(home_team_score == away_team_score,'D','L'))))
  matchData$match_date <- as.Date(matchData$match_date)
  matchData <- matchData[order(matchData$match_date, decreasing = TRUE),]
  recent_result <- paste(matchData[1:5,"win"], collapse = " ")
  dbDisconnect(con)
  recent_result
}

killDbConnections <- function () {
  
  all_cons <- dbListConnections(PostgreSQL())
  
  print(all_cons)
  
  for(con in all_cons)
    +  dbDisconnect(con)
  
  print(paste(length(all_cons), " connections killed."))
  
}
