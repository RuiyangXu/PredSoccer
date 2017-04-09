library("neuralnet")
data <- read.csv("rating.csv")
net <- neuralnet(win+draw+loss~home_rating+away_rating, data, hidden=4, stepmax=1e6)

plot(net)

