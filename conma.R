# Get the connector for the zipmetro database
conma <- function() {
  
  library(RMySQL)
  con <- dbConnect("MySQL",
                   user='root',
                   password='root',
                   dbname='zipmetro', 
                   host='localhost')
  dbGetQuery(con, "SET NAMES utf8")
  return(con)
  
}