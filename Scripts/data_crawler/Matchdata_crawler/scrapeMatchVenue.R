library(dplyr)
library(rvest)
library(stringi)
library(ggmap)

teamUrl <- "http://www.11v11.com"

venueForMatch <- data.frame(id = character(0), max1 = character(0), max2 = character(0),stringsAsFactors=FALSE)
PlayerMatch <- data.frame()
for (i in match_urls){
      matchUrl <- paste(teamUrl,i,sep="")
      matchHtml <- read_html(URLencode(matchUrl))
      match_title <- matchHtml %>%
        html_node(xpath = '//*[@id="pageContent"]/div[2]/h1') %>%
        html_text()
      
      match_title <- strsplit(match_title, ", ")
      venue  <- matchHtml %>%
        html_node(xpath = '//*[@id="pageContent"]/div[2]/div/div/div[1]/table') %>%
        html_table()
      
      venue <- ifelse(length(venue[tolower(venue$X1) == 'venue',2])==0,
                      ' ',
                      venue[tolower(venue$X1) == 'venue',2])
      matchVs <- match_title[[1]][1]
      matchDate <- match_title[[1]][2]
      venuedata <- data.frame(as.character(matchVs), as.character(matchDate), as.character(venue))
      venueForMatch <- rbind(venueForMatch, venuedata)
      print(nrow(venueForMatch))
}

write.csv(venueForMatch, "./datasets/Scraped data/venueForMatch.csv", row.names = FALSE)


venueForMatch <- read.csv("./datasets/Scraped data/venueForMatch.csv", header = TRUE)
