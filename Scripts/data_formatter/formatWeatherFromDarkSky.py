from auth import DARKSKY_TOKEN
from urllib.request import Request
from urllib.request import urlopen
import json
import csv
import time 
from datetime import datetime

from utils import save_csv,save_sql

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




import math




def format_weather(csv_file):
	results = list()
	with open(csv_file, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for match_date,location_id,latitude,longitude in reader: 
			match_timestamp = math.floor(datetime.strptime(match_date,'%Y-%m-%d').timestamp())
			url = API_URL.format(latitude,longitude,match_timestamp)
			print("Request URL would be" + str(url))

			request = Request(url = url , method = "GET")

			with urlopen(request) as response:
				raw_response = response.read().decode('utf-8')
				json_obj = json.loads(raw_response)

				weather_obj = json_obj.get('daily',None)
				if weather_obj:
					weather_obj = weather_obj.get('data',[])
					if len(weather_obj)>0:
						weather_obj=weather_obj[0]
						weather_data = [location_id, match_date] + [ str(weather_obj.get(data_name,"")) for data_name in DATA_NAMES]
						results.append(weather_data)

	return results

# Change here
SLICE_NUMBER = 1


MIN_INDEX = 1000*(SLICE_NUMBER-1)
MAX_INDEX = SLICE_NUMBER*1000


MATCHES_DATA = "..\\..\\datasets\\auxiliary\\match-weather-SLICE{0}.csv"
OUTPUT = "..\\..\\datasets\\formatted_data\\Weather_Slice{0}.csv"




print("Getting Weather For Slice#"+str(SLICE_NUMBER))
csv_file = MATCHES_DATA.format(SLICE_NUMBER)
results = format_weather(csv_file)

header_row = ["location_id","weather_date",] + DATA_NAMES
save_csv(OUTPUT.format(SLICE_NUMBER),header_row, results)