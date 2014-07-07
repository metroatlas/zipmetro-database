# Create the ZipCodes table

P_ZipCodes_2010 <- function(d = TRUE) {
  
  # Download data
  if(d) {
    fileUrl <- "http://www.unitedstateszipcodes.org/zip_code_database.csv"
    download.file(fileUrl, destfile="data/zip_code_database.csv", method="curl")
    dateDownloaded <- date()
    write(dateDownloaded,file="data/zip_code_database.csv.date.txt")
  }
  
  # Open data
  zips  <- read.csv("data/zip_code_database.csv")
  
  # Upload data to database
  con <- conma()
  dbWriteTable(con, name="P_ZipCodes_2010", value=zips, overwrite=TRUE)
  dbDisconnect(con)
  
}

