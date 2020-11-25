library("RODBC")
library(dplyr)
library(stringr)
library("sqldf")
myconn<-odbcConnect("database","username","password")



# 1.	In the Demographics table, find missing values with Age and perform a mean imputation

Demographics <-sqlQuery(myconn,"select * from Demographics")
# Identify NAs
which(is.na(Demographics$tri_age))
# Count the number of NAs
sum(is.na(Demographics$tri_age))
# Find the mean
mean(Demographics$tri_age, na.rm = TRUE)



# 2.	In the Phonecall  table, add a new column call end time and calculate the field
## This is being done with the assumption that 


PhoneCall <-sqlQuery(myconn,"SELECT *FROM PhoneCall")

# PhoneCall <-sqlQuery(myconn,"select *, DATEADD(second, CONVERT(int,CallDuration),
#                      CONVERT(varchar(50), CallStartTime, 22))
#                      AS EndTime FROM PhoneCall")



PhoneCall$CallStartTime <- as.POSIXlt(x=PhoneCall$CallStartTime, format='%m/%j/%y %I:%M %OS', tz='EST')
PhoneCall$EndTime <- PhoneCall$CallStartTime + PhoneCall$CallDuration
PhoneCall[sample(nrow(PhoneCall), 5), ]



# 3.	Use the information in the tables Encounters, procedure, and provider, answer the following
## I.	What kind of procedure did the patient had which had the maximum length of stay


Encounters <- sqlQuery(myconn, "SELECT * FROM Encounters")
Provider <- sqlQuery(myconn, "SELECT * FROM qbs181.dbo.Provider")
Procedure <- sqlQuery(myconn, "SELECT * FROM [dbo].[Procedure]")
Enc_Pro <- merge(Encounters, Provider,
                 by.x = 'NEW_VISIT_PROV_ID', by.y = 'NEW_PROV_ID')
EPP <- merge(Enc_Pro, Procedure, by.x = 'NEW_PAT_ENC_CSN_ID', by.y='PAT_ENC_CSN_ID')

admit <- as.Date(EPP$NEW_HSP_ADMIT_DATE,format="%m/%d/%Y")
depart <- as.Date(EPP$NEW_HSP_DISCH_DATE,format="%Y-%m-%d")
EPP$PROC_DESC[which.max((depart - admit))]



## II.	Provide top 5 providers who saw patients staying at the hospital for the maximum # of days


EPP$StayDuration <- (depart-admit)
order_stay <- order(EPP$StayDuration, decreasing=TRUE)
EPP.ordered <- EPP[order_stay, ]
library(dplyr)
EPP.distinct <- distinct(EPP.ordered, NEW_PROV_NAME, .keep_all = TRUE)
EPP.distinct$NEW_PROV_NAME <- str_to_title(EPP.distinct$NEW_PROV_NAME)
EPP.distinct[1:5,c(9,28)]



