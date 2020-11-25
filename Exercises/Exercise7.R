## 1.	Scrape the QBS webpage https://geiselmed.dartmouth.edu/qbs/2019-cohort/
  

library(rvest)
library(stringr)
scraping_qbs <-  read_html("https://geiselmed.dartmouth.edu/qbs/2019-cohort/")
head(scraping_qbs)
h1_text <- scraping_qbs %>% html_nodes("h1") %>%html_text()
h2_text <- scraping_qbs %>% html_nodes("h2") %>%html_text()
length(h2_text)


p_nodes <- scraping_qbs %>%html_nodes("p")
p_nodes[1:6]


ul_text <- scraping_qbs %>% html_nodes("ul") %>%html_text()
length(ul_text)

ul_text[1]
substr(ul_text[2],start=5,stop=14)
li_text <- scraping_qbs %>% html_nodes("li") %>%html_text()
length(li_text)
li_text[1:8]

# all text irrespecive of headings, paragrpahs, lists, ordered list etc..
all_text <- scraping_qbs %>%
  html_nodes("div") %>% 
  html_text()
all_text[17]
cohort2019 <- str_split(all_text[17], "\n")

cohort2019_df <- data.frame(matrix(unlist(cohort2019[[1]][c(6:8, 10:12, 14:15, 17:19, 21)]), byrow = T), stringsAsFactors = F)




clean_text <- scraping_qbs %>% html_nodes("mw-body") %>%html_text()
clean_text

body_text <- scraping_qbs %>%
  html_nodes("#mw-content-text") %>% 
  html_text()

substr(body_text, start = 1, stop = 10)


ul_text <- scraping_qbs %>% html_nodes("ul") %>%html_text()
length(ul_text)

ul_text[1]
substr(ul_text[2],start=5,stop=14)
li_text <- scraping_qbs %>% html_nodes("li") %>%html_text()
length(li_text)
li_text[1:8]

# all text irrespecive of headings, paragrpahs, lists, ordered list etc..
all_text <- scraping_qbs %>%
  html_nodes("div") %>% 
  html_text()


# Important Cohort 2019 information
(cohort2019_df <- data.frame(matrix(unlist(cohort2019[[1]][c(6:8, 10:12, 14:15, 17:19, 21)]), byrow = T), stringsAsFactors = F))





## 2.	Use the library rnoaa and obtain a web token from this url 
## www.ncdc.noaa.gov/cdo-web/token and obtain min and max temperature of 
## WRIGHT PATTERSON AFB, OH US


# So, for the available range of dates (1946-10-01 to 1970-12-31), 
# the maximum temperature was 38.9 degrees Celcius and the minimum temperature was -26.7 
# degrees Celcius.

library(rjson)
library("rnoaa")
options(noaakey = "your_token")
ncdc_stations(stationid = "GHCND:USW00013840")

ncdc_datacats(stationid = "GHCND:USW00013840")
ncdc_datasets(datacategoryid = "WXTYPE", stationid = "GHCND:USW00013840")

# Given that the only available dates for this station are from 
# 1946-10-01 to 1970-12-31 and that we can only call in a range < 10 years
# There will be three calls for the maximum and minimum temps
max46 <- ncdc(datasetid = "GSOY", datatypeid = "EMXT", 
              stationid = "GHCND:USW00013840", startdate = "1946-10-01", 
              enddate = "1956-01-01", 
              token = "your_token", add_units = T)
max56 <- ncdc(datasetid = "GSOY", datatypeid = "EMXT", 
              stationid = "GHCND:USW00013840", startdate = "1956-01-02", 
              enddate = "1966-01-01", 
              token = "your_token",
              includemetadata = F, add_units = T)
max66 <- ncdc(datasetid = "GSOY", datatypeid = "EMXT", 
              stationid = "GHCND:USW00013840", startdate = "1966-01-02", 
              enddate = "1970-12-31", 
              token = "your_token", 
              includemetadata = F, add_units = T)

min46 <- ncdc(datasetid = "GSOY", datatypeid = "EMNT", 
              stationid = "GHCND:USW00013840", startdate = "1946-10-01", 
              enddate = "1956-01-01", 
              token = "your_token", 
              includemetadata = F, add_units = T)
min56 <- ncdc(datasetid = "GSOY", datatypeid = "EMNT", 
              stationid = "GHCND:USW00013840", startdate = "1956-01-02", 
              enddate = "1966-01-01", 
              token = "your_token", 
              includemetadata = F, add_units = T)
min66 <- ncdc(datasetid = "GSOY", datatypeid = "EMNT", 
              stationid = "GHCND:USW00013840", startdate = "1966-01-02", 
              enddate = "1970-12-31", 
              token = "your_token", 
              includemetadata = F, add_units = T)

(maxtemp <- max(c(max46[["data"]][["value"]], 
                  max56[["data"]][["value"]], max66[["data"]][["value"]])))

(maxtemp <- min(c(min46[["data"]][["value"]], 
                  min56[["data"]][["value"]], min66[["data"]][["value"]])))

