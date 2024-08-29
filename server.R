library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  exampleData1 <- read.csv("www/example/survival_example1.csv")
  exampleData2 <- read.csv("www/example/survival_example2.csv")
  
  output$downloadExampleFile1 <- downloadHandler(
    filename = function() {
      "example_file_1.txt"  # Name of the file when downloaded
    },
    content = function(file) {
      # Specify the path to the file in the www folder
      file.copy("www/example/survival_example1.csv", file)
    }
  )
  
  output$downloadExampleFile2 <- downloadHandler(
    filename = function() {
      "example_file_2.txt"  # Name of the file when downloaded
    },
    content = function(file) {
      # Specify the path to the file in the www folder
      file.copy("www/example/survival_example2.csv", file)
    }
  )
  
  # Reactive to update the selectInput choices based on selectedDataMode
  observeEvent(input$selectedDataMode, {
    if (input$selectedDataMode == "ex1") {
      updateSelectInput(session, "selectedGene", 
                        choices = c("sex", "TP53", "EGFR"),
                        selected = "sex")  # Set default selected value
      
      output$dataTable <- DT::renderDataTable({
        DT::datatable(
          data = exampleData1,
          options = list(
            pageLength = 20,
            autoWidth = FALSE
          )
        )
      })
      
    } else if (input$selectedDataMode == "ex2") {
      updateSelectInput(session, "selectedGene", 
                        choices = c("PIK3CA", "TP63", "BRCA1"),
                        selected = "PIK3CA")  # Set default selected value
      output$dataTable <- DT::renderDataTable({
        DT::datatable(
          data = exampleData2,
          options = list(
            pageLength = 20,
            autoWidth = FALSE
          )
        )
      })
    } else if (input$selectedDataMode == "ex3") {
      
      output$dataTable <- DT::renderDataTable({
        
        # render only if there is data available
        req(input_file())
        
        # reactives are only callable inside an reactive context like render
        data <- input_file()
        
        updateSelectInput(session, "selectedGene", 
                          choices = colnames(data),
                          selected = "filter1")
        
        
        #data <- subset(data, dateCreated >= input$period[1] & dateCreated <= input$period[2])
        DT::datatable(
          data = data,
          options = list(
            pageLength = 20,
            autoWidth = FALSE
          )
        )
      })
      
      
      
    }
    
    
    
  })
  
  input_file <- reactive({
    if (is.null(input$selectedFile)) {
      return("")
    }
    
    # actually read the file
    data <- read.csv(file = input$selectedFile$datapath, sep = input$selectedSeparator)
    colnames(data) <- gsub("\\.", "_", colnames(data))
    data
  })
  
  
  fit <- survfit(Surv(time, status) ~ sex,
                 data = exampleData1)
  
  output$survivalPlot <- renderPlot(
    #Visualize with survminer
    
    ggsurvplot(fit, data = exampleData1, risk.table = FALSE)
  )
  
  
}