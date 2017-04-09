# Soccer Result Prediction

SoccerPrediction is an shiny application that analyzes previous match and predicts the probability for  match outcome of upcoming game. 

This project involves following steps:  
1) Data Scraping  
2) Data Preprocessing  
3) Model Building  
4) Validation  
5) Prediction  
 
Initially, soccer match data between number of countries are collected from number of online sources and processed to convert it to suitable format. Then, it is loaded to database. Before starting the phase of model building, feature vector was created.
|previous 5 match results for home team|previous 5 match results for away team| previous 3 match results  between these team | match result

This feature vector has 13 columns as input and one column as output. The probable values for output is   
1 -> home win  
0 -> draw  
-1 -> away win  

Since the output is categorical variable, this is the problem of classification. Different algorithms were used to learn training data and random forest was seen to outperform all other methods with accuracy of 63.85%. However, the drawback of random forest is that it requires more data to create model. There might be the scenario that team A is playing team B for first time. In such case, ranking of teams in FIFA rankings plays significant role along with previous matches of respective teams. If training data is less, Naive Bayes is used to create model.

The output of the project is hosted in [Soccer Prediction](https://kishankc.shinyapps.io/SoccerPrediction/).