library(dplyr)
library(rvest)
library(stringi)
library(stringr)
library(ggmap)

match_urls_all <- as.data.frame(read.table('./datasets/auxiliary/match_urls.txt', header = TRUE))
names(match_urls_all) <- "url"
match_urls_all$id <- stri_sub(match_urls_all$url,-7,-2)
match_urls <- match_urls_all[!duplicated(match_urls_all$id),1]


teamUrl <- "http://www.11v11.com"

PlayerMatch <- data.frame(player = character(0),
                          country = character(0),
                          is_sub = character(0),
                          date = character(0),
                          goals = character(0),
                          stringsAsFactors=FALSE)
j = 9532
positions <- c("Goalkeeper", 
               "Defender", 
               "Midfielder",
               "Forward",
               "Defender/Centre back",
               "Defender/Midfielder",
               "Defender/Left back", 
               "Defender/Right back",
               "Midfielder/Striker",
               "Midfielder/Forward",
               " (captain)",
               "Full back")

for (i in match_urls[9532:16005]){
  lineups <- NULL
  homeLineup <- NULL
  awayLineup <- NULL
  homeSubstitution <- NULL
  awaySubstitution <- NULL
  awayteamGoals <- NULL
  hometeamGoals <- NULL
  goals <- NULL
  print(paste("Counter",j,sep = "->"))
  matchUrl <- paste(teamUrl,i,sep="")
  matchHtml <- read_html(URLencode(matchUrl))
  match_title1 <- matchHtml %>%
    html_node(xpath = '//*[@id="pageContent"]/div[2]/h1') %>%
    html_text()
  
  match_title <- strsplit(match_title1, ", ")
  matchVs <- match_title[[1]][1]
  matchDate <-match_title[[1]][2]
  teams <- strsplit(matchVs, " v ")
  hometeam <- teams[[1]][1]
  awayteam <- teams[[1]][2]
  homeLineup <- NULL
  awayLineup <- NULL
  
  emptyvenue  <- matchHtml %>%
    html_node(xpath = '//*[@id="pageContent"]/div[2]/div/div/div[1]/table') %>%
    html_text()
  
  if(length(emptyvenue)!=0 && emptyvenue != ""){
    
  venue  <- matchHtml %>%
    html_node(xpath = '//*[@id="pageContent"]/div[2]/div/div/div[1]/table') %>%
    html_table()
  
  venues <- ifelse(length(venue[tolower(venue$X1) == 'venue',2])==0,
                  ' ',
                  venue[tolower(venue$X1) == 'venue',2])
  
  score <- ifelse(length(venue[tolower(venue$X1) == 'score',2])==0,
                  ' ',
                  venue[tolower(venue$X1) == 'score',2])
  
  competition <- ifelse(length(venue[tolower(venue$X1) == 'competition',2])==0,
                  ' ',
                  venue[tolower(venue$X1) == 'competition',2])
  }
  emptyLineup <- matchHtml %>%
    html_node('#pageContent > div.match-report > div > div > div.teams-new > div.lineup')
  
  if(length(emptyLineup)!=0 && emptyLineup != ""){
    homeLineup <- matchHtml %>%
      html_node('#pageContent > div.match-report > div > div > div.teams-new > div.lineup > div.home') %>%
      html_text() %>%
      strsplit(split = "[\r\n]|[\r\t]") %>%
      unlist() %>%
      .[. != ""]
    
    data <- homeLineup[2:length(homeLineup)]
    data <- data[!(data %in%positions)]
    homeLineups <- data.frame("player" = data)
    homeLineups$country <- rep(hometeam, nrow(homeLineups))
    
    awayLineup <- matchHtml %>%
      html_node('#pageContent > div.match-report > div > div > div.teams-new > div.lineup > div.away') %>%
      html_text() %>%
      strsplit(split = "[\r\n]|[\r\t]") %>%
      unlist() %>%
      .[. != ""]
    
    data <- awayLineup[2:length(awayLineup)]
    data <- data[!(data %in%positions)]
    awayLineups <- data.frame("player" = data)
    awayLineups$country <- rep(awayteam, nrow(awayLineups))
    
    lineups <- rbind(homeLineups, awayLineups)
    lineups$is_sub <- rep('N',nrow(lineups))
  }
  
  emptySubstitutions <- matchHtml %>%
    html_node('#pageContent > div.match-report > div > div > div.teams-new > div.substitutions')
  
  if(length(emptySubstitutions)!=0 && emptySubstitutions != ""){
    emptyhomeSubstitution  <- matchHtml %>%
      html_node('#pageContent > div.match-report > div > div > div.teams-new > div.substitutions > div.home > table> tbody') %>%
      html_text()
    if (length(emptyhomeSubstitution) != 0 && !is.na(emptyhomeSubstitution) && emptyhomeSubstitution != ""){
      
      homeSubstitution <- matchHtml %>%
        html_node('#pageContent > div.match-report > div > div > div.teams-new > div.substitutions > div.home > table') %>%
        html_table()
      
      homeSubstitution$X1 <- lapply(homeSubstitution$X1, function(x){
        strsplit(str_replace_all(x,"[\r\n]|[\r\t]",""), "for ")[[1]][1]
      })
      homeSubstitution$country <- rep(hometeam, nrow(homeSubstitution))
    }
    
    emptyawaySubstitution  <- matchHtml %>%
      html_node('#pageContent > div.match-report > div > div > div.teams-new > div.substitutions > div.away > table > tbody') %>%
      html_text()
    if (length(emptyawaySubstitution) != 0 && !is.na(emptyawaySubstitution) &&  emptyawaySubstitution != ""){
      awaySubstitution <- matchHtml %>%
        html_node('#pageContent > div.match-report > div > div > div.teams-new > div.substitutions > div.away > table') %>%
        html_table()
      
      awaySubstitution$X1 <- lapply(awaySubstitution$X1, function(x){
        strsplit(str_replace_all(x,"[\r\n]|[\r\t]",""), "for ")[[1]][1]
      })
      awaySubstitution$country <- rep(awayteam, nrow(awaySubstitution))
    }
    substitutions <- rbind(homeSubstitution[,c('X1','country')], awaySubstitution[,c('X1','country')])
    names(substitutions) <- c("player","country")
    substitutions$player <- factor(unlist(substitutions$player))
    substitutions$is_sub <- "Y"
    
    lineups <- rbind(lineups, substitutions)
  }
  
  emptyGoals <- matchHtml %>%
    html_node('#pageContent > div.match-report > div > div > div.teams-new > div.goals')
  
  if(length(emptyGoals)!=0){
    emptyhometeamGoals  <- matchHtml %>%
      html_node('#pageContent > div.match-report > div > div > div.teams-new > div.goals > div.home > table > tbody') %>%
      html_text()
    if (length(emptyhometeamGoals) != 0 && emptyhometeamGoals != ""){
      
      hometeamGoals <- matchHtml %>%
        html_node('#pageContent > div.match-report > div > div > div.teams-new > div.goals > div.home > table') %>%
        html_table()
      hometeamGoals <- as.data.frame(table(hometeamGoals$X1))
    }
    
    emptyawayteamGoals  <- matchHtml %>%
      html_node('#pageContent > div.match-report > div > div > div.teams-new > div.goals > div.away > table > tbody') %>%
      html_text()
    if (length(emptyawayteamGoals) != 0 && emptyawayteamGoals != ""){
      
      awayteamGoals <- matchHtml %>%
        html_node('#pageContent > div.match-report > div > div > div.teams-new > div.goals > div.away > table') %>%
        html_table()
      awayteamGoals <- as.data.frame(table(awayteamGoals$X1))
    }
    goals <- rbind(hometeamGoals, awayteamGoals)
  }
  if(is.null(goals)){
    goals <- data.frame("player"=lineups$player,
                        "goals"=rep(0,length(lineups$player)))
  } else {
    names(goals) <- c("player","goals")
  }
  goals$goals <- as.factor(goals$goals)
  lineups <- merge(lineups, goals, all.x = TRUE)
  lineups$date <- rep(matchDate, nrow(lineups))
  lineups$score <- rep(score, nrow(lineups))
  lineups$competition <- rep(competition, nrow(lineups))
  lineups$matchtitle <- rep(match_title1, nrow(lineups))
  lineups$venue <- rep(venues, nrow(lineups))
  PlayerMatch <- rbind(PlayerMatch, lineups)
  j <- j + 1
}

