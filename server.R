library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  output$distPlot <- renderPlot({
    hist(rnorm(5))
  })
  
}