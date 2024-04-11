# MarchMadnessModel

### Introduction

Every March, millions of people fill out a bracket to try and predict the Men's Division 1 College Basketball Championship, otherwise known as March Madness because of it's tendecy to have crazy upsets and highlight plays. Over the past 2 years, my goal has been to try to create a machine learning model that would fill out a perfect braket for me. This repository serves as a place to store my current model and data so that myself (and others) can continue to improve the model for better predictions.

### Data
All of the team data that I used comes from sports-reference.com. The txt files of the data can be found in the RawData folder. Sadly, since I am making this repo after the 2nd iteration of the model, I could not find where I got the original matchups.csv data.

The matchups.csv data in the Matchups folder is all of the games in March Madness from 1985-2023. This data set includes both teams, the year, the seeds of both teams, and the score of both teams. The other csv's in the Matchups folder are the matchups of teams that are to be predicted. For example, the 2024_adv_matchups_playins includes the teams playing in the play in games for March Madness in 2024 that I wanted to predict. It contains both team names, the year, and the round (0 = playins, 1 = 1st round, 2 = 2nd round, etc.).

The 2024_Team_Data_adv.csv is the team specific data just for the 2024 year. For the model, this is kept seperate as this is the data I wanted to predict on.
The master_matchups.csv contains data from 2010-2023. It has the the two teams in the matchup, who won (team1 or team2), and the yearly stats for both team1 and team2. This is the dataset used to train the model.

The stats used for this model are:  
Games - Total Games Played  
Wins - Total Wins  
Losses - Total Losses  
W_L_Perc - Win-Loss Percentage (Total Wins/Total Losses)  
SRS - Simple Rating System, takes into account average point differential and strength of schedule. It is total points above/below average with 0 being average.  
SOS - Strength of Schedule, It is total points above/below average with 0 being average  
Conf_W - Wins within their Conference  
Conf_L - Losses with their Conference  
Home_W - Wins at Home  
Home_L - Losses at Home  
Away_W - Wins on the road  
Away_L - Losses on the road  
Team_Points - Total points they scored  
Opp_Points - Total points their opponents scored  
FG - Field Goals made (total made shots)  
FGA - Field Goals taken (total shots)  
FG_Perc - FG/FGA (made/shot)  
3P - 3-pointers made  
3PA - 3-pointers shot  
3P_Perc - 3P/3PA (3s made/3s shot)  
FT - Free throws made  
FTA - Free throws shot  
FT_Perc - FT/FTA (made FT/shot FT)  
ORB - Offensive Rebounds  
TRB - Total Rebounds  
AST - Assits  
STL - Steals  
BLK - Blocks  
TO - Turnovers  
PF - Personal Fouls  
Pace - Estimate of Possesions per 40 minutes  
ORtg - Offensive Rating: estimate of points produce per 100 possesions  
FTr - Free Throw Attempt Rate, # of FT attempted per FG attempted  
3PAr - 3-point attempt rate, % of FG attempts from 3-point range  
TS_Perc -True Shooting %, shooting efficiency from 2-point, 3-point, and FT  
TRB_Perc - Total Rebound %, estimate of rebounds grabbed  
AST_Perc - Assist %, estimate of field goals a assisted on   
STL_Perc - Steal %, estimate of opponent possesions that end in a steal  
BLK_Perc - Block %, estimate of opponent FGA blocked  
eFG_Perc - Effective Field Goal %, FG% that adjusts for the fact that a 3-pointer is worth more than a 2-pointer  
TOV_Perc - Turnover %, estimate of turnovers in 100 possesions  
ORB_Perc - Offensive Rebound %, estimate of percentage of available offensive rebounds that were grabbed  
FT.FGA - FT/FGA, Free Throws per Field Goal Attempt  

### Model
The model I decided to use was a Random Forest. This was for a few reasons. First, a random forest is a pretty simple machine learning model. This means it is easy to understand how the model works, how to tune the model, and it does not take too much computing power to train the model. The Second reason is because it gives more options for explaining why the model made a prediction. Specifically it gives the option for a variable importance chart. That way it is easy to see what is and isn't contributing to the model's predictions. While a more complex model (like a nueral network) would likely make more accurate predictions, for the first iterations I wanted to stick with simplicity and understand what goes into these predictions. 

As for the model itself, I used a 1000 tree forest. After tuning, the best OOB_error_rate was produced with an mTry of 75. So both of those will be the parameters for this particular model. It is also to note the for predictions, I used 5 different seeds and predicted using those 5 different random forests. I wanted to see if the model prediction was a fluke or not. While this does not fully prevent that, it did matter in a few cases. Another note is that who is Team1 and Team2 is manually randomized in the prediction dataset as to not bias one particular team.

