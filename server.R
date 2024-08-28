library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  input_file <- reactive({
    if (is.null(input$selectedFile)) {
      return("")
    }
    
    # actually read the file
    read.csv(file = input$selectedFile$datapath, sep = input$selectedSeparator, header = input$selectedHeader)
  })
  
  output$dataTable <- DT::renderDataTable({
    
    # render only if there is data available
    req(input_file())
    
    # reactives are only callable inside an reactive context like render
    data <- input_file()
    #data <- subset(data, dateCreated >= input$period[1] & dateCreated <= input$period[2])
    DT::datatable(
      data = data,
      options = list(
        pageLength = 20
      )
    )
  })
  
}