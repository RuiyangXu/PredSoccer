playerMatch <- read.csv("datasets/Scraped data/playerMatch.csv", header = TRUE)
playerMatch$country<- gsub('USSR', 'Russia', playerMatch$country)
playerMatch$country<- gsub('Czechoslovakia', 'Czech Republic', playerMatch$country)
playerMatch$country<- gsub('West Germany', 'Germany', playerMatch$country)
playerMatch$score<- gsub('USSR', 'Russia', playerMatch$score)
playerMatch$score<- gsub('Czechoslovakia', 'Czech Republic', playerMatch$score)
playerMatch$score<- gsub('West Germany', 'Germany', playerMatch$score)
playerMatch$matchtitle<- gsub('USSR', 'Russia', playerMatch$matchtitle)
playerMatch$matchtitle<- gsub('Czechoslovakia', 'Czech Republic', playerMatch$matchtitle)
playerMatch$matchtitle<- gsub('West Germany', 'Germany', playerMatch$matchtitle)
playerMatch <- playerMatch[,c(-1,-2)]
playerMatch <- playerMatch[-grep("Starting lineup", playerMatch$player, ignore.case = TRUE),]
write.csv(playerMatch, "datasets/processedPlayerMatchData.csv", row.names = FALSE)