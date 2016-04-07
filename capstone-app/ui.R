library(shiny)
shinyUI(bootstrapPage(
  fluidPage(
    fluidRow(
      p("Just type a phrase, like you'd on twitter and we will try to help you!")
    ),
    fluidRow(
      textInput("sentence", label = h3("Typing.."))
    ),
    fluidRow(
      # Only show this panel if Custom is selected
      conditionalPanel(
        "results",
        condition = "input.sentence != ''",
        tags$ul(
          htmlOutput("prediction", container = tags$li, class = "custom-li-output")
        )
      )
    )
      #tableOutput("prediction")
  )
))

