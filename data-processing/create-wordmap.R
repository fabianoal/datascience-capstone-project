#http://www.unt.edu/rss/class/Jon/R_SC/Module12/BasicTextMining.R
#txt <- VectorSource(text.d); rm(text.d)
#txt.corpus <- VCorpus(txt, readerControl = list(reader = readPlain,language = "en")); rm(txt)

#https://eight2late.wordpress.com/2015/05/27/a-gentle-introduction-to-text-mining-using-r/
#https://rstudio-pubs-static.s3.amazonaws.com/31867_8236987cf0a8444e962ccd2aec46d9c3.html

#For sampilng....
#https://stat.ethz.ch/R-manual/R-devel/library/base/html/sample.html

#Libraries...
library(stringi)
library(dplyr)
library(parallel)

prdMode = TRUE

#setwd("/Users/fabianoal/Documents/GitHub/Data Science Capstone Project")
#setwd("C:\\Users\\fabianoal\\Documents\\Cursos\\Coursera\\Capstone Project")
setwd("C:\\Users\\Fabiano\\Documents\\GitHub\\datascience-capstone-project\\data-processing")
set.seed(3546)

source(paste(getwd(),"common.R", sep="/"))

tokenizeAndProcess <- function(lines){
  tok <- tokenize(lines, removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, simplify = TRUE)
  tok <- removeNonWordsFromVector(tok)
  tok <- data.frame(feature = tok, stringsAsFactors = FALSE)
  tok <- group_by(tok, feature) %>% summarise(freq = n()) %>% mutate(firstChar = substr(feature,1,1))
  return(tok)
}

groupTexts <- function(tokens1, tokens2){
  if (!is.null(tokens1))
    tok <- dplyr::bind_rows(tokens1, tokens2)
  else
    tok <- tokens2
  
  tok <- group_by(tok, firstChar, feature) %>%
         summarise(freq2 = sum(freq)) %>%
         select(firstChar, feature, freq = freq2)
  return (tok)
}

printLog("Creating cluster")
# We're going to assume that the cluster is already in place.
# To setup the cluster, use the manipulate_cluster.R

peopleNames <- compileListNames()
  
clusterExport(c1, c("peopleNames", "splitVectorIntoChunks","tokenizeAndProcess", "removeNonWordsFromVector"))
clusterEvalQ(c1, {
  library(quanteda)
  library(dplyr)
})

worddf <- NULL

for (f in getListOfFiles(textFilesLocation)){
  #t <- readFile(paste0(getwd(),"/files/en_US.twitter.txt"))
  t <- readFile(f)

  #Chunking: should return a list with character vectors
  printLog("Chunking...")
  t <- splitVectorIntoChunks(t, 32)

  printLog("Tokenizing...")
  #Tokenizing: should return a list of tokenized objects (same size as the previous step)
  t <- parLapplyLB(c1, t, "tokenizeAndProcess")
  gc()
  
  printLog("Reducing")
  t <- Reduce(groupTexts, t)
  
  printLog("Consolidating")
  worddf <- groupTexts(worddf, t)
}

#temp <- c("i'm","fucking","23th", "sandler's","aas","1st")
#sub(".*\\'s","'s", temp)
#sub("\\d+th","*th", temp)
#sub("\\d+st","*st", temp)

wordsTotalthreshold <- sum(worddf$freq) * 0.95

worddf <- ungroup(worddf)
worddf <- arrange(worddf, desc(freq)) %>%
          mutate(cumulativeSum = cumsum(freq)) %>%
          filter(cumulativeSum < wordsTotalthreshold) %>%
          select(firstChar, feature)

printLog("Creating final vector")
wordtable <- 1:nrow(worddf)

names(wordtable) <- worddf$feature

printLog("Saving wordtable")
saveObjToFile(wordTableFileName(), wordtable)
saveObjToFile(stopWordsFileName(), stopwords())
gc()
