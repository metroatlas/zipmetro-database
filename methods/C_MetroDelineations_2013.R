C_MetroDelineations_2013 <- function(d = TRUE){
  # Download data
  if(d) {
    fileUrl <- "https://www.census.gov/population/metro/files/lists/2013/List1.xls"
    download.file(fileUrl, destfile="data/C_MetroDelineations_201302.xls", method="curl")
    dateDownloaded <- date()
    write(dateDownloaded,file="data/C_MetroDelineations_201302.xls.date.txt")
  }
  
  # Load data
  library(xlsx)
  md <- read.xlsx("data/C_MetroDelineations_201302.xls",
                  sheetIndex=1,
                  colIndex=1:12,
                  rowIndex=3:1885,
                  colClasses="character",
                  header=TRUE)
  
  # Get table of state abbreviations
  con <- conma()
  states <- dbReadTable(con, "P_StatesAbbr_2010")
  dbDisconnect(con)
  states$StateName <- as.character(states$StateName)
  
  # Transform names
  names(md) <- gsub("\\.","",names(md))
  md[c(1:4,6:11)]  <- lapply(md[c(1:4,6:11)], as.character)
  md[1:3] <- lapply(md[1:3], as.integer)
  
  # Type
  md$MetropolitanMicropolitanStatisticalArea <- factor(md$MetropolitanMicropolitanStatisticalArea, levels = c("Micropolitan Statistical Area", "Metropolitan Statistical Area"))
  md$Type <- as.integer(md$MetropolitanMicropolitanStatisticalArea) - 1
  md$Type <- as.integer(md$Type)
  
  # CentralCounty
  md$CentralOutlyingCounty  <- factor(md$CentralOutlyingCounty, levels = c("Outlying", "Central"))
  md$CentralCounty  <- as.integer(md$CentralOutlyingCounty) - 1
  md$CentralCounty  <- as.integer(md$CentralCounty) - 1
  
  
  # Methods for first and last elements of a list
  firstElement <- function(x){x[1]}
  lastElement <- function(x) {
      return(tail(x, n = 1))
  }
  
  # Replaces dashes with comma separators
  dtoc  <- function(x) {
    y <- unlist(strsplit(x,"-"))
    z <- paste(y, sep = ',', collapse = ',')
    return(z)
  }
  
  # CBSACentralCity
  md$CBSACentralCities <- sapply(strsplit(md$CBSATitle,"[,]"), firstElement)
  md$CBSACentralCities <- sapply(md$CBSACentralCities, dtoc)
  md$CBSACentralCity <- sapply(strsplit(md$CBSACentralCities,"[,]"), firstElement)

  
  # CSACentralCity
  md$CSACentralCities <- sapply(strsplit(md$CSATitle,"[,]"), firstElement)
  md$CSACentralCities <- sapply(md$CSACentralCities, dtoc)
  md$CSACentralCity <- sapply(strsplit(md$CSACentralCities,"[,]"), firstElement)
  
  #State names from abbreviations
  getStateName <- function(abr) {
    return(states[states$StateAbbr == abr,]['StateName'])
  }
  
  getStateNames  <- function(abrs) {
      if(!is.na(abrs)) {
        abrv  <- unlist(strsplit(abrs, "[-]")[1])
        stnv  <- unlist(sapply(abrv, getStateName))
        ststr <- paste(stnv, collapse = ',')
        return(ststr)
      } else {
        return(NA)
      }
  }
  
  # CBSAStates
  md$CBSAStates <- sapply(strsplit(md$CBSATitle, ", "), lastElement)
  md$CBSAStates <- sapply(md$CBSAStates, getStateNames)
  
  # CSAStates
  md$CSAStates <- sapply(strsplit(md$CSATitle, ", "), lastElement)
  md$CSAStates <- sapply(md$CSAStates, getStateNames)
  
  # Write table
  con <- conma()
  dbWriteTable(con, name="C_MetroDelineations_201302", value=md, overwrite=TRUE)
  dbDisconnect(con) 
}