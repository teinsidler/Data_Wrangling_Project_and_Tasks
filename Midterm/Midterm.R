library("RODBC")
library(dplyr)
library(stringr)
library("sqldf")
myconn<-odbcConnect("database","username","password")

## 1.	The DIQ_I.xpt(will be uploaded on canvas) file has some problems with its data (e.g., missing values, numeric columns stored as chars, etc.) and need to be cleaned before further use. 


# Read the .xpt file 
library(haven)
DIQ_I <- read_xpt("DIQ_I.xpt")

# Check the missing values
colSums(is.na(DIQ_I))

# Check the classes of the columns
sapply(DIQ_I, class)

# Check if any non-numeric  characters exist
lapply(X=DIQ_I, function(x) grep(pattern = "[^0-9]", x, value=TRUE))



### a)	List the data-related issues you see in this data set

### b)	How will you address each data-related issue?

### c)	Give justification for why you chose a particular way to address each issue. For example, if you decide to address missing values by removing rows or filling empty data cells, justify your decision or if you want to create a PHI field like year of Birth




## 2.	Clean the data by addressing each point listed in 1.


# Since I know these columns are consecutive
# I need to find the number value for the first and last column
match('DIQ175A', names(DIQ_I)) # First
match('DIQ175X', names(DIQ_I)) # Last
DIQ_I[,7:30][is.na(DIQ_I[,7:30])] <- 0

DIQ_I[,7:15][sample(nrow(DIQ_I[,7:16]), 10), ]
DIQ_I[,16:24][sample(nrow(DIQ_I[,15:24]), 10), ]
DIQ_I[,25:30][sample(nrow(DIQ_I[,25:30]), 10), ]



