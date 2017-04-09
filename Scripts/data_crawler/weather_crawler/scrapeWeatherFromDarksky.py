from auth import DARKSKY_TOKEN
from urllib.request import Request
from urllib.request import urlopen
import json
import csv
import time 
from datetime import datetime

API_URL = "https://api.darksky.net/forecast/" + DARKSKY_TOKEN + "/{0},{1},{2}?exclude=currently,hourly,flags"

DATA_NAMES = [
	"sunsetTime",
	"pressure",
	"precipIntensity",
	"humidity",
	"windSpeed",
	"temperatureMin",
	"cloudCover",
	"precipIntensityMax",
	"windBearing",
	"sunriseTime",
	"visibility",
	"apparentTemperatureMax",
	"temperatureMinTime",
	"moonPhase",
	"temperatureMaxTime",
	"dewPoint",
	"apparentTemperatureMin",
	"apparentTemperatureMinTime",
	"temperatureMax",
	"apparentTemperatureMaxTime",
	"precipProbability",
]




from geopy.geocoders import Nominatim


def save_csv(csv_file,header_row, results):
	with open(csv_file, "w", newline='', encoding="utf8") as csvfile:
		f = csv.writer(csvfile, delimiter=',',quotechar='"')
		f.writerow(header_row)
		for row in results:
			f.writerow(row)



def get_location_coordinates(location):
	geolocator = Nominatim()
	geo_obj = geolocator.geocode(location) 
	print(location)
	coordinates = (str(geo_obj.latitude),str(geo_obj.longitude))
	# print(geo_obj)
	print("\t(" + coordinates[0] + "," + coordinates[1] +  ")")
	return coordinates

import math
def get_weather(matches):
	
	results = []

	for match in matches:
		teamA, teamB, matchDate ,location = match['teamA'],match['teamB'], match['matchDate'], match['location']
		# match_timestamp = int(datetime.datetime(year,month, day).timestamp())
		print(matchDate)
		match_timestamp = math.floor(datetime.strptime(matchDate,'%d %B %Y').timestamp())
		latitude,longitude = get_location_coordinates(location)
		url = API_URL.format(latitude,longitude,match_timestamp)
		print("Request URL would be" + str(url))

		# request = Request(url = url , method = "GET")

		# with urlopen(request) as response:
		# 	raw_response = response.read().decode('utf-8')
		# 	json_obj = json.loads(raw_response)
		# 	weather_obj = json_obj['daily']['data'][0]
		# 	weather_data = [ str(weather_obj.get(data_name,"")) for data_name in DATA_NAMES]
		# 	results.append(weather_data)
	
	return results






#PLACEHOLDER, while I dont have the actual match data
 
def load_matches(csv_file):
	matches = list()
	with open(csv_file, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for teamA,teamB,matchDate,venue in reader: 
			match_data = {
				"teamA":teamA.strip(),
				"teamB":teamB.strip(),
				"location": venue.strip(),
				"matchDate": matchDate, #month.strip().replace("January")
			} 
			matches.append(match_data)
			




	# matches = [
	# 	{
	# 		'location': "Rochester, NY", 'month': 10, 'day':1,'year':2006
	# 	},
	# 	{
	# 		'location': "Rio de Janeiro, RJ. Brazil", 'month': 5, 'day':19,'year':2002
	# 	}
	# ]
	return matches

# Change here
SLICE_NUMBER = 1


MIN_INDEX = 1000*(SLICE_NUMBER-1)
MAX_INDEX = SLICE_NUMBER*1000


MATCHES_DATA = "..\\..\\datasets\\Scraped data\\venueForMatch.csv"
OUTPUT = "..\\..\\datasets\\Scraped data\\Weather_Slice{0}.csv"




print("Getting Weather For Slice#"+str(SLICE_NUMBER))
print("Loading Matches Data...")
matches = load_matches(MATCHES_DATA)
print("Loading Completed!")
print("Querying Weather Data from Darksky...")
results = get_weather(matches)
print("Saving Results...")
save_csv(OUTPUT.format(SLICE_NUMBER),DATA_NAMES, results)
print("DONE For Slice#"+str(SLICE_NUMBER))