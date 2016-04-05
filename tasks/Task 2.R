#Referencias:

#http://www.unt.edu/rss/class/Jon/R_SC/Module12/BasicTextMining.R
#txt <- VectorSource(text.d); rm(text.d)
#txt.corpus <- VCorpus(txt, readerControl = list(reader = readPlain,language = "en")); rm(txt)

#https://eight2late.wordpress.com/2015/05/27/a-gentle-introduction-to-text-mining-using-r/
#https://rstudio-pubs-static.s3.amazonaws.com/31867_8236987cf0a8444e962ccd2aec46d9c3.html

#For sampilng....
#https://stat.ethz.ch/R-manual/R-devel/library/base/html/sample.html


#Loading libraries
library(tm)
library(slam)
#The % of texts to use as sample

sample_size <- 0.08
#First we create a vector containing 8% of the texts of each file

setwd("/Users/fabianoal/Documents/GitHub/Data Science Capstone Project")

cname <- paste0(getwd(),"/final/en_US")
files <- paste(cname, list.files(cname), sep="/")

corpusVector <- vector(mode = 'character')

for (j in files){
  f <- file(j)
  lines <- readLines(f)
  summary(lines)
  #print(paste0("nrow:",length(lines),", size:", trunc(length(lines)*0.2)))
  s <- sample(length(lines), size = trunc(length(lines)*sample_size), replace=FALSE)
  corpusVector <- append(corpusVector, lines[s])
  close(f)
}
remove(files, f, j, s, cname, sample_size, lines)

#With quatenda

install.packages("quatenda")
devtools::install_github("kbenoit/quanteda")
library(quanteda)
library(wordcloud)
library(stringi)
library(ggplot2)

length(corpusVector)
object.size(corpusVector)
str(corpusVector)

# profanities filtering (courtesy, seven words of George Carlin)
profanities_regex <- "(fuck|shit|piss|motherfuck|cocksuck)[^ $]*|cunt|dick"
corpusVector <- stri_replace_all_regex(corpusVector, profanities_regex, "", opts_regex=stri_opts_regex(case_insensitive=TRUE))

mCorpus <- quanteda::corpus(corpusVector)

summary(mCorpus)

unigrams <- dfm(mCorpus, removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE)

tfUnigrams <- topfeatures(unigrams, n = ncol(unigrams))
#We were left with 188k words.
tfUnigrams <- as.data.frame(tfUnigrams)
tfUnigrams$x <- 1:nrow(tfUnigrams)
head(tfUnigrams)
colnames(tfUnigrams) <- c("Frequency", "x")

gramsForCoverage <- function(grams, cName, thres){
  totalTerms <- sum(grams[,c(cName)])
  uniqueTerms <- 0
  for (j in 1:nrow(grams)){
    uniqueTerms <- uniqueTerms + 1
    if (sum(grams[1:uniqueTerms, c(cName)]) >= (total * thres)){
      break
    }
  }  
  uniqueTerms
}

gramsForCoverage(tfUnigrams, "Frequency", 0.75)

g <- ggplot(tfUnigrams[1:1000,], aes(x, Frequency))
g <- g + geom_line()
g <- g + geom_vline(aes(xintercept = gramsForCoverage(tfUnigrams, "Frequency", 0.5)))
g <- g + xlab("Terms")
g


bigrams <- dfm(mCorpus, ngrams=2)
tfBigrams <- topfeatures(bigrams, n=ncol(bigrams))
tfBigrams <- as.data.frame(tfBigrams)
tfBigrams$x <- 1:nrow(tfBigrams)
colnames(tfBigrams) <- c("Frequency", "x")

topfeatures(bigrams, n=15)

gramsForCoverage(tfBigrams, "Frequency", 0.50)

tfTrigrams <- dfm(mCorpus, ngrams=3)
top200 <- as.data.frame(topfeatures(unigrams, n=200))
colnames(top200) <- c("freq")
wordcloud(words = rownames(top200), freq=top200$freq)



createNgram <- function(sentense){
  s <- tokenize(sentense, removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, ngrams = 1, simplify = TRUE)
  paste(s[(length(s)-2):length(s)], sep="_")
}

createNgram
