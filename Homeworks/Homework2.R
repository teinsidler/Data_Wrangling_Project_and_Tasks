library("RODBC")
library(dplyr)
library(stringr)
library("sqldf")



## 1.	Create a new column “Enrollment group” in the table Phonecall
# a)	Insert EnrollmentGroup=Clinical Alert :code is 125060000
# b)	Insert EnrollmentGroup =Health Coaching :code is 125060001
# c)	Insert EnrollmentGroup =Technixal Question: Code is 125060002
# d)	Insert EnrollmentGroup =Administrative: Code  is 125060003
# e)	Insert EnrollmentGroup =Other: Code  is 125060004
# f)	Insert EnrollmentGroup =Lack of engagement : Code  is 125060005


myconn<-odbcConnect("database","username",
                    "password")
# The table that actually contains the codes 
# specified in the question
# is Phonecall_Encounter
PhoneCall_Encounter <-sqlQuery(myconn,"SELECT * 
                               FROM PhoneCall_Encounter")
for (i in 1:(nrow(PhoneCall_Encounter))){
  if (PhoneCall_Encounter$EncounterCode[i] == 125060000){
    PhoneCall_Encounter$EnrollmentGroup[i] <- "Clinical Alert"
  }else if (PhoneCall_Encounter$EncounterCode[i] ==
            125060001){
    PhoneCall_Encounter$EnrollmentGroup[i] <- "Health Coaching"
  }else if (PhoneCall_Encounter$EncounterCode[i] ==
            125060002){
    PhoneCall_Encounter$EnrollmentGroup[i] <- "Technical Question"
  }else if (PhoneCall_Encounter$EncounterCode[i] ==
            125060003){
    PhoneCall_Encounter$EnrollmentGroup[i] <-
      "Administrative"
  }else if (PhoneCall_Encounter$EncounterCode[i] ==
            125060004){
    PhoneCall_Encounter$EnrollmentGroup[i] <- "Other"
  }else if (PhoneCall_Encounter$EncounterCode[i] ==
            125060005){
    PhoneCall_Encounter$EnrollmentGroup[i] <- "Lack of Engagement"
  }
}
PhoneCall_Encounter[sample(nrow(PhoneCall_Encounter), 5), ]


## 2.	Obtain the # of records for each enrollment group


enroll_records <- PhoneCall_Encounter %>% count(EnrollmentGroup)
colnames(enroll_records) <- c("Enrollment Group", 
                              "Number of Records")
enroll_records


## 3.	Merge the Phone call encounter table with Call duration table.


CallDuration <- sqlQuery(myconn, "SELECT * FROM CallDuration")
PC_Encounter_Duration <- sqldf("SELECT * FROM
                               PhoneCall_Encounter e 
                               INNER JOIN CallDuration d 
                               ON
                               e.CustomerId=
                               d.tri_CustomerIDEntityReference")
PC_Encounter_Duration[sample(nrow(PhoneCall_Encounter), 5), ]


## 4.	Find out the # of records for different call outcomes and call type. Use 1-Inbound and 2-Outbound, for call types; use 1-No response, 2-Left voice mail and 3 successful. Please also find the call duration for each of the enrollment groups


CT_Count <- PC_Encounter_Duration %>% count(CallType)
row.names(CT_Count) <- c("Inbound", "Outbound")
CT_Count

CT_Outcome <- PC_Encounter_Duration %>% count(CallOutcome)
row.names(CT_Outcome) <- c("No Response", "Left Voicemail", "Successful")
CT_Outcome


# If we want to do both at once:
  
CT_T_O <- PC_Encounter_Duration %>% count(CallType, CallOutcome)
row.names(CT_T_O) <- c("Inbound, No Response", "Inbound, Left Voicemail",
                       "Inbound, Successful", "Outbound, No Response",
                       "Outbound, Left Voicemail", "Outbound, Successful")
colnames(CT_T_O) <- c("Call Type Code", "Call Outcome Code", 
                      "Number of Records")
CT_T_O



## 5.	Merge the tables Demographics, Conditions and TextMessages. Find the # of texts/per week, by the type of sender. 


# Merged the tables
DemCondText <- sqlQuery(myconn, "SELECT * FROM (SELECT * FROM 
                        Conditions c INNER JOIN Demographics d 
                        ON c.tri_patientid=d.contactid) a 
                        INNER JOIN Text t ON a.tri_patientid=t.tri_contactid")
DemCondText[sample(nrow(PhoneCall_Encounter), 5), ]

# Since I found out that sqldf() uses SQLite, which doesn't support DATEPART, 
# I knew that I needed to use sqlQuery() to separate the texts by week 
# in the manner that I found familiar. Since question 5 asks for the group to be by type of sender,
# I knew I only needed to perform a new query on the Text table.


TextPerWeek_Sender <- sqlQuery(myconn,"SELECT SenderName, 
                               (COUNT(DATEPART(week,TextSentDate))/
                               MAX(DATEPART(week,TextSentDate))) AS
                               TextPerWeek FROM Text GROUP BY SenderName")
TextPerWeek_Sender



## 6.	Obtain the count of texts based on the chronic condition over a period of time (say per week). 
# See reasoning from question 5 as to why I completed a new sqlQuery().


# Obtaining the average number of texts per week from the database information
# Based on condition
Condition_Text <- sqlQuery(myconn, "SELECT tri_name,
                           (COUNT(DATEPART(week,TextSentDate))
                           /MAX(DATEPART(week,TextSentDate))) AS TextPerWeek
                           FROM (SELECT * FROM Conditions c 
                           INNER JOIN Demographics d 
                           ON c.tri_patientid=d.contactid) a 
                           INNER JOIN Text t ON
                           a.tri_patientid=t.tri_contactid GROUP BY tri_name")
Condition_Text



# Obtaining the average number of texts per week from the database information
# Based on parentcustomeridname
Demographics_Text <- sqlQuery(myconn, "SELECT parentcustomeridname,
                              (COUNT(DATEPART(week,TextSentDate))/
                              MAX(DATEPART(week,TextSentDate))) AS TextPerWeek
                              FROM (SELECT * FROM Conditions c 
                              INNER JOIN Demographics d 
                              ON c.tri_patientid=d.contactid) a 
                              INNER JOIN Text t ON
                              a.tri_patientid=t.tri_contactid 
                              GROUP BY parentcustomeridname")
Demographics_Text


