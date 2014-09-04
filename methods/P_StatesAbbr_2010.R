# Create the States Abbreviations table

P_StatesAbbr_2010 <- function(d = TRUE) {
  
  # Download data
  if(d) {
    fileUrl <- "https://raw.githubusercontent.com/chris-taylor/USElection/master/data/state-abbreviations.csv"
    download.file(fileUrl, destfile="data/states_abbreviations.csv", method="curl")
    dateDownloaded <- date()
    write(dateDownloaded,file="data/states_abbreviations.csv.date.txt")
  }
  
  # Open data
  states  <- read.csv("data/states_abbreviations.csv", header = FALSE)
  names(states) <- c("StateName", "StateAbbr")
  
  # Upload data to database
  con <- conma()
  dbWriteTable(con, name="P_StatesAbbr_2010", value=states, overwrite=TRUE)
  dbDisconnect(con)
  
}

