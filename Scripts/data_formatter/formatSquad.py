from datetime import datetime
from utils import save_csv,save_sql
import csv


PLAYERS = "..\\..\\datasets\\formatted_data\\Player_new.csv"
TEAMS 	= "..\\..\\datasets\\formatted_data\\Team_new.csv"
SQUAD 	= "..\\..\\datasets\\Scraped data\\players.txt"


CSV_OUTPUT_SQUAD = "..\\..\\datasets\\formatted_data\\Squad_new.csv"


def load_teams():
	teams = dict()
	with open(TEAMS, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for team_id,country in reader: 
			teams[country.strip().lower()] = team_id
	return teams

def load_players():
	players = dict()
	with open(PLAYERS, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for player_id,name in reader: 
			players[name.strip().lower()] = player_id
	return players



def format_squad(players, teams):
	results = []
	visited = set()
	with open(SQUAD, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=' ', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for player,position,appearance,goals,year,team in reader: 
			if year == '2017':
				player_id = players.get(player.strip().lower(),None)
				team_id = teams.get(team.replace("-"," ").strip().lower(),None)
				pk =  str(player_id)+"_"+str(team_id)
				if player_id != None and team_id != None : # filter out not found players'names!
					if pk not in visited:
						visited.add(pk)
						results.append([player_id,team_id,goals])
				else:
					if not player_id:
						print("NOT FOUND " + player)
					if not team_id:
						print("NOT FOUND " + team)
	
	return results

players = load_players()
teams  = load_teams()
formatted_squads = format_squad(players,teams)
# Save
header_row = ["player_id","team_id","goals",]
save_csv(CSV_OUTPUT_SQUAD,header_row, formatted_squads)