# The new column, years_insulin, created from columns DID060 and DIQ060U will be the length of time, 
# in years, that the individual has been taking insulin. Anyone who has been taking insulin for 
# less than a month will be set to a uniform value of 0.08, which is less than 1/12 of a year, 
# or one month (0.0833), because it will be recognizable as a distinct value and can be separated
# from the other calculated values if so desired. Anyone that doesn't know when they started insuling 
# is equivalent to a missing value and thus computed as an NA in the context of this measure.
  
  insulin_vals <- rep(0, 9575)
  for (i in 1:9575){
    if (is.na(DIQ_I$DID060[i])){
      insulin_vals[i] <- NA
    }else if (is.na(DIQ_I$DIQ060U[i])){
      insulin_vals[i] <- NA
    }else if (DIQ_I$DID060[i] <= 55){
      if (DIQ_I$DIQ060U[i] == 1){
        insulin_vals[i] <- DIQ_I$DID060[i] / 12
      }else if (DIQ_I$DIQ060U[i] == 2){
        insulin_vals[i] <- DIQ_I$DID060[i]
      }
    }else if (DIQ_I$DID060[i] == 666){
      insulin_vals[i] <- 0.08
    }else{
      insulin_vals[i] <- NA
    }
  }
  
  DIQ_I$years_insulin <- insulin_vals
  DIQ_I[sample(which(!is.na(DIQ_I$years_insulin)), 10), c('DID060','DIQ060U', 'years_insulin')]
  
  
  
  # The new column, check_sores_yr, created from DID350 and DIQ350U, will be the number of times, 
  # per year, that the individual checked for sores. A year is assumed to have 365 days.
  
  sores <- rep(0, 9575)
  for (i in 1:9575){
    if (is.na(DIQ_I$DID350[i])){
      sores[i] <- NA
    }else if (DIQ_I$DID350[i] == 0){
      sores[i] <- 0
    }else if (is.na(DIQ_I$DIQ350U[i])){
      sores[i] <- NA
    }else if (DIQ_I$DID350[i] <= 20){
      if (DIQ_I$DIQ350U[i] == 1){
        sores[i] <- DIQ_I$DID350[i] * 365
      }else if (DIQ_I$DIQ350U[i] == 2){
        sores[i] <- DIQ_I$DID350[i] * 52
      }else if (DIQ_I$DIQ350U[i] == 3){
        sores[i] <- DIQ_I$DID350[i] * 12
      }else if (DIQ_I$DIQ350U[i] == 4){
        sores[i] <- DIQ_I$DID350[i]
      }
    }else{
      sores[i] <- NA
    }
  }
  
  DIQ_I$check_sores_yr <- sores
  DIQ_I[sample(which(!is.na(DIQ_I$check_sores_yr)), 10), c('DID350','DIQ350U','check_sores_yr')]
  
  
  
  # The new column, is_A1C, created from DIQ280 and DIQ291, will show whether an individual's 
  # A1C levels are within the doctor's recommended range. 1 - yes, 0 - no. 
  # If the provider did not specify a goal, then that will be taken as an NA.
  
  a1c <- rep(0, 9575)
  for (i in 1:9575){
    if (is.na(DIQ_I$DIQ280[i])){
      a1c[i] <- NA
    }else if (is.na(DIQ_I$DIQ291[i])){
      a1c[i] <- NA
    }else if (DIQ_I$DIQ280[i] <= 18.5){
      if (DIQ_I$DIQ291[i] == 1){
        if (DIQ_I$DIQ280[i] < 6){
          a1c[i] <- 1
        }else {
          a1c[i] <- 0
        }
      }else if (DIQ_I$DIQ291[i] == 2){
        if (DIQ_I$DIQ280[i] < 7){
          a1c[i] <- 1
        }else {
          a1c[i] <- 0
        }
      }else if (DIQ_I$DIQ291[i] == 3){
        if (DIQ_I$DIQ280[i] < 8){
          a1c[i] <- 1
        }else {
          a1c[i] <- 0
        }      
      }else if (DIQ_I$DIQ291[i] == 4){
        if (DIQ_I$DIQ280[i] < 9){
          a1c[i] <- 1
        }else {
          a1c[i] <- 0
        }      
      }else if (DIQ_I$DIQ291[i] == 5){
        if (DIQ_I$DIQ280[i] < 10){
          a1c[i] <- 1
        }else {
          a1c[i] <- 0
        }
      }else if (DIQ_I$DIQ291[i] == 6){
        a1c[i] <- NA
      }
    }else{
      a1c[i] <- NA
    }
  }
  
  DIQ_I$is_A1C <- a1c
  DIQ_I[sample(which(!is.na(DIQ_I$is_A1C)), 10), c('DIQ280','DIQ291','is_A1C')]
  
  
  
  # The new column, is_SBP, created from columns DIQ300S and DID310S, 
  # will show whether an individual's SBP is within the doctor's recommended range. 1 - yes, 
  # 0 - no. If the provider did not specify a goal, or there was a refusal, 
  # then that will be taken as an NA.
  
  sbp <- rep(0, 9575)
  for (i in 1:9575){
    if (is.na(DIQ_I$DIQ300S[i])){
      sbp[i] <- NA
    }else if (is.na(DIQ_I$DID310S[i])){
      sbp[i] <- NA
    }else if (DIQ_I$DIQ300S[i] <= 201 & DIQ_I$DIQ300S[i] >= 80){
      if (DIQ_I$DID310S[i] <= 175 & DIQ_I$DID310S[i] >= 80){
        if (DIQ_I$DIQ300S[i] <= DIQ_I$DID310S[i]){
          sbp[i] <- 1
        }else if (DIQ_I$DIQ300S[i] >= DIQ_I$DID310S[i]){
          sbp[i] <- 0
        }else{
          sbp[i] <- NA
        }
      }else{
        sbp[i] <- NA
      }
    }
  }
  
  DIQ_I$is_SBP <- sbp
  DIQ_I[sample(which(!is.na(DIQ_I$is_SBP)), 10), c('DIQ300S','DID310S','is_SBP')]
  
  
  
  # The new column, is_DBP, created from columns DIQ300D and DID310D, 
  # will show whether an individual's DBP is within the doctor's recommended range. 1 - yes, 
  # 0 - no. If the provider did not specify a goal, or there was a refusal, 
  # then that will be taken as an NA.

  dbp <- rep(0, 9575)
  for (i in 1:9575){
    if (is.na(DIQ_I$DIQ300D[i])){
      dbp[i] <- NA
    }else if (is.na(DIQ_I$DID310D[i])){
      dbp[i] <- NA
    }else if (DIQ_I$DIQ300D[i] <= 251 & DIQ_I$DIQ300D[i] >= 17){
      if (DIQ_I$DID310D[i] <= 140 & DIQ_I$DID310D[i] >= 18){
        if (DIQ_I$DIQ300D[i] <= DIQ_I$DID310D[i]){
          dbp[i] <- 1
        }else if (DIQ_I$DIQ300D[i] >= DIQ_I$DID310D[i]) {
          dbp[i] <- 0
        }else {
          dbp[i] <- NA
        }
      }else{
        dbp[i] <- NA
      }
    }
  }
  
  DIQ_I$is_DBP <- dbp
  DIQ_I[sample(which(!is.na(DIQ_I$is_DBP)), 10), c('DIQ300D','DID310D','is_DBP')]

  
  
  # The new column, is_LDL, created from DID320 and DID330, will show whether an individual's 
  # LDL number is within the doctor's recommended range. 1 - yes, 0 - no.
  # If the provider did not specify a goal, or there was a refusal, or they don't know, 
  # then that will be taken as an NA.

ldl <- rep(0, 9575)
for (i in 1:9575){
  if (is.na(DIQ_I$DID320[i])){
    ldl[i] <- NA
  }else if (is.na(DIQ_I$DID330[i])){
    ldl[i] <- NA
  }else if (DIQ_I$DID320[i] <= 520 & DIQ_I$DID320[i] >= 4){
    if (DIQ_I$DID330[i] <= 205 & DIQ_I$DID330[i] >= 6){
      if (DIQ_I$DID320[i] <= DIQ_I$DID330[i]){
        ldl[i] <- 1
      }else if (DIQ_I$DID320[i] >= DIQ_I$DID330[i]){
        ldl[i] <- 0
      }else {
        ldl[i] <- NA
      }
  }else{
    ldl[i] <- NA
  }
}
}

DIQ_I$is_LDL <- ldl
match(c(), names(DIQ_I))
DIQ_I[sample(which(!is.na(DIQ_I$is_LDL)), 10), c('DID320','DID330','is_LDL')]



# Now, with all of my corrections, I can turn this dataset in R into a table in SQL.

sqlSave(myconn, dat = DIQ_I, tablename = "eeinsidler.midterm")
