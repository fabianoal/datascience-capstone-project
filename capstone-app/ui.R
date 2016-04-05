library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("Car fuel consumption predictor"),
  sidebarPanel(
    p('This application uses a simple linear model to predict fuel consumption for cars using tree user informed parameters: weight (lb/1000), 1/4 mile time and transmission type.'),
    
    selectInput("am", label = h3("Transmission Type"), 
                choices = list("Automatic" = 0, "Manual" = 1), selected = 0),
    
    sliderInput("qsec", label = h3("1/4 mile time"),
                min = 10, max = 30, value = 15),
    
    sliderInput("wt", label = h3("Weight (lb/1000)"),
                min = 1, max = 7, value = 3),
    p('Instructions:'),
    p('Just play with the sliders and the combo to set new values for transmission, 1/4 mile time and weight.')
  ),
  mainPanel(
    p('Plot showing the relationshipe between weight, 1/4 mile time and transmission type with miles/galon'),
    plotOutput("distPlot"),
    textOutput('textMpg'),
    textOutput('valores')
  )
))
