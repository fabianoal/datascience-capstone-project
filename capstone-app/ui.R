library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("Word predictor app"),
  mainPanel(
    p("Just type a phrase, like you'd on twitter and we will try to help you!"),
    textInput("text", label = h3("Typing..")),
    textOutput1("textOutput1"),
    textOutput2('textOutput2'),
    textOutput3('textOutput3')
  )
))
