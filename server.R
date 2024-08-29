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
      updateSelectInput(session, "selectedDependentVariableColumn", 
                        choices = c("status", "sex"), 
                        selected = "sex")
      updateSelectInput(session, "selectedStatusColumn", 
                        choices = c("status", "sex"), 
                        selected = "status")
      updateSelectInput(session, "selectedTimeColumn", 
                        choices = c("inst", "time", "status", "age", "sex", "ph_ecog", "ph_karno", "pat_karno"), 
                        selected = "time")
      return(exampleData1)
    } else if (input$selectedDataMode == "ex2") {
      updateSelectInput(session, "selectedDependentVariableColumn", 
                        choices = c("Tumor_stage", "Histology", "vital_status", "deceased", "mRNAsi_value", "mDNAsi_value"), 
                        selected = "Tumor_stage")
      updateSelectInput(session, "selectedStatusColumn", 
                        choices = c("vital_status", "deceased", "mRNAsi_value", "mDNAsi_value", "Stage"),
                        selected = "vital_status")
      updateSelectInput(session, "selectedTimeColumn", 
                        choices = c("age_at_diagnosis", "year_of_birth", "overall_survival"), 
                        selected = "overall_survival")
      return(exampleData2)
    } else if (input$selectedDataMode == "ex3") {
      req(input_file())
      updateSelectInput(session, "selectedDependentVariableColumn", choices = colnames(input_file()), selected = "filter1")
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
    
    # browser()
    
    duration <<- dataset()[[input$selectedTimeColumn]]
    status <<- dataset()[[input$selectedStatusColumn]]
    dependentVariable <<- dataset()[[input$selectedDependentVariableColumn]]
    
    
    # Check if the status column is numeric or logical
    if (is.numeric(status) || is.logical(status)) {
      # If it's logical, convert TRUE/FALSE to 1/0
      status <- as.numeric(status)
    } else {
      # If it's not numeric or logical, identify unique values and convert
      unique_values <- unique(status)
      
      # Map the first unique value to 0 (censored) and the second to 1 (event occurred)
      status <- ifelse(status == unique_values[1], 0, 1)
      
      message(status)
    }
    
    
    survfit(Surv(duration, status) ~ dependentVariable, data = dataset())
  })
  
  # Render the survival plot
  output$survivalPlot <- renderPlot({
    ggsurvplot(fit(), data = dataset())
  })
  
  
}