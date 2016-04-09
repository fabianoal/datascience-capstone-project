#http://www.unt.edu/rss/class/Jon/R_SC/Module12/BasicTextMining.R
#txt <- VectorSource(text.d); rm(text.d)
#txt.corpus <- VCorpus(txt, readerControl = list(reader = readPlain,language = "en")); rm(txt)

#https://eight2late.wordpress.com/2015/05/27/a-gentle-introduction-to-text-mining-using-r/
#https://rstudio-pubs-static.s3.amazonaws.com/31867_8236987cf0a8444e962ccd2aec46d9c3.html

#For sampilng....
#https://stat.ethz.ch/R-manual/R-devel/library/base/html/sample.html

#"\Program Files\Microsoft\MRO\R-3.2.3\bin\Rscript" -e "parallel:::.slaveRSOCK()" MASTER=fabiano-pc PORT=11999 OUT=/dev/null TIMEOUT=2592000 METHODS=TRUE XDR=TRUE 

setwd("C:\\Users\\Fabiano\\Documents\\GitHub\\datascience-capstone-project\\data-processing")

#Libraries...
library(stringi)
#library(caret)
library(dplyr)
library(parallel)
library(reshape2)
library(quanteda)


prdMode = TRUE

source(paste(getwd(),"common.R", sep="/"))

translateToCodes <- function(tk){
  m_stop <- wordtable[stopwords()]
  printLog("Tokenizing...")
  tk <- tokenize(tk, removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE)
  printLog("Translating...")
  l <- length(wordtable)
  tk <- lapply(tk, function(x){
    ret.text <- removeNonWordsFromVector(x)
    ret <- wordtable[ret.text]
    # ret <- ret[!(ret %in% m_stop)]
    ret <- ret[!is.na(ret)]
    if (length(ret) > 1 && (length(ret.text) == length(ret)))
      return(ret)
    else
      return (NA)
  })
  return(tk[!is.na(tk)])
}

groupDataframe <- function(x, n){
  if (n == 4)
    return (group_by(x,T1, T2, T3, T4))
  else  
    if (n == 3)
      return (group_by(x, T1, T2, T3))
    else 
      if (n == 2)
        return (group_by(x, T1, T2))
      else
        return (group_by(x, T1))
}

listOfVectorsToNGramMatrix <- function(x, n){
  #x <- m[[2]]; n <- 4
  z <- lapply(x, function(x) nGramize(x, n))
  return(do.call(rbind, z[!is.na(z)]))
}

nGramize <- function(x, n){
  l <- length(x)
  x <- x[!is.na(x)]
  if (l < n){
    m <- NA
  }else if (l == n){
    m <- matrix(nrow=1, ncol = n, data = x)
    #m <- x
  }else{
    res <- vector(mode = "numeric")
    for (i in 1:(l - (n-1))) res <- append(res, x[i:(i+n-1)])
    m <- matrix(nrow= (length(x) - (n-1)), ncol = n, byrow=TRUE, data= res)
    #m <- res
  }
  return(m)
}

getFormula <- function(n){
  if (n == 4)
    return (T1 + T2 + T3 ~ pred_ranking)
  else  
    if (n == 3)
      return (T1 + T2 ~ pred_ranking)
  else 
    if (n == 2)
      return (T1 ~ pred_ranking)
}

createDf <- function(x){
  colnames(x) <- paste0("T",as.character(1:ncol(x)))  
  return(data.frame(lapply(data.frame(x), as.integer)))
}

#This function creates a "markov matrix" alike data frame
createMarkov <- function(x){
  l <- length(x)
  #Just to avoid a data frame with numbers as dbl...
  df <- groupDataframe(data.frame(lapply(data.frame(x), as.integer)), l) %>%
        summarise(freq = n()) %>%
        arrange(desc(freq)) %>%
        mutate(pred_ranking = row_number(desc(freq))) %>%
        filter(pred_ranking < 4) %>%
        select(-freq)
  if (nrow(df) > 0)
    df <- dcast(df, getFormula(l), value.var = paste0("T", as.character(l)))
  else
    df <- NULL
  return(df)
  #return(select(df, -c(ng)))
}



m <- list()
wordtable <- getObjFromFile(wordTableFileName())
peopleNames <- getObjFromFile(namesFileName())

clusterExport(c1, c("peopleNames", "wordtable", "splitVectorIntoChunks", "translateToCodes","groupDataframe","getFormula", "listOfVectorsToNGramMatrix", "nGramize", "createMarkov", "printLog", "removeNonWordsFromVector"))
clusterEvalQ(c1, {
  library(quanteda)
  library(dplyr)
  library(reshape2)
})

if (!(file.exists(paste(getwd(),cacheFolder,"1_Translated.RData", sep="/")) &&
    file.exists(paste(getwd(),cacheFolder,"2_Translated.RData", sep="/")) &&
    file.exists(paste(getwd(),cacheFolder,"3_Translated.RData", sep="/"))
    )){
      printLog("Init Translating...")
      numFile <- 1
      for (f in getListOfFiles(textFilesLocation)){
        #t <- readFile(paste0(getwd(),"/files/en_US.twitter.txt.sample.txt"))
        #t <- readFile(f)
        t <- sampleFile(f, 0.2)
        
        #Chunking: should return a list with character vectors
        printLog("Chunking...")
        t <- splitVectorIntoChunks(t, 32)
      
        printLog("Translating...")
        #Should return a list with vectors of codes. Each vector correspondes to a line of the chunk
        t <- parLapplyLB(c1, t, "translateToCodes")
        gc()
        clusterCall(c1, gc)
      
        saveObjToFile(tFileName(numFile), t)
        numFile <- numFile + 1
      }
      
      
      printLog("Cleaning up")
      rm(t)
      gc()
}


printLog("NGramizing...")
numFile <- 4
for (mNumber in 4:2){
  if (!(file.exists(nModelFileName(mNumber)))){
    #To save some memory...
    #mNumber <- 2
    megaMatrix <- lapply(1:(numFile-1), function(x){
      #x <- 3; nNumber <- 4
      printLog("Reading obj...")
      m <- getObjFromFile(tFileName(x))
      clusterExport(c1, c("mNumber"))
      printLog(paste0(as.character(mNumber),"-NGramizing..."))
      #m <- parLapplyLB(c1, m, function(l) Reduce(transformAndCompactDataFrame, l, init=NULL))
      m <- parLapplyLB(c1, m, function(x) listOfVectorsToNGramMatrix(x, mNumber))
      #sapply(m,ncol,simplify=TRUE)
      printLog("Rbinding...")
      return(do.call(rbind, m))
    })
  
    printLog("Last Rbinding")
    megaMatrix <- do.call(rbind,megaMatrix)
    gc()
    printLog("Creating DF")
    megaMatrix <- createDf(megaMatrix)
    gc()
    printLog("Splitting")
    megaMatrix <- split(megaMatrix, megaMatrix$T1)
    gc()
    printLog("Creating markov")
    megaMatrix <- parLapplyLB(c1, megaMatrix, createMarkov)
    printLog("Saving...")
    saveObjToFile(nModelFileName(mNumber), megaMatrix)
    rm(megaMatrix)
    gc()
    clusterCall(c1, gc)
  }
}







