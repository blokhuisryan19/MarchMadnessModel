rm(list=ls())
library(randomForest)
library(rpart)
library(rpart.plot)
library(tidyverse)

#Read in the Matchup Data
data = read.csv("master_matchups.csv",stringsAsFactors = TRUE)
data <- subset(data, select = -c(X))

data <- na.exclude(data)
data2 <- subset(data, select = -c(Team1,Team2))

#Used this code to tune the forest
#----Forest Tuning-----
#Set a random seed to duplicate results
RNGkind(sample.kind = "default")
set.seed(123123)

#Split data into training and testing

train.idx = sample(x = 1:nrow(data), size = .8*nrow(data))
#Create training data

train.df = data2[train.idx, ]
#create testing data
test.df = data2[-train.idx, ]

#Build a base forest to help with comparison
March_Forest = randomForest(Winner ~.,
                        data = train.df,
                        ntrees = 10000)

March_Forest

#Trying all 88 different columns from the Advanced stats data set
mtry = c(1:88)
keeps = data.frame(m = rep(NA, length(mtry)),
                   OOB_error_rate = rep(NA, length(mtry)))
for(idx in 1:length(mtry)){
  print(paste0("Fitting m = ", mtry[idx]))
  tempmarch = randomForest(Winner ~.,
                            data = train.df,
                            ntree = 10000,
                            mtry = mtry[idx])
  keeps[idx, "m"] = mtry[idx]
  keeps[idx, "OOB_error_rate"] = mean(predict(tempmarch) != train.df$Winner)
}

#Print all the different OOB error rates, pick which is lowest/with fewest variables
ggplot(data = keeps) + 
  geom_line(aes(x = m, y = OOB_error_rate)) +
  labs(x = "m (Number of Features Used in Random Forest)", y = "OOB Error Rate") +
  ggtitle("Plot of OOB Error Rate vs. Number of Features Used")

#mtry of 75 was the lowest for the new variables
#mtry of about 51 was the lowest
min(keeps$OOB_error_rate)


#------Tuned Forest------

#Using multiple seeds to build multiple different random forests

RNGkind(sample.kind = "default")
set.seed(123123)
#set.seed(8675309)
#set.seed(9274619)
#set.seed(909090)
#set.seed(5389123)

#In this case, since the predictions are made on the current year of march madness
#matchups, all the current data will be used as training data 
train.df = data2

#Add in *importance = TRUE* in the () if you want the importance plot
Best_March_Forest = randomForest(Winner ~.,
                             data = train.df,
                             ntree = 10000,
                             mtry = 75, 
                             importance = TRUE)


#Read in a clean the current years Team data
team_stats <- read.csv("2024_Team_Data_adv.csv")
team_stats <- subset(team_stats, select = -c(Min_Played))
team_stats$School <- gsub('NCAA','', team_stats$School)
team_stats$School <- gsub(' ','', team_stats$School)

#-----Variable Importance-----
#Building the Variable importance plot
varImpPlot(Best_March_Forest, type = 1)
vi = as.data.frame(varImpPlot(Best_March_Forest, type = 1))
vi$Variable <- rownames(vi)
ggplot(data = vi) + 
  geom_bar(fill = "#99d8c9", aes(x = reorder(Variable,MeanDecreaseAccuracy), weight = MeanDecreaseAccuracy), 
           position ="identity") +
  coord_flip() + 
  labs( x = "Variable Name",y = "Importance") + 
  ggtitle("Variable Importance")

#----Predictions-----

#Read in whatever round of matchups you want to predict
matchups_playins <- read.csv("2024_real_matchups.csv") 
matchups_playins$Team1 <- gsub(' ','',matchups_playins$Team1)
matchups_playins$Team2 <- gsub(' ','', matchups_playins$Team2)

#Merge the team stats and matchups together for Team 1
colnames(team_stats)[2] = "Year"
colnames(team_stats)[1] = "Team1"
master <- matchups_playins %>% 
  merge(team_stats, by = c('Year'='Year','Team1'='Team1'), all = TRUE)
master_cleaning <- subset(master, !is.na(ROUND))