PlayerMatch <- setdiff(PlayerMatch, PlayerMatch[grep("/",PlayerMatch$player),]) 
PlayerMatch <- PlayerMatch[!(PlayerMatch$player %in% positions),]
# PlayerMatchs$date <- as.Date(PlayerMatchs$date, "%d %h %Y")
 write.csv(PlayerMatch,"./datasets/Scraped data/playerMatch4.csv")
# 
# PlayerMatchs <- read.csv("./datasets/Scraped data/playerMatch2.csv", header = TRUE)
# PlayerMatchs$date <- as.Date(PlayerMatchs$date, "%d %h %Y")
# PlayerMatchs <- PlayerMatchs[PlayerMatchs$date > '2000-01-01',]
# 
# PlayerMatchs <- PlayerMatchs %>%
# group_by(date,country, is_sub) %>%
# mutate(count=n())
# 
# data <- PlayerMatchs %>%
# group_by(date,country, is_sub) %>%
# mutate(lineup_rank = rank(-player))
# 
# data[data$lineup_rank>11,]$is_sub <- 'Y'
# data <- data %>%
#   group_by(date,country, is_sub) %>%
#   mutate(lineup_rank = rank(-player))
# 
# PlayerMatchRelation <- data[,2:6]
# PlayerMatchRelation$goals[is.na(PlayerMatchRelation$goals)] <- 0

