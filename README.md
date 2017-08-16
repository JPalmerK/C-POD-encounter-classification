# C-POD-encounter-classification
# This file contains the GAM 'teICINcycFqApr6.rdata'from Palmer et al 2017  
# http://asa.scitation.org/doi/10.1121/1.4996000

# Input: 
# MedICI- median inter-click-interval of the C-POD click train
# NCycles- median number of cycles for the clicks in each click train
# MeanFreq- Mean frequency of the clicks in each C-POD click train 

# Output:
# Speciesid- the logit probability that each click train was 'frequency banded' i.e. contained spectral peaks and notches
# consistant with whitebeaked/risso's off-axis click trains. Since our study assumed that ESC clcik trains must be either broadband
# 'broadband' or 'frequency banded' the model is binary. To estimate 'broadband' probability subtract inv.logit() of the model output 
# from 1. 



