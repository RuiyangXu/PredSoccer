# Soccer Match Prediction - Team Null Pointer Exception
###### Joanna CS Santos, Kishan KC, Danielle Gonzalez, Ruiyang Xu



### Project Description
This project is a web application which predicts soccer match outcomes between two teams based on:
* Match Location
* Team Ratings
* Past Match Outcomes 
* Player Ratings

and outputs three probabilities:
1.  Team A Win
2.  Team B Win
3.  Match Draw

### Tech

 **Web Application**: [Shiny](https://shiny.rstudio.com/)
 **Data Analysis**: R
 **Web Scraping**: R and Python
 **Database**: PostgreSQL


### Project Organization
There are two main directories for the project:

**bigdata** directory contains information used to design the project and collect the data:
* **Scripts**: the data crawler, formatter, preprocessor, and consolidator code
* **datasets**: the raw, preprocessed, and formatted CSV output from the crawlers
* **diagrams**: architecture, schema, and figures for report
* **MeetingLogs**: Record of our meetings 
* **README**: This document

**shiny_app**: the actual application directory

### Running the Application
1. Open the shiny_app directory in RStudio
2. open the ui.R file and click 'Run App'
3. Application will automatically open a browser and run on localhost

### Team Contributions 
The following describes what each person on the team did:
#### Kishan
* Wrote Web Crawler for Past Matches/Player relation data
* Initialized Analysis Model & Shiny App
* Integrated `past match outcomes` and `team ranking` features into model
#### Joanna
* Wrote Web Crawler for Weather (Discontinued) 
* Wrote Web Crawler to get location data for Match/Location relation data
* Imported data into DB
* Integrated `win percentages for teams` into model
#### Danielle
* Wrote Web Crawler for Player Rating relation data
* Integrated `location` feature into model
* Integrated location dropdown into Shiny interface
* Wrote README
#### Ruiyang
* Wrote Web Crawler for Team/Squad relations
* Wrote neural network model for `player ratings` feature
#### As a Team
* architectural & design decisions
* data analysis *decisions*
* report writing
* presentation writing

