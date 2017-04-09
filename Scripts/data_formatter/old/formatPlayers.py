import csv
from datetime import datetime
from utils import save_sql,save_csv

PLAYERS_MATCHES = "..\\..\\datasets\\processedPlayerMatchData.csv"

CSV_OUTPUT = "..\\..\\datasets\\formatted_data\\Player.csv"
SQL_OUTPUT = "..\\..\\datasets\\formatted_data\\Player.sql"
SQL_STRING = "INSERT INTO public.\"Player\"(id,name) VALUES({0},'{1}');"



def load_players_matches():
	players = set()
	with open(PLAYERS_MATCHES, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for player,country,is_sub,goals,date,score,competition,matchtitle,venue in reader: 
			players.add(player.strip())
	return players


def format_players(players_matches):
	matches = dict()
	results = []
	sql = []
	gen_id = 1
	for name in players_matches:
		results.append([gen_id,name])
		sql.append(SQL_STRING.format(gen_id,name))
		gen_id+=1

	
	return results, sql



players = load_players_matches()
formatted_players, sql_commands = format_players(players)

# Save
header_row = ["id","name"]
save_csv(CSV_OUTPUT,header_row, formatted_players)
save_sql(SQL_OUTPUT, sql_commands)

