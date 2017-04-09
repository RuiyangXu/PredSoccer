
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(stringi)
library(ggplot2)
library(plotly)
source('functions.R')

shinyServer(function(input, output, session) {
  output$distPlot <- renderPlot({

    # generate bins based on input$bins from ui.R
    result    <- as.data.frame(t(predict_byMatch(input$team_a, input$team_b, input$location)))
    colnames(result) <- 'prob'
    result$outcome  <- as.character(rownames(result))
    result$prob <- as.numeric(100 * result$prob)
    result$outcome[which(result$outcome=='-1')] <- paste(input$team_b,' Win', sep = '')
    result$outcome[which(result$outcome=='0')] <- 'Draw'
    result$outcome[which(result$outcome=='1')] <- paste(input$team_a,' Win', sep = '')
    ggplot(result, aes(x = outcome, y = as.numeric(prob), fill = outcome)) + 
      geom_bar(stat='identity') +
      ggtitle(paste('Predicted probability of match outcome between ',input$team_a,' and ', input$team_b, sep = '',' at ',input$location)) +
      xlab("Match Outcome") +
      ylab("Probability based on previous matches") +
      geom_text(aes(label=prob),size=5, position= position_dodge(width=0.9), vjust=-.5, color="black") +
      ylim(0,100)
    # ggplotly()
  })
  output$table1 <- renderTable({
    result <- getHeadtoHead(input$team_a, input$team_b)
    names(result) <- c("outcome","numbers","Recent Games")
    result$outcome <- as.character(result$outcome)
    result[which(result$outcome=='-1'),1] <- paste(input$team_b,' Win', sep = '')
    result[which(result$outcome=='0'),1] <- 'Draw'
    result[which(result$outcome=='1'),1] <- paste(input$team_a,' Win', sep = '')
    result <- rbind(result, c("Matches", sum(result$numbers)))
    result <- as.data.frame(t(result))
    recent_result <- as.character(paste(result[3,1], collapse = " "))
    rownames(result) <- NULL
    colnames(result) <- NULL
    result <- result[1:2,]
    row <- c("Recent Matches", recent_result, " ", "")
    result[,1] <- as.character(result[,1] )
    result[,2] <- as.character(result[,2] )
    result[,3] <- as.character(result[,3] )
    result[,4] <- as.character(result[,4] )
    result <- rbind(result ,row)
    result
  })
  
  output$homeForm <- renderPrint(paste(getRecentForm(input$team_a), collapse = " "))
  output$awayForm <- renderPrint(paste(getRecentForm(input$team_b), collapse = " "))
})
