

# Code for running GAM categorisation system for acoustic encounters
# Spelling mistakes designed prevent copywrite infringment.
# For further information contact the author k palmer at coa dot edu. No spaces.

# 1) Load packages and model ##########

rm(list=ls())
library(boot) # primarily for inv.logit
library(car)
library(mgcv)

load(file='CategorisationGAM.rdata')


# Load C-POD click train data. These data have been pre-processed in 
# Matlab to calculate several variables including the model parameters
# Median interclick interval (MedICI), median number of click cycles in the
# train (NCycles) and the mean frequency of the clicks in the train (MeanFreq)
# The MATLAB decimal date was also added for ease of computing encounter 
# times. This may be achieved in R as well, but I prefer[ed] Matlab for dealing
# with dates and times.


# The dataframe must also contain a column called "Speciesid" which should
# be set to 0

Trains=read.csv('YourData.csv')

# 2) Run the GAM categorisation #########

# Create empty column to store prediction values
Trains$Predicted='NA'

# Run the GAM on all the data and transform the scale to 0-1. The transformation
# isn't strictly necessary, and many likelihood values calculated on the logit
# or log scale, but it makes it nice for initial plotting. 
Trains$Predicted=inv.logit(predict.gam(gam1, newdata = Trains))


# 3) Label Acoustic Encounters and Apply Likelihood Calculations ####

# This section gives unique labels to all acoustic encounters from the entire
# deployment (26 C-PODs)

# Sort dataframe by deployment location and date
Trains=Trains[order(Trains$UnitLoc, Trains$MatlabDecDate),]
row.names(Trains) <- 1:nrow(Trains)

# New column for encounter ID
Trains$EncounterID=array(NA, dim=nrow(Trains))
IDX=1 
EncounterVal=1
MaxETime=30/60/24 # Maximum duration between sucessive click trains to label encounters

Trains$EncounterID[1]=1
Trains$EncounterDuration=0

while(length(which(is.na(Trains$EncounterID)))>0){
  
  # Get starter index
  IDX=max(which(!is.na(Trains$EncounterID)))
  
  # Get starter encounter values and set ID
  EncounterTrains=which(Trains$UnitLoc==Trains$UnitLoc[IDX] &
                          Trains$MatlabDecDate <= Trains$MatlabDecDate[IDX]+MaxETime &
                          Trains$MatlabDecDate > Trains$MatlabDecDate[IDX])
  
  if (length(EncounterTrains>0)) {
    
    Trains$EncounterID[EncounterTrains]=EncounterVal
    
  }   else{
    EncounterVal=EncounterVal+1
    Trains$EncounterID[IDX+1]=EncounterVal
  }             
  print(EncounterVal)
}

# Apply the Likelihood Ratio ###

# Create empty column for species id, could also save likelihood values
Trains$EncounterSpp=array(NA, dim=nrow(Trains))


for (ii in 1:max(Trains$EncounterID)){
  
  # Trains exclude is a binary indicating whether (1) or not (1) I 
  # chose to include a click train in the likelihood ratio based on 
  # whether it was trimmed from the analysis (see data quality) or
  # could be independently varified in the adjacent SM2M recordings. 
  # All of this can be achieved by properly implementing the aggregate
  # function. Unfortunately, the 2014 version of the author didn't know that and
  # 2017 version doesn't have time to update it since the code works fine as it is. 
  
  aa=Trains$Predicted[Trains$EncounterID==ii & Trains$Exclude==0]
  bb=1-aa
  # Probability that it's WBD/RSD
  
  FBLiklihood=prod(aa)
  BBLiklihood=prod(bb)
  
  if(BBLiklihood/FBLiklihood>5){
    Trains$EncounterSpp[Trains$EncounterID==ii]='Broadband'
  }
  else if(BBLiklihood/FBLiklihood<1/5){
    Trains$EncounterSpp[Trains$EncounterID==ii]='FreqBanded'
  }
  else{
    Trains$EncounterSpp[Trains$EncounterID==ii]='UNK'
  }
  
}



# 4) Visualise the GAM #####


vis.gam2(gam1, view = c('MeanFreq', 'MedICI'),
         plot.type='contour', type = "response",
         #ticktype="detailed",
         color = 'gray',cex.lab=1, cex.axis=1,
         xlab='Mean fZC', ylab='Median ICI', main="")

vis.gam2(gam1, view = c('NCycles', 'MedICI'),
         plot.type='contour', type = "response",
         #ticktype="detailed",
         color = 'gray', cex.lab=1, cex.axis=1,
         xlab='Mean Cycles', ylab='Median ICI', main="")




