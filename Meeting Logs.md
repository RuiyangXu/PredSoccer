# PredSoccer #

Predsoccer is an application that predicts the result of upcoming match based on scores from past matches.


### Folders: ###
* Papers: Related works on soccer prediction
* scripts: the scripts written for scrapping data from our sources
* datasets: the files containing the data we have collected to populate our database

### Meeting Logs: ###

**09-14-2016**: 

* We considered some influences for each match:
* * Weather (NO: too difficult to acquire forecasts)
* * Starting Team (YES: which team the first kick in the match)
* * Players (YES: The average ratio of the players in the match. The substitutes would have a lower weight in this average calculation )
* * Demographics: (NO)
* * Match Type:(YES World Cup? Friendly Match? Olimpics? Etc)
* * Past Matches: (YES: The outcome - score - of the previous matches of that pair of teams)
* We draw the Arch Diagram 
* * https://www.draw.io/#G0BzZrQPpQSAfiOFkwMFFaeHdiMVk
* **PROBLEM TO THINK OF**: To find out if there is any way to get the list of players that are going to play for the next match that is going to be predicted
* **WHAT NEXT**: Come up with a DB Schema for out next Meeting

**09-23-2016:** 

* Created a Draft of the Scheme: https://drive.google.com/a/g.rit.edu/file/d/0BzZrQPpQSAfic1hUdDVwSzlNWnc/view?usp=sharing
* We got feedback from the professor about the architecture and scheme: He suggested us to bring other events to our database related the match (like weather, or so).
* We found a Web service to get Weather data for a match: https://openweathermap.org/api
* We changed in the Architecture: We do not need to use Rattle (it is just a UI on top of R) as we are already going to use Shiny
* **WHAT NEXT**:  Create a table for other types of data (e.g. weather). Set up our MySQL DB Server

**09-28-2016:** 

* We have written a draft of our phase 1 report
* Updated schema/architecture diagrams
* Got information from the professor to the PostgreSQL Server (details placed @ Trello)
* Set Up our Trello Task Management System
* Divided our tasks (see Trello for details)
* **WHAT NEXT**: Data Integrator, Wrap Up Report and Get PostgreSQL working done
* **NEXT MEETING:** Monday, October  3rd


**10-03-2016:** 

* Updated schema diagram
* Found  new data sources: https://github.com/sanand0/fifadata, https://github.com/HashirZahir/FIFA-Player-Ratings, http://www.11v11.com/
* Created SQL file with the create table statements
* Updated report
* **WHAT NEXT**: Finalize paper, work on integrators
* **NEXT MEETING**: October, 7th


**10-07-2016:** 

* Updated schema/architecture diagram
* Created the tables in the database 
* Updated the report and delivered
* **WHAT NEXT**: Study how to create the probability formula
* **NEXT MEETING**: October 12th

**10-12-2016:** 

* We updated player by removing the ranking attribute. Instead, we have a new relation called PlayerRatings which contains a foreign key to Player ID, the date of a game, the player�s rating after this game, and the opponent. For this data we are including club matches, so opponent is not a foreign key to the Team relation. We do not consider club matches in the rest of our data, but it is important when determining the rating of a player.
* Database Schema and Database have been updated to reflect these changes
* **WHAT NEXT**: 
* Study How to create probability formula
* Each person will create a SQL file with the SQL needed to add their scraped data to the database, to be reviewed by the team before being applied to database
* **NEXT MEETING**: October 19th



**10-19-2016:** 

* Database Schema and Database have been updated to reflect changes on player ratings
* We decided to store only the 25 players in the latest team's formation
* Scripts are and Data being collected
* **WHAT NEXT**: 
* Save the data into csv files
* Merge / filter the csv files
* Insert data from csv files into our DB
* **NEXT MEETING**: October 26th

**10-26-2016:**

* The following Items were addressed
* winning_team_id or result_type (W,L,D)
* remove coach data? yes
* no info on starting_team_id
* do we need location on tournament? Info already on stadium
* what about rename match_time to match_date.
* what to do with missing venues?
* **WHAT NEXT**: 
* Insert data from csv files into our DB
* **NEXT MEETING**: November 2nd

**11-02-2016:**

* DB Partially populated (needs fix on Team Names [e.g. West Germany])
* Wrote First Version of the Second Report 
* Generated reports for our current dataset (number of teams, number of matches, competitions, etc)
* Defined the Analysis we gonna perform (bayes)
* **NEXT MEETING**: November 4th

** 11-16-2016 **

* We decided to instead of creating a single model containung all our predictor variables, we will create separated model based on each variable:
* * Model 1:    Previous Scores (teamA,teamB) --> MatchOutcome(Draw,Lose,Win) * * 
* * Model 2:    Team Skills (teamA,teamB) [based on player ratings] --> MatchOutcome(Draw,Lose,Win) * * 
* * Model 3:    Team Metrics (teamA,teamB) [#GOALS, #LOSES, ETC] --> MatchOutcome(Draw,Lose,Win) * *
* * Model 4:    Weather / Location / Venue (teamA,teamB) --> MatchOutcome(Draw,Lose,Win) * * 
* **NEXT MEETING**: November 23rd




** 11-30-2016 **

* We defined the features we are using for our prediction models and divided the tasks as follows:
* * Features 1:    5 previous matches (teamA,teamB) {Kishan} * * 
* * Features 2:    Team Statistics (teamA,teamB) [based on player ratings] {Rui} * * 
* * Features 3:    Team Metrics (teamA,teamB) [Percentage Wins, Percentage Losses] {Joanna} * *
* * Features 4:    Location (teamA,teamB) {Danielle} * * 
* **NEXT MEETING**: December 2nd

** 12-05-2016 **

* Worked together  immplementing features extraction for prediction
* **NEXT MEETING**: December 5th

** 12-07-2016 **

* Worked together writing the final report
* **LAST PROJECT MEETING**