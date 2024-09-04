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
  
  # observe({
  #   if (input$tabset == "Help") {
  #     hide("sidebar")  # Hide the sidebar when "Help" is selected
  #     runjs('$(".col-sm-8").removeClass("col-sm-8").addClass("col-sm-12");')  # Expand the main panel
  #   } else {
  #     show("sidebar")  # Show the sidebar for other tabs
  #     runjs('$(".col-sm-12").removeClass("col-sm-12").addClass("col-sm-8");')  # Reset the main panel width
  #   }
  # })
  
  autoChoices <- function(data){
    timeChoices <- colnames(data)[sapply(data, function(col) is.numeric(col) )]
    statusChoices <- colnames(data)[sapply(data, function(col) length(unique(col)) == 2)]
    dependentVariableChoices <- colnames(data)[sapply(data, function(col) length(unique(col)) == 2)]
    
    updateSelectInput(session, "selectedTimeColumn", choices = timeChoices)
    updateSelectInput(session, "selectedStatusColumn", choices = statusChoices)
    updateSelectInput(session, "selectedDependentVariableColumn", choices = dependentVariableChoices)
    
    updateRadioButtons(session, "selectedDependentVariableType", selected = "bool")
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
  
  # Toggle
  observe({
    toggleState(id = "crGridSize", condition = input$crGridBoolean == "TRUE")
    toggleState(id = "crGridColor", condition = input$crGridBoolean == "TRUE")
    toggleState(id = "crPvaluePosition", condition = input$crPValueBoolean == "TRUE")
    toggleState(id = "crPvalueSize", condition = input$crPValueBoolean == "TRUE")
    toggleState(id = "crPvalueColor", condition = input$crPValueBoolean == "TRUE")
    toggleState(id = "crTruncateXCoordinate", condition = input$crTruncateXBoolean == "TRUE")
  })
  
  # Observe Time Column
  observeEvent(input$selectedTimeColumn,{
    req(max(dataset()[[input$selectedTimeColumn]], na.rm = T))
    
    TimeMax <- max(dataset()[[input$selectedTimeColumn]], na.rm = T)
    TimeMin <- min(dataset()[[input$selectedTimeColumn]], na.rm = T)
    
    XAxisStepSize <- 10
    
    if(TimeMax >= 1000){
      XAxisStepSize = ceiling(TimeMax/(5*100))*100
    }
    else if(TimeMax >= 100){
      XAxisStepSize = ceiling(TimeMax/(5*10))*10
    }
    else if(TimeMax >= 1){
      XAxisStepSize = ceiling(TimeMax/5)
    }
    else{
      XAxisStepSize = TimeMax/5
    }
    updateNumericInput(session, "crXAxisStepSize", min = TimeMin, max = TimeMax, value = XAxisStepSize)
    
    TruncateXCoordinate <- 10
    if(TimeMax >= 1000){
      TruncateXCoordinate = ceiling(TimeMax/(2*100))*100
    }
    else if(TimeMax >= 100){
      TruncateXCoordinate = ceiling(TimeMax/(2*10))*10
    }
    else if(TimeMax >= 1){
      TruncateXCoordinate = ceiling(TimeMax/2)
    }
    else{
      TruncateXCoordinate = TimeMax/2
    }
    updateNumericInput(session, "crTruncateXCoordinate", min = TimeMin, max = TimeMax, value = TruncateXCoordinate)
    
    PValXCoordinateMax <<- TimeMax
  })
  
  # Observe Status Column
  observeEvent(input$selectedStatusColumn,{
    unique_values <- dataset()[[input$selectedStatusColumn]]
    updateSelectInput(session, "selectCensoredLabel", choices = unique_values)
  })
  
  # Observe Dependent Variable Type
  observeEvent(input$selectedDependentVariableType,{
    if(input$selectedDependentVariableType == "bool"){
      updateSelectInput(session, "selectedDependentVariableColumn", 
                        choices = colnames(dataset())[sapply(dataset(), function(col) length(unique(col)) == 2)])
    }
    else{
      updateSelectInput(session, "selectedDependentVariableColumn", 
                        choices = colnames(dataset())[sapply(dataset(), function(col) {is.numeric(col) & sum(is.na(col)) == 0 } )])
    }
  })
  
  
  pValueCoordinates <- reactive({

    if(input$crPvaluePosition== 'bottom-center'){
      PValYCoordinate <- 0.1
      PValXCoordinate <- ceiling(PValXCoordinateMax/(2))
    }
    else if(input$crPvaluePosition == 'bottom-right'){
      PValYCoordinate = 0.1
      PValXCoordinate = ceiling(PValXCoordinateMax/(1.1))
    }
    else if(input$crPvaluePosition == 'center-left'){
      PValYCoordinate = 0.5
      PValXCoordinate = ceiling(PValXCoordinateMax/(99))
    }
    else if(input$crPvaluePosition == 'center-right'){
      PValYCoordinate = 0.5
      PValXCoordinate = ceiling(PValXCoordinateMax/(1.1))
    }
    else if(input$crPvaluePosition == 'upper-left'){
      PValYCoordinate = 0.9
      PValXCoordinate = ceiling(PValXCoordinateMax/(99))
    }
    else if(input$crPvaluePosition == 'upper-center'){
      PValYCoordinate = 0.9
      PValXCoordinate = ceiling(PValXCoordinateMax/(2))
    }
    else if(input$crPvaluePosition == 'upper-right'){
      PValYCoordinate = 0.9
      PValXCoordinate = ceiling(PValXCoordinateMax/(1.1))
    } else {
      # Default values if no position is selected
      PValXCoordinate <- NULL
      PValYCoordinate <- NULL
    }
    
    return(list(x=PValXCoordinate, y=PValYCoordinate))
    
  })

  # survfit 
  fit <- reactive({
    duration <<- dataset()[[input$selectedTimeColumn]]
    status <<- dataset()[[input$selectedStatusColumn]]
    dependentVariable <<- dataset()[[input$selectedDependentVariableColumn]]
    
    status <<- ifelse(status == input$selectCensoredLabel, 0, 1)
    
    if(input$selectedDependentVariableType == "number"){
      if(input$selectedDependentVariableSplit == "median"){
        dependentVariable <- ifelse(dependentVariable > median(dependentVariable), 'high', 'low')
      }
      else if(input$selectedDependentVariableSplit == "upper"){
        dependentVariable <- cut(
          dependentVariable, 
          breaks = quantile(dependentVariable, probs = c(0, 0.25, 1), na.rm = TRUE),
          labels = c("low", "high"),
          include.lowest = TRUE
        )
      }
      else if(input$selectedDependentVariableSplit == "lower"){
        dependentVariable <- cut(
          dependentVariable, 
          breaks = quantile(dependentVariable, probs = c(0, 0.75, 1), na.rm = TRUE),
          labels = c("low", "high"),
          include.lowest = TRUE
        )
      }
    }
    
    survfit(Surv(duration, status) ~ dependentVariable, data = dataset())
  })

  # Render the survival plot
  plot_survival <- reactive({
    
    legendList <- unique(dataset()[[input$selectedDependentVariableColumn]])
    legendLabelOne <- paste(input$selectedDependentVariableColumn, "=", as.character(legendList[1]), sep = " ")
    legendLabelTwo <- paste(input$selectedDependentVariableColumn, "=", as.character(legendList[2]), sep = " ")
    
    if(input$selectedDependentVariableType == "number"){
      legendLabelOne <- 'high'
      legendLabelTwo <- 'low'
    }
    
    ggplot_surv <- ggsurvplot(fit(), data = dataset(),
                              size = input$crLineWidth,
                              linetype = input$crLineType,
                              censor.shape = input$crCensorShape,
                              censor.size = input$crCensorWidth,
                              surv.median.line = input$crMedianLineType,
                              break.time.by = input$crXAxisStepSize,
                              break.y.by = input$crYAxisStepSize,
                              pval = if (input$crPValueBoolean == "TRUE") TRUE else FALSE,
                              pval.size = input$crPvalueSize,
                              pval.coord = c(pValueCoordinates()$x, pValueCoordinates()$y),
                              palette = c(input$crClass1Color, input$crClass2Color),
                              xlab = if (nchar(input$crXTitle) != 0) input$crXTitle else "Time",
                              ylab = if (nchar(input$crYTitle) != 0) input$crYTitle else "Survival Probability",
                              legend.title= if (nchar(input$crLegendTitle) != 0) input$crLegendTitle,
                              legend.labs = c(
                                if(nchar(input$crLegendTitle1) != 0) input$crLegendTitle1 else legendLabelOne, 
                                if(nchar(input$crLegendTitle2) != 0) input$crLegendTitle2 else legendLabelTwo
                              ),
                              ggtheme = theme(panel.background = element_rect(fill = input$crBgColor),
                                              panel.grid = if (input$crGridBoolean == "TRUE") element_line(colour = input$crGridColor, linewidth = input$crGridSize) 
                                              else element_blank(),
                              ),
                              xlim = if (input$crTruncateXBoolean == "TRUE") c(0, input$crTruncateXCoordinate),
    )
    
    if(input$crPValueBoolean == "TRUE") ggplot_surv[["plot"]][["layers"]][[4]][["aes_params"]][["colour"]] = input$crPvalueColor
    
    ggplot_surv$plot
    
  })
  
  # Render the plot using Plotly
  output$survivalPlot <- renderPlotly({
    plotHeight <- input$crPlotHeight * 37.795275591  # Convert cm to pixels
    plotWidth <- input$crPlotWidth * 37.795275591    # Convert cm to pixels
    ggplotly(plot_survival(), height = plotHeight, width = plotWidth)
  })
  
  
  output$plotDownload <- downloadHandler(
    filename = function() {
      paste("survival_plot.",input$plotFormat, sep = "")  # Name of the file when downloaded
    },
    content = function(file) {
      plotHeight <- (input$crPlotHeight/2.54)
      plotWidth <- (input$crPlotWidth/2.54)
      plotDPI <- as.numeric(input$plotDPI)
      
      ggsave(file, plot = plot_survival() ,device = input$plotFormat, width=plotWidth, height=plotHeight, dpi = plotDPI)
    }
  )  
}