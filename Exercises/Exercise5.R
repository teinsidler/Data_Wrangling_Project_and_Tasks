# 1.	In the Flowsheet table,
library("RODBC")
library(dplyr)
library(stringr)
library("sqldf")
myconn<-odbcConnect("database","username","password")
Flowsheets <-sqlQuery(myconn,"SELECT * FROM Flowsheets")

# extract the cc/kg in disp_name and convert it to CC-Kg
Flowsheets$DISP_NAME <- gsub("cc/kg", "CC-KG", Flowsheets$DISP_NAME)

# 2.	In the flowsheets table,
# find any alphanumeric character and replace them with spaces
# Can't run the whole dataframe simply through gsub 
# so it must be done through a function that will perceive it as a list/vector
Flowsheets[] <- lapply(X=Flowsheets, function(x) 
                      gsub(pattern = "[[:alnum:]]", replacement = " ",x))

# 3.	In the provider table,
# split and create a new column which reflects first and last names.
# Extract all the providers whose last name starts with "Wa"
Provider <-sqlQuery(myconn,"select * from Provider")
split_names <- str_split_fixed(string = Provider$NEW_PROV_NAME, 
                                          pattern = ", ", n=2)
Provider$LAST_NAME <- split_names[,1]
Provider$FIRST_NAME <- split_names[,2]
Provider_Wa <- grep("^Wa", Provider$LAST_NAME, value = TRUE)
# I noticed that not all of the first and last names are capitalized.
# Since this affects what the output is
# for providers whose last names start with "Wa",
# I will assume we want proper Title font for names and will clean up the names
# and I will repeat the process
Provider$LAST_NAME <- str_to_title(split_names[,1])
Provider$FIRST_NAME <- str_to_title(split_names[,2])
Provider_Wa_new <- grep("^Wa", Provider$LAST_NAME, value = TRUE)
Provider_Wa
Provider_Wa_new

