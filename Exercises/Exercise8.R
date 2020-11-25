## 1.	Use the library rtimes and obtain a web token from this url http://developer.nytimes.com and obtain articles written on climate change in the last 3 years

# *Assuming that the last three years means 3 years from today (11/05/2017)*
  
  
  # *Note: There are issues regarding gathering all of the articles in the last three years 
  # that are written on climate change are due to the limits NYT puts on users accessing their APIs, 
  # so a smaller date range had to be chose in order to allow for any searches.*


library("rtimes")
article_key <- "your_key"
article_search_climate <- 
  as_search(q="climate+change",
            begin_date="20201001",
            end_date="20201105",key=article_key,
            all_results = T, sleep = 2)


article_search_climate[["data"]][["headline.main"]]



## 2.	Use your twitter credentials and obtain tweets talking about earth hour

# I am operating under the assumption that any tweets containing the hashtag '#earthhour' 
# will capture tweets that discuss earth hour.

library(twitteR) 
consumer_key <- "your_key"
consumer_secret <-"your_key"
access_token <- "your_token"
access_secret <- "your_token" 
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tw = twitteR::searchTwitter('#earthhour',  n = 1e4,  retryOnRateLimit = 1e3)
d = twListToDF(tw)
d




