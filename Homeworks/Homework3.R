## 1.	Compute the rate for table2, and table4a+table4b and perform the four operation

library(dplyr)
library(magrittr)
library(tidyr)


## a.	Extract the number of TB cases per country per year

## b.	Extract the matching population per country per year

clean4a <- table4a%>%gather('1999','2000',key="year",value="cases")
clean4b <- table4b%>%gather('1999','2000',key="year",value="population")
table2_clean <- spread(table2,key=type,value=count)
table4_join <- clean4a %>%inner_join(clean4b,by=c("country","year"))
table4_join <- arrange(table4_join, country)
table4_join$year <- as.integer(table4_join$year)
table2_clean
table4_join



## c.	Divide cases by population, and multiply by 10,000

## d.	Store back in appropriate place.

table2_clean%<>%mutate(rate=(cases/population) *10000)
table4_join%<>%mutate(rate=(cases/population) *10000)
table2_clean
table4_join


## 2.	Why does this code fail?
  

table4a%>%gather(1999,2000,key="year",value="cases")


# This code fails because the column names aren't being recognized.
# This is because they are being listed as their numeric, year values within this attempt to use the gather function when they should instead be referenced as strings, like this:


    table4a%>%gather('1999','2000',key="year",value="cases")


## 3.	Use the flights dataset in the nycflights13 library and answer the following
    
    library(nycflights13)
    str(flights)
    

    ## a.	How does the distribution of flights times within a day change over the course of the year
    
    # As seen by plotting the the standard deviations of air time for each day in 2013, 
    # there is an increase in the st. dev. (or distribution) of flight times as the year progresses.

    by_day <- group_by(nycflights13::flights,year,month,day)
    info1 <- as.data.frame(summarise(by_day, avg_time=mean(air_time,na.rm=TRUE), 
              sd_time=sd(air_time,na.rm=TRUE), .groups = "keep"))
    days <- c(1:length(info1$day)) # Easily uses the days from 1 to 365 in a year
    plot(days, info1$sd_time, xlab = "Day Number in the Year", ylab = "St. Dev. in Air Time")
    abline(lm(info1$sd_time ~ days), col = "red", lty=2)
    plot(days, info1$avg_time, xlab = "Day Number in the Year", ylab = "Average Air Time")
    abline(lm(info1$avg_time ~ days), col = "blue", lty=2)

  
    ## b.	Compare dep_time,sched_dep_time, and dep_delay. Are they consistent. Explain your findings
    
    
    # In terms of being properly calculated, it appears that the calculated departure delay is 
    # consistent with the values used for the actual and scheduled departure times, so there are 
    # no errors in that regard.
    
    # When trying to analyze these factors in the same fashion as we did with the air time, 
    # there does not seem to be a similar/relevant association/pattern over the course of the 
    # day of the year.
    

    by_day <- group_by(nycflights13::flights,year,month,day)
    info2 <- as.data.frame(summarise(by_day, avg_deptime=mean(dep_time,na.rm=TRUE), 
              sd_deptime=sd(dep_time,na.rm=TRUE), .groups = "keep"))
    days <- c(1:length(info2$day)) # Easily uses the days from 1 to 365 in a year
    plot(days, info2$sd_deptime, xlab = "Day Number in the Year", 
         ylab = "St. Dev. in Departure Time")
    abline(lm(info2$sd_deptime ~ days), col = "red", lty=2)
    
    info3 <- as.data.frame(summarise(by_day, avg_scheddeptime=mean(sched_dep_time,na.rm=TRUE), 
              sd_scheddeptime=sd(sched_dep_time,na.rm=TRUE), .groups = "keep"))
    days <- c(1:length(info3$day)) # Easily uses the days from 1 to 365 in a year
    plot(days, info3$sd_scheddeptime, xlab = "Day Number in the Year",
         ylab = "St. Dev. in Scheduled Departure Time")
    abline(lm(info3$sd_scheddeptime ~ days), col = "red", lty=2)
    
    info4 <- as.data.frame(summarise(by_day, avg_depdelay=mean(dep_delay,na.rm=TRUE), 
              sd_depdelay=sd(dep_delay,na.rm=TRUE), .groups = "keep"))
    days <- c(1:length(info4$day)) # Easily uses the days from 1 to 365 in a year
    plot(days, info4$sd_depdelay, xlab = "Day Number in the Year", 
         ylab = "St. Dev. in Departure Delay Time")
    abline(lm(info4$sd_depdelay ~ days), col = "red", lty=2)

    
    
    # However, there does seem to be a relationship between the scheduled departure time, 
    # the actual departure time, and the amount of minutes of delay. As seen in the graphs below, 
    # there seem to be a pattern of minute intervals for flights that is associated with the 
    # amount of minutes in delay that the flight has.

    plot(flights$minute, flights$dep_delay, xlab = "Minute of Flight Departure", 
         ylab = "Minutes of Departure Delay")
    abline(h=0, lty = 2, col = "yellow")
    plot(flights$sched_dep_time, flights$dep_delay, xlab = "Scheduled Time of Flight Departure", 
         ylab = "Minutes of Departure Delay")
    abline(h=0, lty = 2, col = "yellow")
    plot(flights$dep_time, flights$dep_delay, xlab = "Actual Time of Flight Departure", 
         ylab = "Minutes of Departure Delay")
    abline(h=0, lty = 2, col = "yellow")
    plot(flights$sched_dep_time, flights$dep_time, xlab = "Scheduled Time of Flight Departure", 
         ylab = "Actual Time of Flight Departure")
    abline(0,1, lty = 2, col = "yellow")



    plot(flights$minute[which(flights$dep_delay<0)], 
         abs(flights$dep_delay[which(flights$dep_delay<0)]), 
         xlab = "Minute of Flight Departure", 
         ylab = "Minutes Early for Departure")
    
    plot(flights$sched_dep_time[which(flights$dep_delay<0)], 
         abs(flights$dep_delay[which(flights$dep_delay<0)]), 
         xlab = "Scheduled Time of Flight Departure", 
         ylab = "Minutes Early for Departure")
    
    plot(flights$dep_time[which(flights$dep_delay<0)], 
         abs(flights$dep_delay[which(flights$dep_delay<0)]), 
         xlab = "Actual Time of Flight Departure", 
         ylab = "Minutes Early for Departure")
    
    plot(flights$sched_dep_time[which(flights$dep_delay<0)],
         flights$dep_time[which(flights$dep_delay<0)], 
         xlab = "Scheduled Time of Flight Departure", 
         ylab = "Actual Time of Flight Departure")
    abline(0,1, lty = 2, col = "yellow")
    
    
    ## c.	Confirm my hypothesis that the early departures of flights in minutes 20-30 and 50-60 
    ## are caused by scheduled flights that leave early. Hint:create a binary variable that 
    ## tells whether or not a flight was delayed.
    
    # Through this analysis, it can be seen that for flights in minutes 20-30 and 50-60, 
    # the majority of these flights are departing early, which is in line with the Professor's hypothesis.

flights3c <- flights
flights3c %<>% mutate(early = ifelse(flights3c$dep_delay < 0, 1, 0), 
                      minute_range = case_when(
                        # minute %in% 1:9 ~ "1-9",
                        # minute %in% 10:19 ~ "10-19",
                        minute %in% 20:30 ~ "20-30",
                        # minute %in% 31:39 ~ "31-39",
                        # minute %in% 40:49 ~ "40-49",
                        minute %in% 50:59 | minute == 0 ~ "50-60"
                      ))

counts <- flights3c %>% count(minute_range, early)
counts



## 4.	(OPTIONAL) Use similar methods as accessing Twitter from an API, 
## search the keyword “black Friday deals” on Facebook.

