library(dplyr)
library(tidyr)
data <- read.csv("./datasets/Scraped data/matchdata.csv", header = TRUE)
matchdata <- data
#Convert date column in data to date format 
data$Date <- as.Date(data$Date, "%d %h %Y")

#Convert match column in data to character format
data$Match <- as.character(data$Match)

#Convert score column in data to character format
data$Score <- as.character(data$Score)

#Convert Competition column in data to factor format
data$Competition <- as.factor(data$Competition)


data <- data %>%
  separate(Score, into = c("homeTeamScore", "awayTeamScore"), sep = "-") 

data <- data %>%
  separate(Match, into = c("homeTeam", "awayTeam"), sep = " v ") 

write.csv(data, "datasets/preprocessedMatchData.csv", row.names = FALSE)
