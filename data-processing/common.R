ngramregex <- "_[^_]*?$"
predregex  <- "^.*_"


#textFilesLocation <- "/final/en_US"
textFilesLocation <- "/files"
cacheFolder <- "/cache/"
library()
printLog <- function(message){
  print(paste(format(Sys.time(), "%a %b %d %X %Y"), message, sep = " - "))
}

compileListNames <- function(){
  if(file.exists(namesFileName())){
    names <- getObjFromFile(namesFileName())
  }else{
    names <- vector(mode="character")
    surnames <- c("http://names.mongabay.com/most_common_surnames.htm",
                  "http://names.mongabay.com/most_common_surnames1.htm",
                  "http://names.mongabay.com/most_common_surnames2.htm",
                  "http://names.mongabay.com/most_common_surnames5.htm")
    names <- (unique(unlist(sapply(surnames, function(url){
                      printLog(paste0("Getting names from ", url))
                      return(tolower(as.character(readHTMLTable(url)[[1]]$Surname)))
                    }, simplify = "array"))))
  
    givennames <- c("http://www.baby2see.com/names/1960s.html",
                    "http://www.baby2see.com/names/1970s.html",
                    "http://www.baby2see.com/names/1980s.html",
                    "http://www.baby2see.com/names/1990s.html",
                    "http://www.baby2see.com/names/2000s.html")
  
    names2 <- (unique(unlist(sapply(givennames, function(url){
                printLog(paste0("Getting names from ", url))
                t <- readHTMLTable(url)[[4]]
                v <- tolower(append(as.character(t$V2), as.character(t$V3)))
              }, simplify = "array"))))
    names <- (unique(append(names,names2)))
    saveObjToFile(namesFileName(), names)
  }
  return(names)
}


#Function to get a sample from the files
readFile <- function(fileName){
  printLog(paste0("Reading file ", fileName))
  f <- file(fileName, open="r")
  lines <- (readLines(f))
  close(f)
  return(lines)
}

sampleFile <- function(fileName, samplePerc){
  lines <- readFile(fileName);
  return(sample(lines, length(lines) * samplePerc))
}

getObjFromFile <- function(fileName){
  printLog(paste0("Getting object from file ", fileName))
  f <- file(fileName, open="rb")
  inObj <- readRDS(f)
  close(f)
  return(inObj)
}

saveObjToFile <- function(fileName, outObj){
  printLog(paste0("Saving object to file ", fileName))
  f <- file(fileName, open="wb")
  saveRDS(outObj, file=f)
  close(f)
}

getListOfFiles <- function(filesLocation){
  cname <- paste0(getwd(),filesLocation)
  return(paste(cname, grep("sample",list.files(cname), value=TRUE, invert=prdMode), sep="/"))
}

#Functions to use in parallel
splitVectorIntoChunks <- function(lines, chunks){
  l <- length(lines)/(chunks) #making the chunks smallers for improving memory management
  return(split(lines, ceiling(seq_along(lines)/l)))
}

removeNonWordsFromVector <- function(tok){
  #tok <- c("i'll", "be", "there", "for", "you", "River", "live", "John", "river")
  tok <- grep("[^a-z\']", tok, value=TRUE, invert = TRUE, ignore.case = TRUE)
  tok <- grep("([a-z])\\1{2}", tok, value=TRUE, invert = TRUE, ignore.case = TRUE)  
  tok <- grep("(fuck|shit|piss|motherfuck|cocksuck)[^$]*|cunt|dick", tok, value=TRUE, invert = TRUE, ignore.case = TRUE)  
  tok <- sub(".*\\'s","*'s", tok, ignore.case = TRUE)
  tok <- sub("\\d+th","*th", tok, ignore.case = TRUE)
  tok <- sub("\\d+st","*st", tok, ignore.case = TRUE)
  t <- tolower(tok) %in% peopleNames
  t2 <- grepl("[A-Z]", tok, ignore.case = FALSE)
  tok <- sapply(1:length(tok), function(i) ifelse(t[i] == TRUE && t2[i] == TRUE, "*name", tok[i]), simplify="array")
  return(tolower(tok))
}

removeNonCharacter <- function(tk){
  tk <- lapply(tk, removeNonWordsFromVector)
  return(tk)
}

nGramFileName <- function(n){
  return (paste(getwd(),cacheFolder, paste0(as.character(n),"NGram_df.RData"), sep="/"))
}

nModelFileName <- function(n){
  return (paste(getwd(),cacheFolder, paste0(as.character(n),"NModel_df.RData"), sep="/"))
}

tFileName <- function(n){
  return (paste(getwd(),cacheFolder, paste0(as.character(n),"_Translated.RData"), sep="/"))
}

namesFileName <- function(){
  return (paste(getwd(),cacheFolder, "Names.RData", sep="/"))
}


initCl <- function(prdMode){
  printLog("Creating cluster")
  if (prdMode){
    c1 <- makePSOCKcluster(names=c("fabiano-pc","fabiano-pc","macbook","macbook","macbook", "macbook", "fabiano-laptop", "fabiano-laptop","fabiano-laptop", "fabiano-laptop"), master="fabiano-pc", port=11999, homogeneous=FALSE, manual=TRUE)
  }else{
    c1 <- makeCluster(detectCores()-1)
  }
  return(c1)
}


destroyCl <- function(clId){
  stopCluster(clId)
}

