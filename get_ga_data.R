# Adapted from https://raw.github.com/skardhamar/ga-auth-data/master/GAAuthData.R

# Originally had a lot of functions for fetching tokens, refreshing etc. 
# Never got it to work. So I used https://developers.google.com/oauthplayground/
# as detailed here: http://www.tatvic.com/blog/ga-data-extraction-in-r/
# to generate a token, and simply used that.

# Make sure you turn on Google Analytics in the list of services here
# https://code.google.com/apis/console/

c.token <- ''

# Libraries required 
library(RCurl)
library(rjson)

# Global data variables
date.format <- '%d-%m-%Y' # european

processManData = function(url) {
  ga.data <- fromJSON(getURL(url))
  ga.data.df <- as.data.frame(do.call(rbind, ga.data$items)) # convert to data.frame
  ga.data.df <- subset(ga.data.df, select = -c(kind, selfLink, childLink)) # remove columns
  return(ga.data.df)
}

getData = function(ids, start.date=format(Sys.time(), "%Y-%m-%d"), end.date=format(Sys.time(), "%Y-%m-%d"), metrics='ga:visits', dimensions='ga:date', sort='', filters='', segment='', fields='', remove.prefix=T, fix.date=T, fix.format=T, start=1, max=1000) {
  url <- paste('https://www.googleapis.com/analytics/v3/data/ga',
               '?access_token=', c.token,
               '&ids=', ids, # req
               '&start-date=', start.date, # req, YYYY-MM-DD
               '&end-date=', end.date, # req, YYYY-MM-DD 
               '&metrics=', metrics, # req
               '&dimensions=', dimensions,
               '&start-index=', start,
               '&max-results=', max,
               sep='', collapse='')
  if (sort != '') { url <- paste(url, '&sort=', sort, sep='', collapse='') }
  if (filters != '') { url <- paste(url, '&filters=', filters, sep='', collapse='') }
  if (segment != '') { url <- paste(url, '&segment=', segment, sep='', collapse='') }
  if (fields != '') { url <- paste(url, '&fields=', fields, sep='', collapse='') }
  
  # if there is an error code, try this in the browser to see what the problem is
  print (url) 
  
  ga.data <- fromJSON(getURL(url))
  ga.headers <- as.data.frame(do.call(rbind, ga.data$columnHeaders)) # get column names
  ga.data.df <- as.data.frame(do.call(rbind, ga.data$rows)) # convert to data.frame
  ga.data.df <- data.frame(lapply(ga.data.df, as.character), stringsAsFactors=F) # convert to characters
  
  if (remove.prefix) { ga.headers$name <- sub('ga:', '', ga.headers$name) }
  names(ga.data.df) <- ga.headers$name # insert column names
  
  if (fix.date) { # will not work without remove.prefix=T
    if ('date' %in% names(ga.data.df)) {
      ga.data.df$'date' <- as.Date(format(as.Date(ga.data.df$'date', '%Y%m%d'), date.format), format=date.format)
    }
  }
  
  if (fix.format) {
    int <- c('hour', 'visits', 'visitors', 'newVisits', 
             'daysSinceLastVisit', 'visitCount', 'transactionRevenue',
             'bounces', 'timeOnSite', 'entranceBounceRate', 'visitBounceRate',
             'avgTimeOnSite', 'organicSearches', 'adSlotPosition', 'impressions',
             'adClicks', 'adCost', 'CPM', 'CPC', 'CTR', 'costPerTransaction',
             'costPerGoalConversion', 'costPerConversion', 'RPC', 'ROI',
             'margin', 'goal', 'latitude', 'longitude', 'socialActivityTimestamp',
             'socialActivities', 'pageDepth', 'entrances', 'pageviews', 
             'uniquePageviews', 'timeOnPage', 'exits', 'entranceRate', 
             'pageviewsPerVisit', 'avgTimeOnPage', 'exitRate', 'searchResultViews',
             'searchUniques', 'searchVisits', 'searchDepth', 'searchRefinements',
             'searchDuration', 'searchExits', 'avgSearchResultViews', 
             'percentVisitsWithSearch', 'avgSearchDepth', 'avgSearchDuration',
             'searchExitRate', 'searchGoal', 'goalValueAllPerSearch')
    
    # stupid stupid solution - fix, do vector
    for(i in 1:length(names(ga.data.df))) {
      if (names(ga.data.df)[i] %in% int) {
        ga.data.df[[i]] <- as.numeric(ga.data.df[[i]])
      }
    }
  }
  
  return(ga.data.df)
}

############################################################################

# This code tries to fetch a data frame of hits to every single post from 
# my blog, by date, time, and day of the week.
# Since I know it's less than 60,000 hits, and the API only allows max
# 10,000 rows at once, we have to iterate, and add to a data.frame.
# We finally store the result for future analysis (and so that people
# who do not have access to my Analytics account, can also try analysis.

print("*****************************")
print("Beginning download")

tbl <- data.frame()
for(i in 0:5){
  dt <- getData('ga:31450814', 
                 
                 start.date=format(Sys.time(), "2010-04-09"),
                 end.date=format(Sys.time(), "2014-01-01"), 
                 metrics='ga:visits', 
                 
                 # only blog posts, not category pages etc
                 filters='ga:pagePath=~^/blog/20', 
                 
                 dimensions='ga:pageTitle,ga:date,ga:hour,ga:DayOfWeek',
                 
                 # grab section by section
                 start=i*10000+1, 
                 max=10000)
  
  tbl <- rbind(tbl, dt) # add it to a collector dataframe
  cat("Getting", i*10000+1, "to", i*10000+10000)
}
save(tbl, file="./data.Rda")