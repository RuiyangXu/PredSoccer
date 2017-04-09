from urllib.request import Request
from urllib.request import urlopen
import json
import csv
import time 
from datetime import datetime


from geopy.geocoders import Nominatim


def save_csv(csv_file,header_row, results):
	with open(csv_file, "w", newline='', encoding="utf8") as csvfile:
		f = csv.writer(csvfile, delimiter=',',quotechar='"')
		f.writerow(header_row)
		for row in results:
			f.writerow(row)



def get_location_coordinates(location):
	print(location)
	coordinates = ("","","")
	try:
		geolocator = Nominatim()
		geo_obj = geolocator.geocode(location) 
		
		if geo_obj:
			coordinates = (str(geo_obj), str(geo_obj.latitude),str(geo_obj.longitude))

		print("\t(" + coordinates[1] +  "," + coordinates[2] + ")")
		return coordinates
	except:
		print("\tERROR")
		return coordinates
	


# Load the Data for the venues
def load_venues(csv_file):
	venues = set()
	with open(csv_file, 'r', encoding='utf-8') as csvfile:
		reader = csv.reader(csvfile, delimiter=',', quotechar='"')
		# ignores CSV header
		next(reader, None) 
		for teamA,teamB,matchDate,venue in reader: 
			venues.add(venue.strip())
	return venues




MATCHES_DATA = "..\\..\\datasets\\Scraped data\\venueForMatch.csv"
OUTPUT = "..\\..\\datasets\\Scraped data\\stadiums.csv"

stadium_id = 1
header_row = ['stadium_id','venue', 'stadium_location_name','latitude','longitude']
results = []
venues = load_venues(MATCHES_DATA)
for v in venues:
	coordinates = get_location_coordinates(v)
	results.append([stadium_id, v, coordinates[0], coordinates[1],coordinates[2]])


save_csv(OUTPUT,header_row, results)
