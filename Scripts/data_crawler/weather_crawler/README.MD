Source Code:
==================
* + .\old\*: Folder with old code for scrapping data from WUnderground and NCDC
* + .\auth.py: Code with tokens
* + .\scrapeWeatherFromDarksky.py: Code that gets weather data from DarkSky API

Challenges:
==================
* Some matches does not provide its venue information
* Some venues I could not get coordinates information

Data Sources Attempted:
==================

First Attempt: From Wunderground
----------------------------------
* Link: https://www.wunderground.com/cgi-bin/findweather/getForecast?airportorwmo=query&historytype=DailyHistory&backurl=%2Fhistory%2Findex.html
* Status: I was able to obtain the weather data by crawling through their HTML search result Web page
* Problem: It only provides historical weather information for Airports!

Second Attempt: From National Centers for Environmental Information
--------------------------------------
* Link: http://www.ncdc.noaa.gov/cdo-web/webservices/:
* Status: I was able to get some data, except humidity.
* Challenges: I cannot search by city name, I have to use an ID. So, I need to know the city ID in their database to retrieve the weather data. It limits 1K requests a day

Third Attempt: From DarkSky
--------------------------------------
* Link: https://darksky.net/dev/docs
* Status: I was able to get the data we need quickly *and I am stick with it for now*
* Challenges: I need to know the city latitude/longitude. It limits 1K requests a day


Next Sites to Tested
---------------------------------------
* https://developer.worldweatheronline.com/api/historical-weather-api.aspx (From 2008 only)
* https://darksky.net/dev/docs It seems it provides historical data
* https://www.wunderground.com/weather/api/d/pricing.html?MR=1: I am not sure if it provides historical data for free (but through their Web site it is feasible to get historical data for cities with airport)
* http://www.programmableweb.com/news/top-10-weather-apis/analysis/2014/11/13 : To get more ideas from