
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(stringi)
library(plotly)
source('functions.R')

con <- getDBConnection()
teams <- getTeams(con)
locations <- getLocations(con)
teams <- as.data.frame(stri_trans_totitle(teams[,2]))
names(teams) <- 'team'
teams <- as.data.frame(teams[order(teams$team, decreasing = FALSE),])
names(teams) <- 'team'
dbDisconnect(con)
shinyUI(fluidPage(

  # Application title
  titlePanel("Prediction based on previous match outcomes and location"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      # uiOutput("team_a"),
      # uiOutput("team_b"),
      # 
      selectInput("team_a","Select home team",teams$team, "Italy"),
      selectInput("team_b", "Select away team", teams$team, "Germany"),
      selectInput("location", "Select location", locations$name, "Sofia"),
      hr(),
      h4("Home Team recent games"),
      verbatimTextOutput("homeForm"),
      h4("Away Team recent games"),
      verbatimTextOutput("awayForm"),
      width = 5
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      width = 7
    )
  )
))
