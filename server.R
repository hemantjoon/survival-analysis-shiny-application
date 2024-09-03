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
  
  autoChoices <- function(data){
    timeChoices <- colnames(data)[sapply(data, function(col) is.numeric(col) )]
    statusChoices <- colnames(data)[sapply(data, function(col) (length(unique(col)) == 2 && is.logical(col)) || (length(unique(col)) == 2 && is.numeric(col)) )]
    dependentVariableChoices <- colnames(data)[sapply(data, function(col) length(unique(col)) == 2)]
    
    updateSelectInput(session, "selectedTimeColumn", choices = timeChoices)
    updateSelectInput(session, "selectedStatusColumn", choices = statusChoices)
    updateSelectInput(session, "selectedDependentVariableColumn", choices = dependentVariableChoices)
  }
  
  # Reactive to determine the selected dataset
  dataset <- reactive({
    if (input$selectedDataMode == "ex1") {
      autoChoices(exampleData1)
      updateSelectInput(session, "selectedTimeColumn", selected = "time")
      updateSelectInput(session, "selectedStatusColumn", selected = "status")
      updateSelectInput(session, "selectedDependentVariableColumn", selected = "sex")
      return(exampleData1)
    } else if (input$selectedDataMode == "ex2") {
      autoChoices(exampleData2)
      return(exampleData2)
    } else if (input$selectedDataMode == "ex3") {
      req(input_file())
      data <- input_file()
      
      autoChoices(data)
      
      return(data)
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
      status <<- ifelse(status == unique_values[1], 0, 1)
      
    }
      
    survfit(Surv(duration, status) ~ dependentVariable, data = dataset())
  })
  
  # Render the survival plot
  output$survivalPlot <- renderPlotly({
    ggplot_surv <- ggsurvplot(fit(), data = dataset(),
                              size = input$crLineWidth,
                              linetype = input$crLineType,
                              censor.shape = input$crCensorShape,
                              censor.size = input$crCensorWidth,
                              conf.int = input$crCIBoolean,
                              conf.int.style = "step",
                              surv.median.line = input$crMedianLineType,
                              break.y.by = input$crYAxisStepSize,
                              pval = if (input$crPValueBoolean == "TRUE") TRUE else FALSE,
                              palette = c(input$crAxisXColor, input$crAxisYColor),
                              xlab = if (nchar(input$crXTitle) != 0) input$crXTitle else "Time",
                              ylab = if (nchar(input$crYTitle) != 0) input$crYTitle else "Survival Probability",
                              legend.title= if (nchar(input$crLegendTitle) != 0) input$crLegendTitle,
                              legend.labs = c(
                                              if(nchar(input$crLegendTitle1) != 0) input$crLegendTitle1, 
                                              if(nchar(input$crLegendTitle2) != 0) input$crLegendTitle2
                                              ),
                              ggtheme = theme(panel.background = element_rect(fill = input$crBgColor),
                                              panel.grid = element_line(colour = input$crGridColor, linetype = input$crGridType, linewidth = input$crGridSize), 
                              ),
                              )
    ggplot_surv$plot
  })
  
  
}