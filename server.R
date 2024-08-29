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
  
  # Reactive to determine the selected dataset
  dataset <- reactive({
    if (input$selectedDataMode == "ex1") {
      updateSelectInput(session, "selectedGene", choices = c("sex", "TP53", "EGFR"), selected = "sex")
      return(exampleData1)
    } else if (input$selectedDataMode == "ex2") {
      updateSelectInput(session, "selectedGene", choices = c("PIK3CA", "TP63", "BRCA1"), selected = "PIK3CA")
      return(exampleData2)
    } else if (input$selectedDataMode == "ex3") {
      req(input_file())
      updateSelectInput(session, "selectedGene", choices = colnames(input_file()), selected = "filter1")
      return(input_file())
    }
  })
  
  # Rendering the dataTable
  output$dataTable <- DT::renderDataTable({
    DT::datatable(
      data = dataset(),
      options = list(pageLength = 20, autoWidth = FALSE)
    )
  })
  
  input_file <- reactive({
    if (is.null(input$selectedFile)) {
      return(NULL)
    }

    # actually read the file
    data <- read.csv(file = input$selectedFile$datapath, sep = input$selectedSeparator)
    colnames(data) <- gsub("\\.", "_", colnames(data))
    data
  })
  

  fit <- reactive({
    
    duration <<- dataset()[[input$selectedDurationColumn]]
    outcome <<- dataset()[[input$selectedOutcomeColumn]]
    gene <<- dataset()[[input$selectedGene]]
    
    survfit(Surv(duration, outcome) ~ gene, data = dataset())
  })
  
  # Render the survival plot
  output$survivalPlot <- renderPlot({
    ggsurvplot(fit(), data = dataset())
  })
  
  
}