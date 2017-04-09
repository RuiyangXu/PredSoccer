import csv
from datetime import datetime
from utils import save_sql,save_csv
TEAMS = "..\\..\\datasets\\formatted_data\\Team.csv"
MATCHES_LOCATION = "..\\..\\datasets\\formatted_data\\MatchLocation.csv"
MATCHES_VENUES  = "..\\..\\datasets\\processedvenueForMatchNonEmpty.csv"
MATCHES  = "..\\..\\datasets\\preprocessedMatchData.csv"
CSV_OUTPUT = "..\\..\\datasets\\formatted_data\\Match.csv"
SQL_OUTPUT = "..\\..\\datasets\\formatted_data\\Match.sql"
SQL_STRING = "INSERT INTO public.\"Match\"(id,home_team_id,away_team_id,location_id,match_type,competition,winning_team_id,home_team_score,away_team_score,match_date) VALUES({0},{1},{2},{3},{4},'{5}',{6},{7},{8},'{9}');"


def load_teams():
	teams = dict()
	with open(TEAMS, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for team_id,country in reader: 
			teams[country.strip()] = team_id
	return teams

def load_match_location():
	locations = dict()
	with open(MATCHES_LOCATION, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for location_id, name, latitude, longitude in reader: 
			locations[name.strip()] = location_id
	return locations	

def load_matches_venues():
	matches_venues = dict()
	with open(MATCHES_VENUES, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for team_a,team_b,m_date,venue in reader: 
			formatted_date = datetime.strptime(m_date, '%d %B %Y').strftime("%Y-%m-%d")
			v_id = team_a.strip()+ "_"+team_b.strip()+"_"+formatted_date.strip()
			matches_venues[v_id] = venue.strip()
	return matches_venues




def format_matches(teams, locations, venues):
	matches = dict()
	results = []
	sql = []
	gen_id = 1
	with open(MATCHES, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for match_date, match_teams,result,score,competition in reader: 
			team_a, team_b  = [t.strip() for t in match_teams.split(" v ")] 
			home_team_score, away_team_score  = [int(s.strip()) for s in score.split("-")] 
			
			home_team_id = teams[team_a]
			away_team_id = teams[team_b]
			winning_team_id = home_team_id if home_team_score > away_team_score else ( away_team_id if away_team_score>home_team_score else None)

			v_id = team_a.strip()+ "_"+team_b.strip()+"_"+match_date.strip()
			venue_id = venues.get(v_id,None)
			if not venue_id:
				v_id = team_b.strip()+ "_"+team_a.strip()+"_"+match_date.strip()
				venue_id = venues.get(v_id,None)
				

			location_id = locations.get(venue_id)
			match_type = None

			results.append([gen_id,home_team_id,away_team_id,location_id,match_type,competition,winning_team_id,home_team_score,away_team_score,match_date])
			sql.append(SQL_STRING.format(
					gen_id,
					home_team_id,
					away_team_id,
					location_id if location_id else 'NULL',
					match_type if match_type else 'NULL',
					competition,
					winning_team_id  if winning_team_id else 'NULL',
					home_team_score,
					away_team_score,
					match_date))
			gen_id+=1

	
	return results, sql





teams = load_teams()
locations = load_match_location()
matches_venues = load_matches_venues()

formatted_matches, sql_commands = format_matches(teams,locations,matches_venues)



# Save
header_row = ["id","home_team_id","away_team_id","location_id","match_type","competition","winning_team_id","home_team_score","away_team_score","match_date"]
save_csv(CSV_OUTPUT,header_row, formatted_matches)
save_sql(SQL_OUTPUT, sql_commands)

