library(dplyr)
library(rvest)
teamUrl <- read_html("http://www.11v11.com/teams/chile/tab/opposingTeams/opposition/Brazil/")

teams <- teamUrl %>% 
  html_node(xpath = '//*[@id="opposition"]') %>%
  html_text()

teams <- strsplit(teams, "\n")
countryVs <- data.frame()
for (i in teams[[1]]){
  for (j in teams[[1]]){
    if (i != j) {
      matchData <- NULL
      matchUrl <- paste("http://www.11v11.com/teams/",tolower(i),"/tab/opposingTeams/opposition/",j,"/",sep="")
      print(paste(i, j, sep = " Vs. "))
      matchHtml <- read_html(URLencode(matchUrl))
      emptyBody  <- matchHtml %>%
        html_node(xpath = '//*[@id="pageContent"]/div[2]/table[2]/tbody') %>%
        html_text()
      matchTable <- matchHtml %>%
      html_node(xpath = '//*[@id="pageContent"]/div[2]/table[2]') 
      if (length(matchTable) != 0 && emptyBody != ""){
        matchData <- matchTable %>%
          html_table()
      }
      countryVs <- rbind(countryVs, matchData)
    }
    }
}
names(countryVs) <- c("Date","Match", "Result", "Score", "Competition")
write.table(countryVs, "MatchData.txt", row.names = FALSE)
write.csv(countryVs,"matchdata.csv", row.names = FALSE)
