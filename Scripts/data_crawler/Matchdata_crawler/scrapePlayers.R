library(dplyr)
library(rvest)

teams <- read.csv("./datasets/Scraped data/teams.csv", header = FALSE)
teams <- as.character(teams$V1)
teams[teams=='ussr'] <- 'russia'
teams[teams=='czechoslovakia'] <- 'czech republic'
teams[teams=='west germany'] <- 'germany'
players <- data.frame()
for (team in teams){
  team <- gsub(pattern = ' ',replacement = "-", x = team)
  playerDataAll <- NULL
  for (year in c('2016','2017')){
      playerData <- NULL
      playerUrl <- paste("http://www.11v11.com/teams/",tolower(team),"/tab/players/season/",year,"/",sep="")
      playerHtml <- read_html(URLencode(playerUrl))
      emptyBody  <- playerHtml %>%
        html_node(xpath = '//*[@id="pageContent"]/div[2]/table/tbody') %>%
        html_text()
      playerTable <- playerHtml %>%
        html_node(xpath = '//*[@id="pageContent"]/div[2]/table') 
      if (length(playerTable) != 0 && emptyBody != ""){
        playerData <- playerTable %>%
          html_table(fill = TRUE, header = TRUE)
        playerData <- playerData[!is.na(playerData$Player),c(2,3,4,5)]
        playerData$year <-  rep(year,nrow(playerData))
        playerData$team <- rep(team, nrow(playerData))
      }
      playerDataAll <- rbind(playerDataAll, playerData)
  }
  players <- rbind(players, playerDataAll)
  print(team)
}

names(players) <- c("player","position", "appearance", "goals", "year","team")
write.table(players, "./datasets/Scraped data/players.txt", row.names = FALSE)