After creating the variable importance plot, the most important stats in order in order from best to worst were:  
1) Team1_Games  
2) Team2_Games  
3) Team2_SRS  
4) Team1_SRS  
5) Team2_Wins  
6) Team1_TRB
7) Team2_SOS
8) Team2_STL
9) Team2_FGA
10) Team1_FG
11) Team1_FGA
12) Team2_FG

This turned out interesting and a little concerning. First is that both Games were at the top of importance. This is likely because sports-reference also tracks games that were played in March Madness, thus teams that make it further into March Madness will have more games played. While this is concerned, it also didn't seem to make that large of an impact on the effectiveness on the model. My guess is because early season tournaments and the NIT exists where teams will play more games than expected and still not neccessarily make it further in March Madness. However it is a note for concern. The other concern is that places 5 to 8 are all different stats. I expected the stats to be near each other (like Games, SRS, FG, and FGA are) but those 4 places near the top are not paired up. This causes concern that a bias may be placed on if a team is Team1 or Team2.

The least important stats in order from worst to best were:  
1) Team1_3PAr  
2) Team1_TRB_Perc  
3) Team1_BLK_Perc  
4) Team2_3PAr  
5) Team1_STL_Perc
6) Team2_Pace
7) Team1_TOV_Perc
8) Team1_3P_Perc
9) Team2_BLK_Perc
10) Team1_Conf_L
11) Team1_AST_Perc
12) Team1_FG_Perc
13) Team2_TS_Perc
14) Year

These bottom stats continue to raise concern that their is a bias if a team is Team1 or Team2. 9 of 14 stats at the bottom are related to Team 1 while only 4 are related to Team 2. This did not limit the success of the model this year however is a red flag for years to come. 

### Predictions
This year, the model did extraordinarily well. I used ESPN to help track how the bracket is doing. Points are allocated for a correct game picked with more points for prections deeper into the tournament. Each round there is a total of 320 points available split evenly between each game. Thus in round 1 a correct prediction is worth 10 points, round 2 is 20 points, 3 is 40 points, and so on. 

The model scored a total of 1520 points and was in the 99.9th percentile. It ended up rank 17,168 of 23 million brackets made on ESPN this year a pdf of the bracket is below:  
[ESPN Men's Tournament Challenge - Brackets.pdf](https://github.com/blokhuisryan19/MarchMadnessModel/files/14940820/ESPN.Men.s.Tournament.Challenge.-.Brackets.pdf)  
What is not shown are the play in games which I also attempted to predict as well. Listed below is each game, the predicted Winner, and if it was correct:  
Howard vs Wagner: Howard - WRONG  
Virginia vs Colorado: Colorado - CORRECT  
Montana State vs Grambling: Montana State: WRONG  
Boise State vs Colorado State: Colorado State: CORRECT  

The impressive predictions in this bracket, in my opinion, are the Championship Game, Winner, and the incredible run NC State had to the Final Four as an 11 seed. In total, of the 67 games played for March Madness, the model was able to correcty pick 48 of them. This seems less impressive than it is as to predict the next games, it had to get the previous games correct otherwise it would/could have predicted the next games wrong.

However that is not the end of the story. I also created a second model that was the same as the first iteration. This one only had the basic stats of the teams. This means it excluded Pace, ORtg, FTr, 3PAr, TS_Perc, TRB_Perc, AST_Perc, STL_Perc, BLK_Perc, eFG_Perc, TOV_Perc, ORB_Perc, and FT.FGA. It did better than the model with advanced stats. That model scored a Total of 1540 points, was also in the 99.9th percentile, and ranked 9,998. However it only got 46 of 67 games correct. The bracket is below:  
[ESPN Men's Tournament Challenge - Brackets - Basic Stats.pdf](https://github.com/blokhuisryan19/MarchMadnessModel/files/14940943/ESPN.Men.s.Tournament.Challenge.-.Brackets.-.Basic.Stats.pdf)  


### Work To Come
Moving forward I think there is a lot of work that could be done. First and foremost, a lot of the work was done by hand. I tried to supply a lot of the final product but to get to the final product I did a lot of manual work. Perferably I would like to automate this all in Python using webscraping and other modeling tools. Secondly, it is pretty apparent that going with the Team1 stats and Team2 stats approach could lead to bias. In the future I want to maybe combine these stats somehow. This will likely will be in the form of a difference. That way if a stat is too positive or negative the model should know to pick Team1 or Team2 but there would not be repeated stats. Thirdly, I would want to explore why/how the basic statistics model did just as good as the one with the advanced statistics. I know there are python packages that let you explore why a model made a prediction and I want to explore more with those. Finally, I think the random forest may be pushed to it's limits. I would like to explore  transitioning to a nueral network. The predictions may be more like a "Black Box" but for effectiveness it may be the best way forward. 




