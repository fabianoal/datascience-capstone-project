#http://www.unt.edu/rss/class/Jon/R_SC/Module12/BasicTextMining.R
#txt <- VectorSource(text.d); rm(text.d)
#txt.corpus <- VCorpus(txt, readerControl = list(reader = readPlain,language = "en")); rm(txt)

#https://eight2late.wordpress.com/2015/05/27/a-gentle-introduction-to-text-mining-using-r/
#https://rstudio-pubs-static.s3.amazonaws.com/31867_8236987cf0a8444e962ccd2aec46d9c3.html

#For sampilng....
#https://stat.ethz.ch/R-manual/R-devel/library/base/html/sample.html

#Libraries...
library(dplyr)


#setwd("/Users/fabianoal/Documents/GitHub/Data Science Capstone Project")
#setwd("C:\\Users\\fabianoal\\Documents\\Cursos\\Coursera\\Capstone Project")
setwd("C:\\Users\\Fabiano\\Documents\\Coursera\\Capstone Project")

source(paste(getwd(),"common.R", sep="/"))

model <- list(
  "4" = getObjFromFile(nModelFileName(4)),
  "3" = getObjFromFile(nModelFileName(3)),
  "2" = getObjFromFile(nModelFileName(2))
)
peopleNames <- compileListNames()
wordtable <- getObjFromFile(paste(getwd(),cacheFolder,"wordvector.RData", sep="/"))

#Stupid back-off implementation
stupidBackoffPredict <- function(sentence, results){
  #print(paste0(" -> predicting for ", sentence))
  #sentence <- prepareQuery("I'm not worried about"); results <- vector(mode="integer")
  #printLog(sentence)
  selected_model <- model[[as.character(length(sentence) + 1)]]
  selected_interval <- selected_model[[as.character(sentence[1])]]
  
  if(length(sentence)==3)
    selected_row <- filter(selected_interval, T2 == sentence[2] && T3 == sentence[3]) %>% select(-T1, -T2, -T3)
  else if (length(sentence) ==2)
      selected_row <- filter(selected_interval, T2 == sentence[2]) %>% select(-T1, -T2)
    else
        selected_row <- select(selected_interval, -T1)
  
  mvec <- append(results, base::setdiff(unlist(selected_row),results))
  #mvec <- append(results, na.exclude(as.character(selected_model[sentence, -c(1)])))

  if (length(mvec) < 4 && length(sentence) > 1){
    return(stupidBackoffPredict(sentence[2:length(sentence)], mvec))
  }else{
    return(mvec)
  }
}

s <- " inch away from me but you hadn't time to take a"
convertResult(stupidBackoffPredict(prepareQuery(s), vector(mode="integer")))

wordtable[(model[["4"]][[as.character(wordtable["milk"])]] %>% filter(T2 == wordtable["and"]))$T3]

wordtable[c(5,   18, 1715,    1)]
peopleNames
#Testing the model.

#Function to prepare the data
prepareTestData <- function(m_corpus, ngrams){
  tokenizedText <- tokenize(m_corpus, removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, ngrams = ngrams, simplify = TRUE)
  data.frame(ng = sub(ngramregex,"",tf), pred = sub(predregex,"",tf), stringsAsFactors = FALSE) %>%
    distinct()
}
prepareQuery2("When you were in Holland you were like 1 inch away from me but you hadn't time to take a")
prepareQuery2 <- function(sentence){
  sentence <- stri_trans_tolower(sentence)
  s <- tokenize(sentence, removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, ngrams = 1, simplify = TRUE)
  s <- removeNonWordsFromVector(s)
  s <- s[!(s %in% stopwords())]
  s <- s[!is.na(s)]
  return(s)  
}
prepareQuery <- function(sentence){
  sentence <- stri_trans_tolower(sentence)
  s <- tokenize(sentence, removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, ngrams = 1, simplify = TRUE)
  s <- removeNonWordsFromVector(s)
  s <- wordtable[s]
  s <- s[!(s %in% stopwords())]
  s <- s[!is.na(s)]
  s <- s[!is.na(s)]
  s <- if (length(s) > 3) s[(length(s)-2):length(s)] else s
  return(s)
}

convertResult <- function(result){
  return(names(wordtable[result]))
}



#Function to test the data
doTest <- function(df, model){
  mcount <- 0
  for (i in 1:nrow(df)){
    if (df[i, c('pred')][[1]] %in% stupidBackoffPredict(model, df[i, c('ng')][[1]] , vector(mode="character"))[1:3]) 
      mcount <- mcount + 1
  }
  mcount
}

#Sample size for testing...
number_of_samples <- 200

testResults <- matrix(ncol=2, nrow=3)
rownames(testResults) <- as.character(c(4,3,2))

for (i in c(4,3,2)){
  print(paste0(" t: Getting data for testing grams of size [", as.character(i), "]"))
  dfTest <- prepareTestData(mCorpusTesting, i)
  dfTest <- dfTest[sample(nrow(dfTest), number_of_samples), ]
  print(" t: Performing testings...")
  numberGotIt <- doTest(dfTest, model)
  testResults[as.character(i), 1] <- numberGotIt
  testResults[as.character(i), 2] <- nrow(dfTest)
  print(paste0(" t: Got: ", as.character(numberGotIt), " out of ", nrow(dfTest), ". [", format((numberGotIt/nrow(dfTest)) * 100, digts=2), "%]."))
}

tbl_df(as.data.frame(testResults))

dfTest <- prepareTestData(mCorpusTesting, 4)
dfTest <- dfTest[sample(nrow(dfTest), number_of_samples), ]
resultados <- sapply(dfTest$ng, function(x) {stupidBackoffPredict(model, x, vector(mode="character"))[1:3]})
stupidBackoffPredict(model, createNgram("you must be"), vector(mode="character"))

createNgram("you must be")
s <- tokenize(c("you must be"), removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, ngrams = 1, simplify = TRUE)
s
paste(strwrap(s[(length(s)-2):length(s)]), sep="_")
help(paste)
f <- file("./model2.RData")
save(model, file=f)
close(f)




#"\Program Files\Microsoft\MRO\R-3.2.3\bin\Rscript.exe" -e "parallel:::.slaveRSOCK()" MASTER=localhost PORT=11999 OUT=/dev/null TIMEOUT=2592000 METHODS=TRUE XDR=TRUE




t <- vector(mode="character")
for (f in getListOfFiles(textFilesLocation)){
  #t <- readFile(paste0(getwd(),"/files/en_US.twitter.txt"))
  t <- append(t, readFile(f))
}

c1 <- initCl(TRUE)

t <- splitVectorIntoChunks(t, 32)

temp <- parSapplyLB(c1, t, function(x){
    grep("groceries", x, value = TRUE)
})
temp

destroyCl(c1)
