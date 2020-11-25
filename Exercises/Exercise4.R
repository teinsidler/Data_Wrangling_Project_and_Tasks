library("RODBC")
library(dplyr)
library(stringr)
library("sqldf")

# 1.	Connect to the database and extract data from DX table.
myconn<-odbcConnect("database","username","password")
Dx <-sqlQuery(myconn,"select * from Dx")

# Make  all the entries in disp_Name to a lower case
Dx$DX_NAME = tolower(Dx$DX_NAME)

# 2.	Remove any commas and whitespace
# I am assuming that the removal of white space means
# I should remove all of the white space outside and within each entry of DISP_NAME
Dx$DX_NAME <- gsub(" ","", Dx$DX_NAME,fixed=TRUE)
Dx$DX_NAME <- gsub(",","", Dx$DX_NAME,fixed=TRUE)

# 3.	Merge Inpatient and Outpatient tables
# based on NEW_PATIENT_DHMC_MRN by removing any hyphens. 
Outpatient <- sqlQuery(myconn, "SELECT * FROM Outpatient")
Outpatient$NEW_PATIENT_DHMC_MRN <- gsub("-","", Outpatient$NEW_PATIENT_DHMC_MRN)

Inpatient <- sqlQuery(myconn, "SELECT * FROM Inpatient")
Inpatient$NEW_PATIENT_DHMC_MRN <- gsub("-","", Inpatient$NEW_PATIENT_DHMC_MRN)


Inpatient_Outpatient <- sqldf("SELECT o. * FROM Outpatient o INNER JOIN 
                              Inpatient i on o.NEW_PATIENT_DHMC_MRN=i.NEW_PATIENT_DHMC_MRN")

# 4.	Do you see the same distinct NEW_PATIENT_DHMC_MRN
# when merged on NEW_PAT_ID
Outpatient$NEW_PAT_ID <- tolower(Outpatient$NEW_PAT_ID)
Inpatient_Outpatient_2 <- sqldf("SELECT o. * FROM Outpatient o INNER JOIN 
                              Inpatient i on o.NEW_PAT_ID=i.NEW_PAT_ID")