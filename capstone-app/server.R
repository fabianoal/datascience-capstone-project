library(shiny)
library(dplyr)

model <- list(
  "4" = readRDS('data/4NModel_df.RData'),
  "3" = readRDS('data/3NModel_df.RData'),
  "2" = readRDS('data/2NModel_df.RData')
)

wordtable <- readRDS('data/wordvector.RData')
peopleNames <- readRDS('data/Names.RData')
stopwords <- readRDS('data/stopwords.RData')

removeNonWordsFromVector <- function(tok){
  #tok <- c("i'll", "be", "there", "for", "you", "River", "live", "John", "river")
  tok <- grep("[^a-z\']", tok, value=TRUE, invert = TRUE, ignore.case = TRUE)
  #tok <- grep("([a-z])\\1{2}", tok, value=TRUE, invert = TRUE, ignore.case = TRUE)  
  tok <- sub(".*\\'s","*'s", tok, ignore.case = TRUE)
  tok <- sub("\\d+th","*th", tok, ignore.case = TRUE)
  tok <- sub("\\d+st","*st", tok, ignore.case = TRUE)
  t <- tolower(tok) %in% peopleNames
  t2 <- grepl("[A-Z]", tok, ignore.case = FALSE)
  tok <- sapply(1:length(tok), function(i) ifelse(t[i] == TRUE && t2[i] == TRUE, "*name", tok[i]), simplify="array")
  return(tolower(tok))
}

#Stupid back-off implementation
stupidBackoffPredict <- function(sentence, results = vector(mode = "numeric")){
  #print(paste0(" -> predicting for ", sentence))
  #sentence <- prepareQuery("I'm not worried about"); results <- vector(mode="integer")
  #printLog(sentence)
  if (!is.null(sentence) && length(sentence) > 0){
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
}

prepareQuery <- function(sentence){
  #sentence <- "I'm not sure this thing is going to work"
  s <- strsplit(sentence, "[^a-zA-Z\']")[[1]]
  s <- removeNonWordsFromVector(s)
  s <- wordtable[s]
  s <- s[!is.na(s)]
  s <- if (length(s) > 3) s[(length(s)-2):length(s)] else s
  return(s)
}

convertResult <- function(result){
  #return(data.frame("options" = names(wordtable[result])))
  return(names(wordtable[result]))
}

shinyServer(
  function(input, output) {
    output$prediction <- renderUI({
      #paste(input$sentence, convertResult(stupidBackoffPredict(prepareQuery(input$sentence))), sep = " ")
      convertResult(stupidBackoffPredict(prepareQuery(input$sentence)))
    })
  }
)

