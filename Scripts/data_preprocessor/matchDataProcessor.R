library(dplyr)
library(tidyr)
matchData <- read.csv("./datasets/Scraped data/matchdata.csv", header = TRUE)
names(matchData) <- c("date","match","result","score","competition")
matchData$date <- as.Date(matchData$date, '%d %h %Y')
#matchData <- matchData[matchData$date > '2010-01-01',]
#Convert match column in data to character format
matchData$match <- as.character(matchData$match)

#Convert score column in data to character format
matchData$score <- as.character(matchData$score)

#Convert competition column in data to factor format
matchData$competition <- as.factor(matchData$competition)
matchData2 <- matchData
competitions <- c("Merdeka Tournament",
                  "International Friendly",
                  "FIFA World Cup",
                  "African Games",
                  "FIFA Confederations Cup",
                  "FIFA 90 World Cup",
                  "AFC Asian Cup",
                  "UEFA European Championship")
#matchData <- matchData[matchData$competition %in% competitions, ]

matchData$teams <- strsplit(matchData$match," v ")
matchData$teams <- lapply(matchData$teams, function(x){ sort(x)})
matchData$teams <- lapply(matchData$teams, function(x){ paste(x[1],x[2],sep=" v ")})
matchData$teams <- as.character(matchData$teams)
matchData <- matchData %>%
              group_by(date, teams) %>%
              mutate(rnk = row_number())

matchData <- matchData[matchData$rnk==1,]


matchData$matchtitle <- matchData$match
matchData$scoreline <- matchData$score
matchData[,c("rnk")] <- list(NULL)

matchData$scoreline <- ifelse(matchData$scoreline=="",0, matchData$scoreline)
matchData <- matchData[!(matchData$scoreline==0),]

matchData <- matchData %>%
  separate(scoreline, into = c("homeTeamScore", "awayTeamScore"), sep = "-") 

matchData <- matchData %>%
  separate(matchtitle, into = c("homeTeam", "awayTeam"), sep = " v ") 


data <- read.csv("datasets/preprocessedMatchData.csv", header = TRUE)
matchData <- data[,1:5]
matchData$Match<- gsub('USSR', 'Russia', matchData$Match)
matchData$Match<- gsub('Czechoslovakia', 'Czech Republic', matchData$Match)
matchData$Match<- gsub('West Germany', 'Germany', matchData$Match)

write.csv(matchData, "datasets/preprocessedMatchData.csv", row.names = FALSE)
matchData$matchID<-seq.int(nrow(matchData))

players <- as.data.frame(read.table("./datasets/Scraped data/players.txt",header = TRUE))

# playersMatch <- read.csv("./datasets/Scraped data/playerMatchs.csv",header = TRUE)
 # playersMatch$date <- as.Date(playersMatch$date, '%d %h %Y')

 # playersMatch <- playersMatch %>%
                 
 # 
# df <- left_join(playersMatch, matchData)
# df$exists_country <- mapply(grepl, pattern=df$country, x=df$match)
# df <- df[df$exists_country==TRUE,]
# test <- data.frame(table(df$matchID))

