import csv
from datetime import datetime
from utils import save_sql,save_csv
TEAMS = "..\\..\\datasets\\formatted_data\\Team.csv"
MATCHES = "..\\..\\datasets\\formatted_data\\Match.csv"
PLAYERS  = "..\\..\\datasets\\formatted_data\\Player.csv"
PLAYER_MATCH  = "..\\..\\datasets\\processedPlayerMatchData.csv"


CSV_OUTPUT = "..\\..\\datasets\\formatted_data\\MatchPlayerRelation.csv"
SQL_OUTPUT = "..\\..\\datasets\\formatted_data\\MatchPlayerRelation.sql"
SQL_STRING = "INSERT INTO public.\"MatchPlayerRelation\"(id,is_substitute,match_id,player_id,num_goals,team_id) VALUES({0},{1},{2},{3},{4},{5});"


def load_teams():
	teams = dict()
	with open(TEAMS, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for team_id,country in reader: 
			teams[country.strip()] = team_id
	return teams

def load_matches():
	matches = dict()
	with open(MATCHES, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for match_id,home_team_id,away_team_id,location_id,match_type,competition,winning_team_id,home_team_score,away_team_score,match_date in reader: 
			pk = str(home_team_id).strip()  + "_" + str(away_team_id).strip() + "_" + match_date.strip()
			# print(pk)
			matches[pk] = match_id
	return matches	


def load_players():
	players = dict()
	with open(PLAYERS, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for row in reader: 
			player_id,name = row[0],row[1]
			players[name.strip()] = player_id
	return players


def format_match_player_relation(teams, players, matches):
	results = []
	sql = []
	gen_id = 1
	with open(PLAYER_MATCH, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for row in reader: 
			player,country,is_sub,goals,match_date,score,matchtitle = row[0],row[1],row[2],row[3],row[4],row[5],row[7]
			formatted_date = datetime.strptime(match_date, '%d %B %Y').strftime("%Y-%m-%d")
			team_a, team_b  = [teams[t.strip()] for t in matchtitle.split(",")[0].split(" v ")] 

			player_id = players[player.strip()]
			team_id = teams[country]
			is_substitute = str(is_sub.strip() == "Y").upper()

			match_id = matches.get(team_a.strip()+ "_"+team_b.strip()+"_"+formatted_date.strip(),None)
			if not match_id:
				print(matchtitle)
				match_id = matches[team_b.strip()+ "_"+team_a.strip()+"_"+formatted_date.strip()]
			
			if not goals or goals == "NA": 
				num_goals = "NULL"
			else:
				num_goals = goals

			results.append([gen_id,is_substitute,match_id,player_id,num_goals,team_id])
			sql.append(SQL_STRING.format(gen_id,is_substitute,match_id,player_id,num_goals,team_id))
			gen_id+=1

	return results, sql





teams = load_teams()
players = load_players()
matches = load_matches()
# print(matches)
formatted_matches_payers_rel, sql_commands = format_match_player_relation(teams, players, matches)



# # Save
# header_row = ["id","is_substitute","match_id","player_id","num_goals","team_id",]
# save_csv(CSV_OUTPUT,header_row, formatted_matches_payers_rel)
# save_sql(SQL_OUTPUT, sql_commands)

