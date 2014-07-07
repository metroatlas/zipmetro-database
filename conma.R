# Get the connector for the zipmetro database
conma <- function() {
  library(RMySQL)
  con <- dbConnect("MySQL",
                   user='root',
                   password='root',
                   dbname='zipmetro', 
                   host='localhost',
                   unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")
  dbGetQuery(con, "SET NAMES utf8")
  return(con)
}