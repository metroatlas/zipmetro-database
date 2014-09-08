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
  
  zips <- zips[, c(1,3,4,6,7)]
  colnames(zips) <- c("zip","primary_city","acceptable_cities","stusab","countyname")
  
  allCities <- function(x,y) {
    if(y == ""){
      return(x)
    } else {
      return(paste(x, y, sep = ", "))
    }
  }
  
  zips$allCities <- mapply(FUN = allCities, zips$primary_city, zips$acceptable_cities)
  
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
  zips <- merge(zips, states, by = "stusab")[,1:9]
  
  # Format county names in delineation file
  delin$countyname <- sapply(delin$CountyCountyEquivalent, removeCounty)
  delin$StateName <- NULL
  
  # Merge zips with CBSA delineation file
  zips <- merge(zips, delin, by = c("FIPSStateCode", "countyname"), all.x = TRUE)
  to.keep <- c("zip",
               "FIPSStateCode",
               "FIPSCountyCode",
               "StateName",
               "countynamefull",
               "countyname",
               "countyConsolidated",
               "primary_city",
               "acceptable_cities",
               "allCities",
               "CBSACode",
               "CBSATitle",
               "Type",
               "CBSACentralCity",
               "CBSACentralCities",
               "CBSAStates",
               "CSACode",
               "CSATitle",
               "CSACentralCity",
               "CSACentralCities",
               "CSAStates"
  )
  zips <- zips[,to.keep]
  
  # Make PSA
  # Primary Statistical Area is the highest level of a metro area, wither the CSA or the CBSA for
  # metro areas that are not part of a CSA.
  # See http://en.wikipedia.org/wiki/List_of_primary_statistical_areas_of_the_United_States
  
  getPSA <- function(row) {
    r = data.frame()
    if(is.na(row['CSACode'])) {
      r = data.frame(row['CBSACode'], row['CBSATitle'], row['CBSACentralCity'], row['CBSACentralCities'], row['CBSAStates'])
    } else {
      r = data.frame(row['CSACode'], row['CSATitle'], row['CSACentralCity'], row['CSACentralCities'], row['CSAStates'])
    }
    colnames(r) <- c("PSACode","PSATitle","PSACentralCity", "PSACentralCities", "PSAStates")
    return(r)
  }
  
  PSA <- do.call(rbind, apply(zips, 1, getPSA))
  zips <- cbind(zips, PSA)
  
  # Write table
  con <- conma()
  dbWriteTable(con, name="A_ZipCBSA_2010", value=zips, overwrite=TRUE)
  dbDisconnect(con)
}