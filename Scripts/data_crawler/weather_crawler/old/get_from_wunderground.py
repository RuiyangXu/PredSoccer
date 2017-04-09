from urllib.parse import urlencode
from lxml import html

import urllib.request as urllib2
import re 


DEFAULT_ENCODING = "utf8"
DEFAULT_TIMEOUT = 240

# URL = 'https://www.wunderground.com/history/airport/SBAR/2008/10/3/DailyHistory.html?req_city={0}&req_statename={2}'
URL = "https://www.wunderground.com/cgi-bin/findweather/getForecast?airportorwmo=query&historytype=DailyHistory&backurl=%2Fhistory%2Findex.html&"

# URL = 'https://www.underground.com/history/cgi-bin/findweather/getForecast'
URL_PARAMS = {
	"code":"",
	"month":"",
	"day":"",
	"year":"",
}



def request(url):
	"""Makes an HTTP GET request to the specified URL.
	
	Keyword arguments:
    url -- url for the request
	"""
	try:
		raw_response = urllib2.urlopen(url=url, timeout = DEFAULT_TIMEOUT)
		print((raw_response.headers))
		print(raw_response.status)
		charset = raw_response.info().get_param('charset', DEFAULT_ENCODING)
	except urllib2.HTTPError as err:
		print("ERROR {0} for {1}".format(err.code,url))
		raw_response = None
	
		
	return raw_response.read().decode(charset) if raw_response else ''




def get_weather(location, month,day,year):
	URL_PARAMS["code"] = location
	URL_PARAMS["month"] = month
	URL_PARAMS["day"] = day
	URL_PARAMS["year"] = year

	data = urlencode(URL_PARAMS)
	# data = data.encode('utf8')
	url = URL +  str(data)
	result = request(url)
	# tree = html.fromstring(result)
	# rows = tree.xpath('//*[@id="historyTable"]/tbody/tr')
	# for row in rows:
	# 	columns = row.findall("td")
	# 	if len(columns) >= 3:
	# 		data_name = columns[0].text_content()
	# 		data_value = columns[1].text_content().strip()
	# 		print(data_name + " = " + str(data_value))


get_weather("Rochester, NY","10","1","2016")


"""
result  = request(URL)

tree = html.fromstring(result)

rows = tree.xpath('//*[@id="historyTable"]/tbody/tr')
for row in rows:
	columns = row.findall("td")
	if len(columns) >= 3:
		data_name = columns[0].text_content()
		data_value = columns[1].text_content().strip()
		print(data_name + " = " + str(data_value))
	

"""