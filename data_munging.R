# get the contents of the csv file from Ruby, and merge it in

# right now this is just an archive, I did a lot in terminal etc... 

a <- cbind(wpst,wp_stats)
names(a) <- c("title", "tags", "url", "num_comments", "length", "words", "images", "links", "flesch")
wp_stats <- a
save(wp_stats, file = 'wp_stats.Rda')

tbl$pageTitle <- as.vector(unlist(tbl$pageTitle))
pagehits <- ddply(tbl, "pageTitle", summarize, visits = sum(visits))

tbl2 <-ddply(tbl, 'pageTitle', summarize, totvisits = sum(visits))

wp_stats$pageTitle <- wp_stats$title

posts <- merge(tbl2, wp_stats, by='pageTitle')

class(tbl$pageTitle)
