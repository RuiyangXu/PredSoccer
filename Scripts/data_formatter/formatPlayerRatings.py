from datetime import datetime
from utils import save_csv,save_sql
import csv

#YEARS = range(10,18)
YEARS = range(10,17)
PLAYERS = "..\\..\\datasets\\formatted_data\\Player_new.csv"
PLAYERS_RATINGS = "..\\..\\datasets\\Scraped data\\player-ratings-{0}.csv"


CSV_OUTPUT_PLAYERS_RATINGS = "..\\..\\datasets\\formatted_data\\PlayerRating_new.csv"


def load_players():
	players = dict()
	with open(PLAYERS, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for player_id,name in reader: 
			players[name.strip()] = player_id
	return players



def format_ratings(players):
	results = []
	sql = []
	visited = set()
	for data_year in YEARS:
		csv_file_path = PLAYERS_RATINGS.format(data_year)
		print("Parsing year: ", csv_file_path)
		with open(csv_file_path, 'r', encoding='utf-8') as csvfile:
			reader = csv.reader(csvfile, delimiter=',', quotechar='"')
			# ignores CSV header
			next(reader, None) 
			for row in reader: 
				if len(row) > 1:
					year = row[0] if len(row)>0 else ''
					name = row[1] if len(row)>1 else ''
					position = row[2] if len(row)>2 else ''
					rating = row[3] if len(row)>3 else '' 
					pace = row[4] if len(row)>4 else '' 
					shoot = row[5] if len(row)>5 else '' 
					player_pass = row[6] if len(row)>6 else ''
					dribble = row[7] if len(row)>7 else '' 
					defend = row[8] if len(row)>8 else '' 
					physical = row[9] if len(row)>9 else ''
					player_id = players.get(name.strip(),None)

					if player_id != None: # filter out not found players'names!
						pk = str(player_id)+"_"+str(year)
						if pk not in visited:
							visited.add(pk)
							results.append([player_id,year,position,rating,pace,shoot,player_pass,dribble,defend,physical])
	
	return results

players = load_players()
formatted_ratings = format_ratings(players)
# Save
header_row = ["player_id","year","position","rating","pace","shoot","pass","dribble","defend","physical"]
save_csv(CSV_OUTPUT_PLAYERS_RATINGS,header_row, formatted_ratings)

