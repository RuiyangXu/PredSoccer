from datetime import datetime
import csv

def prepare(year):
    match_team = {}
    match_file = open("Match_new.csv")
    for line in match_file:
        data = line.split(",")
        match_id = int(data[0])
        home = int(data[1])
        away = int(data[2])
        score_home = 0
        score_away = 0
        if data[7] != "":
            score_home = int(data[7])
        if data[8] != "":
            score_away = int(data[8])
        time = datetime.strptime(data[3], "%m/%d/%Y")
        if time.year <= year:
            match_team[match_id] = []
            match_team[match_id].append(home)
            match_team[match_id].append(away)
            # match_team[match_id].append(score_home)
            # match_team[match_id].append(score_away)
            if score_home > score_away:
                match_team[match_id].append(1)
                match_team[match_id].append(0)
                match_team[match_id].append(0)
            elif score_home == score_away:
                match_team[match_id].append(0)
                match_team[match_id].append(1)
                match_team[match_id].append(0)
            else:
                match_team[match_id].append(0)
                match_team[match_id].append(0)
                match_team[match_id].append(1)

    team_player_file = open("MatchPlayerRelation_new.csv")
    team_player = {}
    for line in team_player_file:
        data = line.split(",")
        match_id = int(data[1])
        team_id = int(data[4])
        player_id = int(data[0])
        if match_id in match_team.keys():
            if team_id not in team_player:
                team_player[team_id] = []
            if player_id not in team_player[team_id]:
                team_player[team_id].append(player_id)

    # player_id,year,position,rating,pace,shoot,pass,dribble,defend,physical
    player_rating_file = open("PlayerRating_new.csv")
    player_rating = {}
    for line in player_rating_file:
        line = line.replace(" ", "")
        data = line.split(",")
        id = int(data[0])
        time = int(data[1])
        rating = int(data[3])
        if time == year:
            player_rating[id] = rating


    team_rating = {}
    for team in team_player:
        team_rating[team] = []

    for team in team_rating:
        for player in team_player[team]:
            if player in player_rating:
                team_rating[team].append(player_rating[player])


    team_avg = {}
    #compute average
    for team in team_rating:
        sum = 0
        for rate in team_rating[team]:
            sum += rate
        team_avg[team] = sum

    for team in team_avg:
        if len(team_rating[team]) != 0:
            team_avg[team] /= len(team_rating[team])
            team_avg[team] = int(team_avg[team])

    file = open('team_avg_' + str(year) + '.csv', 'w+', newline='')

    file.write("home_rating" + ',' + 'away_rating' + ',' + 'win' + ',' + 'draw' + '\n')

    for match in match_team:
        home = match_team[match][0]
        away = match_team[match][1]
        score_home = match_team[match][2]
        score_away = match_team[match][3]
        if home in team_avg and away in team_avg:
            if team_avg[away] != 0 and team_avg[home] != 0:
                file.write(str(team_avg[home]) + ',' + str(team_avg[away]) + ',' + str(score_home) + ',' + str(score_away)  + '\n')


    file.close()
    player_rating_file.close()
    match_file.close()
    team_player_file.close()




if __name__ == '__main__':
    prepare(2015)