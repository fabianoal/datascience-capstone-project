#Reference: https://rstudio-pubs-static.s3.amazonaws.com/31867_8236987cf0a8444e962ccd2aec46d9c3.html

install.packages(c("tm","wordcloud"))
setwd("/Users/fabianoal/Documents/GitHub/Data Science Capstone Project")

cname <- paste0(getwd(),"/final/en_US")

library(tm)
docs <- Corpus(DirSource(cname))
summary(docs)
help(Corpus)
info(docs[[1]])[1:7]
summary(docs)
meta(docs[[1]])
help(tm)

f <- file(paste(cname,"en_US.twitter.txt", sep="/"))
library("R.utils")
countLines(paste(cname,"en_US.twitter.txt", sep="/"))

summary(f)

sapply(paste(cname, list.files(cname), sep="/"), biggestLine)

remove(docs)



biggestLine = function(filepath) {
  print(paste0("Lendo arquivo ", filepath))
  con = file(filepath, "r")
  lineLength <- 0
  countLines <- 0
  while ( TRUE ) {
    line = readLines(con, n = 1)
    if ( length(line) == 0 ) {
    #if (countLines > 10){
      break
    }
    countLines <- countLines +1
    if (nchar(line) > lineLength) {
      #print(paste0("Maior linha: ", as.character(nchar(line))))
      lineLength <- nchar(line)
    }
  }
  close(con)
  print(paste0("Count Lines: ", countLines))
  print(paste0("Largest Line: ", lineLength))
}




f <- file(paste(cname,"en_US.twitter.txt", sep="/"))

lines <- readLines(f)


vectorLove <- grep("love", lines, value=FALSE)
vectorHate <- grep("hate", lines, value=FALSE)
length(vectorLove)/length(vectorHate)
length(vectorHate)
grep("biostats", lines, value=TRUE)
grep("^A computer once beat me at chess, but it was no match for me at kickboxing$", lines, value=FALSE)
