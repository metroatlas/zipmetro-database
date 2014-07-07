# This R script builds the database for the ZipMetro database using data from:
# - census.gov
# - unitedstateszipcodes.org

# WORKING DIRECTORY
# Make sure the working directory is set to the root of the repository,
# where this file is, to execute it.

# Source all the R files in subdirectories
source("conma.R")
source("sourceAll.R")
sourceAll()

# Set TRUE if you want to redownload the data
# This can be set for each function
d  <-  TRUE

# Create the ZipCodes database
P_ZipCodes_2010(d)

# Import metro areas delineations, 2013
C_MetroDelineations_2013(d)

# Merge Zip data with metro data
A_ZipCBSA_2010(d)