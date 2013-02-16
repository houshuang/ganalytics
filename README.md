ganalytics
==========

## Purpose
I am in the process of learning R, and I wanted a challenge, so I am going to experiment with combining
Google Analytics data, and content data from my WordPress blog, and doing some exploratory data analysis/
visualization. 

I first need to get a hold of the data, and then begin playing with it. I will probably use `ddply` quite a bit,
for some of the more advanced stuff I'll need to study up on timeseries analysis.

## Log: Feb 14

* So far, I have managed to download all the Google Analytics statistics (I think, have not validated that I got 
all the data). It was surprisingly difficult, dealing with OAuth2.

## Log: Feb 15

* Managed to convert the dates to UNIXct (moved this to get_ga_data.R), and also 
calculate a column with day numbers (distance from today). 
* Exported WordPress database into csv, using Export-to-text plugin, resaved it in Excel, and imported it. Added .Rda file as well as the .csv.
* Wrote Ruby script to extract some indicators from post text (length, number of images, number of links, etc) - R gave me trouble with UTF8
* Combined summarized GA data and WP data, and did my first graphs. Nothing interesting stands out yet. Need to create a better "popularity" function - right now just using total page views. 