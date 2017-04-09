import csv
from datetime import datetime
from utils import save_sql,save_csv
from geopy.geocoders import Nominatim


PLAYER_MATCH  = "..\\..\\datasets\\processedPlayerMatchData.csv"

CSV_OUTPUT_TEAMS 				= "..\\..\\datasets\\formatted_data\\Team_new.csv"
CSV_OUTPUT_LOCATIONS 			= "..\\..\\datasets\\formatted_data\\MatchLocation_new.csv"
CSV_OUTPUT_PLAYERS 				= "..\\..\\datasets\\formatted_data\\Player_new.csv"
CSV_OUTPUT_MATCHES 				= "..\\..\\datasets\\formatted_data\\Match_new.csv"
CSV_OUTPUT_MATCH_PLAYERS_REL 	= "..\\..\\datasets\\formatted_data\\MatchPlayerRelation_new.csv"


def get_location_coordinates(location):
	coordinates = (None,None)
	try:
		geolocator = Nominatim()
		geo_obj = geolocator.geocode(location) 
		
		if geo_obj:
			coordinates = (str(geo_obj.latitude),str(geo_obj.longitude))
		return coordinates
	except:
		return coordinates


def save_teams(teams):
	header_teams = ["id","country",]
	formatted_results = []
	# Flat the dictionary
	for t in teams:
		formatted_results.append([teams[t][h] for h in header_teams])

	save_csv(CSV_OUTPUT_TEAMS,header_teams, formatted_results)


def save_locations(match_locations):
	header_locations = ["id","name","latitude","longitude"]
	formatted_results = []
	# Flat the dictionary
	for location in match_locations:
		formatted_results.append([match_locations[location].get(h,None) for h in header_locations])

	save_csv(CSV_OUTPUT_LOCATIONS,header_locations, formatted_results)


def save_players(players):
	header_players = ["id","name",]
	formatted_results = []
	# Flat the dictionary
	for p in players:
		formatted_results.append([players[p][h] for h in header_players])

	save_csv(CSV_OUTPUT_PLAYERS,header_players, formatted_results)


def save_matches(matches):
	header_matches = ["id","home_team_id","away_team_id","match_date","location_id","competition","winning_team_id","home_team_score","away_team_score",]
	formatted_results = []
	# Flat the dictionary
	for m in matches:
		formatted_results.append([matches[m][h] for h in header_matches])

	save_csv(CSV_OUTPUT_MATCHES,header_matches, formatted_results)



def save_match_player_relations(matches):
	header_rel = ["player_id","match_id","is_substitute","num_goals","team_id",]
	formatted_results = []
	# Flat the dictionary
	for m in matches:
		formatted_results.append([matches[m][h] for h in header_rel])

	save_csv(CSV_OUTPUT_MATCH_PLAYERS_REL,header_rel, formatted_results)



def load_data():
	gen_id_teams = 1
	gen_id_players = 1
	gen_id_matches = 1
	gen_id_locations = 1	

	teams = dict()
	players = dict()
	matches = dict()
	match_locations = dict()
	match_player_rel = dict()

	with open(PLAYER_MATCH, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for player,player_country,is_sub,goals,match_date,score,competition,matchtitle,venue in reader: 
			# Loads data appropriately
			formatted_date = datetime.strptime(match_date, '%d %B %Y').strftime("%Y-%m-%d")
			team_a, team_b  = [t.strip() for t in matchtitle.split(",")[0].split(" v ")] 
			score_team_a, score_team_b  = score.split(" ")[0].split("-")[0] , score.split(" ")[0].split("-")[1] 
			num_goals = int(goals.replace("NA","0")) if goals else 0
			is_substitute = str(is_sub.strip() == "Y").upper()

			# Store unique venues
			if venue not in match_locations:
				latitude,longitude = get_location_coordinates(venue.strip())
				match_locations[venue] = {"id":gen_id_locations, "name":venue.strip(), "latitude":latitude,"longitude":longitude}
				gen_id_locations += 1 
			#######################


			# Store unique teams
			if team_a not in teams:
				teams[team_a] = {"id":gen_id_teams, "country":team_a}
				gen_id_teams += 1 
			if team_b not in teams:
				teams[team_b] = {"id":gen_id_teams, "country":team_b}
				gen_id_teams += 1 
			#######################


			# Store unique matches
			pk1 = team_a+ "_"+team_b+"_"+formatted_date
			pk2 = team_b+ "_"+team_a+"_"+formatted_date
			if pk1 not in matches and pk2 not in matches:
				matches[pk1] = {
					"id":gen_id_matches,
					"home_team_id":teams[team_a]["id"],
					"away_team_id":teams[team_b]["id"],
					"match_date":formatted_date,
					"location_id":match_locations[venue.strip()]["id"] if venue.strip() else None,
					"competition":competition,
					"winning_team_id": teams[team_a]["id"] if score_team_a > score_team_b else ( teams[team_b]["id"] if score_team_b > score_team_a else None),
					"home_team_score":score_team_a,
					"away_team_score":score_team_b
				}
				gen_id_matches += 1
			#######################


			# Store unique players
			if player not in players:
				players[player] = {
					"id":gen_id_players,
					"name": player.strip()
				}
				gen_id_players += 1
			#######################


			# Store unique MatchPlayerRelations
			player_id	= players[player]["id"]
			match_id	= matches.get(pk1,matches.get(pk2,None))["id"]
			rel_pk = str(player_id) + "_" + str(match_id)
			if rel_pk not in match_player_rel:
				match_player_rel[rel_pk] = {
					"player_id"		: player_id,
					"match_id"		: match_id,
					"is_substitute"	: is_substitute,
					"num_goals"		: num_goals,
					"team_id"		: teams[player_country]["id"]
				}



	return teams, players, match_locations, match_player_rel, matches



teams, players, match_locations, match_player_rel, matches = load_data()

print("Teams: " + str(len(teams)))
print("Players: " + str(len(players)))
print("Locations: " + str(len(match_locations)))
print("Match_Player_Rel: " + str(len(match_player_rel)))
print("Matches: " + str(len(matches)))


# Save
print("Saving table Team at " + CSV_OUTPUT_TEAMS)
save_teams(teams)
print("Saving table MatchLocation at " + CSV_OUTPUT_LOCATIONS)
save_locations(match_locations)
print("Saving table Player at " + CSV_OUTPUT_PLAYERS)
save_players(players)
print("Saving table Match at " + CSV_OUTPUT_MATCHES)
save_matches(matches)
print("Saving table MatchPlayerRelation at " + CSV_OUTPUT_MATCH_PLAYERS_REL)
save_match_player_relations(match_player_rel)

