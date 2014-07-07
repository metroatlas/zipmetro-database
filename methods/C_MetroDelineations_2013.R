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
  
  # CBSACentralCity
  firstElement <- function(x){x[1]}
  md$CBSACentralCity <- sapply(strsplit(md$CBSATitle,"[-,]"), firstElement)
  
  # CSACentralCity
  md$CSACentralCity <- sapply(strsplit(md$CSATitle,"[-,]"), firstElement)
  
  # Write table
  con <- conma()
  dbWriteTable(con, name="C_MetroDelineations_201302", value=md, overwrite=TRUE)
  dbDisconnect(con) 
}