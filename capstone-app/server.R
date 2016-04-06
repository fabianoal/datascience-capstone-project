library(shiny)
library(ggplot2)

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

shinyServer(

  function(input, output) {
    dopred <- reactive({
      predict(
        slm1, 
        newdata = getdf()
      )      
    })
    output$distPlot <- renderPlot({
      
      qplot(wt, mpg, data=mtcars, colour=am, size=qsec) + 
        geom_hline(yintercept = dopred()) +
        geom_vline(xintercept = as.numeric(input$wt)) +
        xlab("Wheight") +
        ylab("Miles per galon")
        #geom_dotplot(binwidth="y", aes(y = mpg_p, x = wt_p), data = data.frame("mpg" = dopred(), "wt" = as.numeric(input$wt)))
    })

    output$textOutput1 <- renderText({
      paste("The predicted mpg is ", sprintf("%.2f",dopred()), ' for the following informed values:')
    })
    
    output$textOutput2 <- renderText({
      paste("The predicted mpg is ", sprintf("%.2f",dopred()), ' for the following informed values:')
    })
    
    output$textOutput3 <- renderText({
      paste("The predicted mpg is ", sprintf("%.2f",dopred()), ' for the following informed values:')
    })
  }
)

