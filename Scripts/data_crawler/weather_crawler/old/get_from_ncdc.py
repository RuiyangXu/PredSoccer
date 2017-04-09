from auth import TOKEN
from urllib.request import Request
from urllib.request import urlopen
import json

API_URL = "http://www.ncdc.noaa.gov/cdo-web/api/v2/"

headers = {
	"token":TOKEN
}


# http://www.ncdc.noaa.gov/cdo-web/datasets
# Documentation about Daily SUmmaries Data ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt
# Daily Summaries: GHCND
# What is needed for query:
# 	- the CITY ID (Example : CITY:NL000012  Zwolle, NL)
# 	- the startdate= YYYY-mm-dd
# 	- the enddate= YYYY-mm-dd
#
# The data obtained:
# 	- temperature
#			TEMP
#           TMAX = Maximum temperature (tenths of degrees C)
#           TMIN = Minimum temperature (tenths of degrees C)
#	- pressure
# 			PRES 
# 	- humidity
#	- windspeed
#			WIND Wind
#			AWND = Average daily wind speed (tenths of meters per second)
#	- precipitation
#			PRCP = Precipitation (tenths of mm)


endpoint = "data?datasetid=GHCND&datatyped=TEMP&locationid=FIPS:BR&startdate=2010-05-01&enddate=2010-05-01"

request = Request(url = API_URL + endpoint , headers = headers, method = "GET")

with urlopen(request) as response:
	print(response.info())
	print(response.getcode())
	raw_response = response.read().decode('utf-8')
	json_obj = json.loads(raw_response)
	print(json_obj)