#Rename all the columns to Team1 since all the column names will be the same
colnames(master_cleaning)[5] = "Team1_Games"
colnames(master_cleaning)[6] = "Team1_Wins"
colnames(master_cleaning)[7] = "Team1_Loses"
colnames(master_cleaning)[8] = "Team1_W_L_Perc"
colnames(master_cleaning)[9] = "Team1_SRS"
colnames(master_cleaning)[10] = "Team1_SOS"
colnames(master_cleaning)[11] = "Team1_Conf_W"
colnames(master_cleaning)[12] = "Team1_Conf_L"
colnames(master_cleaning)[13] = "Team1_Home_W"
colnames(master_cleaning)[14] = "Team1_Home_L"
colnames(master_cleaning)[15] = "Team1_Away_W"
colnames(master_cleaning)[16] = "Team1_Away_L"
colnames(master_cleaning)[17] = "Team1_Team_Points"
colnames(master_cleaning)[18] = "Team1_Opp_Points"
colnames(master_cleaning)[19] = "Team1_FG"
colnames(master_cleaning)[20] = "Team1_FGA"
colnames(master_cleaning)[21] = "Team1_FG_Perc"
colnames(master_cleaning)[22] = "Team1_3P"
colnames(master_cleaning)[23] = "Team1_3PA"
colnames(master_cleaning)[24] = "Team1_3P_Perc"
colnames(master_cleaning)[25] = "Team1_FT"
colnames(master_cleaning)[26] = "Team1_FTA"
colnames(master_cleaning)[27] = "Team1_FT_Perc"
colnames(master_cleaning)[28] = "Team1_ORB"
colnames(master_cleaning)[29] = "Team1_TRB"
colnames(master_cleaning)[30] = "Team1_AST"
colnames(master_cleaning)[31] = "Team1_STL"
colnames(master_cleaning)[32] = "Team1_BLK"
colnames(master_cleaning)[33] = "Team1_TO"
colnames(master_cleaning)[34] = "Team1_PF"
colnames(master_cleaning)[35] = "Team1_Pace"
colnames(master_cleaning)[36] = "Team1_ORtg"
colnames(master_cleaning)[37] = "Team1_FTr"
colnames(master_cleaning)[38] = "Team1_3PAr"
colnames(master_cleaning)[39] = "Team1_TS_Perc"
colnames(master_cleaning)[40] = "Team1_TRB_Perc"
colnames(master_cleaning)[41] = "Team1_AST_Perc"
colnames(master_cleaning)[42] = "Team1_STL_Perc"
colnames(master_cleaning)[43] = "Team1_BLK_Perc"
colnames(master_cleaning)[44] = "Team1_eFG_Perc"
colnames(master_cleaning)[45] = "Team1_TOV_Perc"
colnames(master_cleaning)[46] = "Team1_ORB_Perc"
colnames(master_cleaning)[47] = "Team1_FT.FGA"

#Merge stats for Team2
colnames(team_stats)[1] = "Team2"
master_cleaning_2 <- master_cleaning %>% 
  merge(team_stats, by = c('Year'='Year','Team2'='Team2'), all = TRUE)


#put together data for matchups and team2
master_cleaning_2 <- subset(master_cleaning_2, !is.na(ROUND))

#Rename Columns for Team2
colnames(master_cleaning_2)[48] = "Team2_Games"
colnames(master_cleaning_2)[49] = "Team2_Wins"
colnames(master_cleaning_2)[50] = "Team2_Loses"
colnames(master_cleaning_2)[51] = "Team2_W_L_Perc"
colnames(master_cleaning_2)[52] = "Team2_SRS"
colnames(master_cleaning_2)[53] = "Team2_SOS"
colnames(master_cleaning_2)[54] = "Team2_Conf_W"
colnames(master_cleaning_2)[55] = "Team2_Conf_L"
colnames(master_cleaning_2)[56] = "Team2_Home_W"
colnames(master_cleaning_2)[57] = "Team2_Home_L"
colnames(master_cleaning_2)[58] = "Team2_Away_W"
colnames(master_cleaning_2)[59] = "Team2_Away_L"
colnames(master_cleaning_2)[60] = "Team2_Team_Points"
colnames(master_cleaning_2)[61] = "Team2_Opp_Points"
colnames(master_cleaning_2)[62] = "Team2_FG"
colnames(master_cleaning_2)[63] = "Team2_FGA"
colnames(master_cleaning_2)[64] = "Team2_FG_Perc"
colnames(master_cleaning_2)[65] = "Team2_3P"
colnames(master_cleaning_2)[66] = "Team2_3PA"
colnames(master_cleaning_2)[67] = "Team2_3P_Perc"
colnames(master_cleaning_2)[68] = "Team2_FT"
colnames(master_cleaning_2)[69] = "Team2_FTA"
colnames(master_cleaning_2)[70] = "Team2_FT_Perc"
colnames(master_cleaning_2)[71] = "Team2_ORB"
colnames(master_cleaning_2)[72] = "Team2_TRB"
colnames(master_cleaning_2)[73] = "Team2_AST"
colnames(master_cleaning_2)[74] = "Team2_STL"
colnames(master_cleaning_2)[75] = "Team2_BLK"
colnames(master_cleaning_2)[76] = "Team2_TO"
colnames(master_cleaning_2)[77] = "Team2_PF"
colnames(master_cleaning_2)[78] = "Team2_Pace"
colnames(master_cleaning_2)[79] = "Team2_ORtg"
colnames(master_cleaning_2)[80] = "Team2_FTr"
colnames(master_cleaning_2)[81] = "Team2_3PAr"
colnames(master_cleaning_2)[82] = "Team2_TS_Perc"
colnames(master_cleaning_2)[83] = "Team2_TRB_Perc"
colnames(master_cleaning_2)[84] = "Team2_AST_Perc"
colnames(master_cleaning_2)[85] = "Team2_STL_Perc"
colnames(master_cleaning_2)[86] = "Team2_BLK_Perc"
colnames(master_cleaning_2)[87] = "Team2_eFG_Perc"
colnames(master_cleaning_2)[88] = "Team2_TOV_Perc"
colnames(master_cleaning_2)[89] = "Team2_ORB_Perc"
colnames(master_cleaning_2)[90] = "Team2_FT.FGA"
View(master_cleaning_2)

#Make the predictions, rows will align and check which team wins 
pred = predict(Best_March_Forest, newdata = master_cleaning_2)
pred




