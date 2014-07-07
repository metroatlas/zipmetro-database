# Merge Zip data with metro data

A_ZipCBSA_2010 <- function(d = TRUE) {
  
  Sys.setlocale("LC_ALL", 'en_US.UTF-8')
  
  # Download state FIPS
  if(d) {
    fileUrl <- "http://www.census.gov/geo/reference/docs/state.txt"
    download.file(fileUrl, destfile="data/state-fips.csv", method="curl")
    dateDownloaded <- date()
    write(dateDownloaded,file="data/state-fips.csv.csv.date.txt")
  }

  
  # Import state FIPS
  states <- read.csv("data/state-fips.csv",
                     sep="|", header = TRUE,
                     colClasses="character",
                     fileEncoding="UTF-8")
  colnames(states) <-  c("FIPSStateCode", "stusab", "StateName", "stateens")
  
  
  # Get data from database
  con <- conma()
  delin <- dbReadTable(con, "C_MetroDelineations_201302")
  zips <- dbReadTable(con, "P_ZipCodes_2010")
  dbDisconnect(con)
  
  zips <- zips[, c(1,6,7)]
  colnames(zips) <- c("zip","stusab","countyname")
  
  #Format county names
  removeCounty <- function(x){
    if(x == "") {return(x)}
    splitWords <- strsplit(x, " ")[[1]]
    qualif  <- c("County", "Borough", "Municipality", "Municipio", "City")
    if(tail(splitWords, n=1) %in% qualif){
      paste(head(splitWords, -1), collapse = " ")
    } else {
      x
    }
  }
  zips$countynamefull <- zips$countyname
  zips$countyname <- sapply(zips$countyname, removeCounty)
  
  # Merge with states to get state fips
  zips <- merge(zips, states, by = "stusab")[,1:5]
  
  # Format county names in delineation file
  delin$countyname <- sapply(delin$CountyCountyEquivalent, removeCounty)
  
  # Merge zips with CBSA delineation file
  zips <- merge(zips, delin, by = c("FIPSStateCode", "countyname"), all.x = TRUE)
  to.keep <- c("zip",
               "FIPSStateCode",
               "FIPSCountyCode",
               "StateName",
               "countynamefull",
               "countyname",
               "CBSACode",
               "CBSATitle",
               "Type",
               "CBSACentralCity",
               "CSACode",
               "CSATitle",
               "CSACentralCity"
  )
  zips <- zips[,to.keep]
  
  # Write table
  con <- conma()
  dbWriteTable(con, name="A_ZipCBSA_2010", value=zips, overwrite=TRUE)
  dbDisconnect(con)
}