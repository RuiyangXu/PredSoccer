library(dplyr)
library(rvest)
library(stringi)
teamUrl <- read_html("http://www.11v11.com/teams/chile/tab/opposingTeams/opposition/Brazil/")

teams <- teamUrl %>% 
  html_node(xpath = '//*[@id="opposition"]') %>%
  html_text()

teams <- strsplit(teams, "\n")
countryVs <- data.frame()
match_urls_all <- data.frame()
for (i in teams[[1]]){
  for (j in teams[[1]]){
    if (i != j) {
      matchData <- NULL
      matchUrl <- paste("http://www.11v11.com/teams/",tolower(i),"/tab/opposingTeams/opposition/",j,"/",sep="")
      print(paste(i, j, sep = " Vs. "))
      matchHtml <- read_html(URLencode(matchUrl))
      urls  <- matchHtml %>%
        html_nodes("a") %>% html_attr("href")
      match_urls_index <- grep('^/matches',urls)
      match_urls <- as.data.frame(urls[match_urls_index])
      match_urls_all <- rbind(match_urls_all, match_urls)
    }
  }
}


write.table(match_urls_all, "./datasets/auxiliary/match_urls.txt", row.names = FALSE)

