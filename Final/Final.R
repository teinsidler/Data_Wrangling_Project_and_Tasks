library("RODBC")
library(dplyr)
library(tidyr)
library(stringr)
library("sqldf")
library(lubridate)
library(magrittr)
myconn<-odbcConnect("database","username","password")



# 1)	Consider the following blood pressure dataset (IC_BP_v2.csv). Perform the following operations



IC_BP_v2 <- read.csv("IC_BP_v2.csv")
# Check the missing values
colSums(is.na(IC_BP_v2))
IC_BP_v2[sample(nrow(IC_BP_v2), 10), ]



# a.	Convert BP alerts to BP status



colnames(IC_BP_v2)[colnames(IC_BP_v2) == "BPAlerts"] <- "BPStatus"
IC_BP_v2[,4:5][sample(nrow(IC_BP_v2[,4:5]), 10), ]



# b.	Define Hypo-1 & Normal as Controlled blood pressure; Hypo-2, HTN1, HTN2 HTN3 as Uncontrolled blood pressure: Controlled & Uncontrolled blood pressure as 1 or 0 (Dichotomous Outcomes) 



for (i in 1:nrow(IC_BP_v2)) {
  if (IC_BP_v2$BPStatus[i] == "Hypo1") {
    IC_BP_v2$ControlledBP[i] <- 1
  }else if (IC_BP_v2$BPStatus[i] == "Normal") {
    IC_BP_v2$ControlledBP[i] <- 1
  }else if (IC_BP_v2$BPStatus[i] == "Hypo2") {
    IC_BP_v2$ControlledBP[i] <- 0
  }else if (IC_BP_v2$BPStatus[i] == "HTN1") {
    IC_BP_v2$ControlledBP[i] <- 0
  }else if (IC_BP_v2$BPStatus[i] == "HTN2") {
    IC_BP_v2$ControlledBP[i] <- 0
  }
}
# Commented out because the table has been made already
# sqlSave(myconn, dat = IC_BP_v2, tablename = "eeinsidler.final",
#         rownames = F)



# c.	Merge this table with demographics (SQL table) to obtain their enrollment dates



Demographics <- sqlQuery(myconn, "SELECT * FROM Demographics")
BP_Dem <- merge(IC_BP_v2, Demographics, by.x = "ID", by.y = "contactid")
# Ensure the columns are in date formats
BP_Dem$tri_enrollmentcompletedate <-
  as.Date(BP_Dem$tri_enrollmentcompletedate,format="%m/%d/%Y")
BP_Dem[sample(nrow(BP_Dem), 10), ]



# d.	Create a 12-week interval of averaged scores of each customer 



# ObservedTime be in date format
BP_Dem$ObservedTime <- as.Date(BP_Dem$ObservedTime, origin = "1899-12-31")

BPD_copy <- group_by(BP_Dem, ID)
BPD_copy %<>% filter((difftime(tri_enrollmentcompletedate, 
                               ObservedTime, units =  "weeks") < 12))
BPD_summary <- summarise(BPD_copy, avg_score = mean(ControlledBP))
BPD_summary




#be.	Compare the scores from baseline (first week) to follow-up scores (12 weeks)



BPD_copy2 <- BP_Dem

BPD_copy2 %<>% arrange(ID, ObservedTime)
BPD_copy2 %<>% distinct(ID, .keep_all = TRUE)

BPD_compare <- c(rep(0, 143))
for (i in 1:143){
  BPD_compare[i] <- BPD_summary$avg_score[i] - BPD_copy2$ControlledBP[i]
}

BPD_scores <- cbind(BPD_summary$ID, 
                    BPD_copy2$ControlledBP, 
                    BPD_summary$avg_score, BPD_compare)
colnames(BPD_scores) <- c("ID", "ControlledBP_Start", "Avg", "Compared")
BPD_scores[sample(nrow(BPD_scores), 10), ]



#f.	How many customers were brought from uncontrolled regime to controlled regime after 12 weeks of intervention?
  
  
  #*There were five customers that were brought from a uncontrolled regime to a controlled regime based off of their first and last recorded measurements.*
  
BPD_copy3 <- BP_Dem
BPD_copy3 %<>% arrange(ID, desc(ObservedTime))
BPD_copy3 %<>% distinct(ID, .keep_all = TRUE)
bef_aft <- inner_join(BPD_copy2[,c(1,6)], BPD_copy3[,c(1,6)], by="ID")
bef_aft %<>% filter(ControlledBP.x == 1)
bef_aft %<>% filter(ControlledBP.y == 0)
bef_aft %>% count(ControlledBP.x)



# 2)	Merge the tables Demographics, Conditions and TextMessages. 
# Obtain the final dataset such that we have 1 Row per ID by choosing on the latest date when the text was sent (if sent on multiple days)


# Note: see SQL code for the procedure being done in SQL
# This is only here in order to display the table in this file
sqlQuery(myconn, "SELECT top 10 * FROM eeinsidler.final_q2_max
             ORDER BY NEWID()")



# 3)	Repeat Question 2 in R. 
# Hint: You might want to use tidyr/dplyr packages



# Bring the tables from SQL into R
Conditions <- sqlQuery(myconn, "SELECT * FROM Conditions")
Text <- sqlQuery(myconn, "SELECT * FROM Text")
# Merge the tables together
Dem_Cond <- merge(Demographics, Conditions, 
                  by.x = "contactid", by.y = "tri_patientid")
T_D_C <- merge(Dem_Cond, Text, by.x = "contactid", by.y = "tri_contactId")
# Order the texts sent for each ID by the most recent sent date
T_D_C %<>% arrange(contactid, desc(TextSentDate))
# Keep only one row per ID
T_D_C_distinct <- distinct(T_D_C, contactid, .keep_all = TRUE)
T_D_C_distinct[sample(nrow(T_D_C_distinct), 10), ]



# 4)	Set up a public GitHub repository to share your code. If you didn’t attend the Research Computing’s Git/BASH workshop, or no longer familiar with it, please use online resources (e.g. YouTube tutorials) to re-familiarize yourself with Git/GitHub.


# https://github.com/teinsidler/Data_Wrangling_Project_and_Tasks