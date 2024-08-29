library(shiny)

options(shiny.host = '0.0.0.0')
options(shiny.port = 7777)

# Allow files up to 10 Mb
options(shiny.maxRequestSize=10*1024^2)

source('libraries.R')
source('functions.R')

# Define UI
ui <- fluidPage(
    
    tags$head(tags$link(rel="icon", type="image/png", sizes="32x32", href="/images/favicon-32x32.png")),

    # Application title
    titlePanel("Survival Analysis"),
    br(),
    
    sidebarLayout(
      
      # Sidebar with a slider input
      sidebarPanel(
        #adjusting the width of sidebarPanel
        width=3,
        conditionalPanel("input.tabset == 'Data' ",
                         
                      
                      # Input: Select separator ----
                       radioButtons("selectedDataMode", "Upload Data", 
                                    choices = c("Example 1" = "ex1",
                                                "Example 2" = "ex2",
                                                "Upload" = "ex3"),
                                    selected = "ex1"),   
                       
                      
                      conditionalPanel("input.selectedDataMode == 'ex3' ",
                                       
                       
                         # Input: Select a file ----
                         fileInput("selectedFile", "Choose a CSV File",
                                   multiple = FALSE,
                                   accept = c("text/csv",
                                              "text/comma-separated-values,text/plain",
                                              ".csv")),
                         
                         
                         # Input: Select separator ----
                         radioButtons("selectedSeparator", "Separator", inline = TRUE,
                                      choices = c(Comma = ",",
                                                  Semicolon = ";",
                                                  Space = " ",
                                                  Tab = "\t"),
                                      selected = ";")
                       
                        ),
                       
                       
                       # Horizontal line ----
                       tags$hr(),
                       
                       h4('Select Gene, Outcome and Duration variables'),
                       
                       selectInput(
                         inputId = "selectedGene",
                         label = "Select Gene",
                         choices = c("sex", "BCL11A", "PIK3CA", "TP63"),
                         selected = "sex",
                         multiple = FALSE,
                         selectize = TRUE,
                         width = NULL,
                         size = NULL
                       ),
                       
                       selectInput(
                         inputId = "selectedOutcomeColumn",
                         label = "Outcome column (Dead or Alive)",
                         choices = c("status", "Col 2", "Col 3", "Col 4"),
                         selected = "status",
                         multiple = FALSE,
                         selectize = TRUE,
                         width = NULL,
                         size = NULL
                       ),
                       
                       selectInput(
                         inputId = "selectedDurationColumn",
                         label = "Time duration column",
                         choices = c("time", "Col 2", "Col 3", "Col 4"),
                         selected = "time",
                         multiple = FALSE,
                         selectize = TRUE,
                         width = NULL,
                         size = NULL
                       ),
                       
                       selectInput(
                         inputId = "selectedDurationStepSize",
                         label = "Time interval",
                         choices = c("Days", "Months", "Weeks", "Years"),
                         selected = "Days",
                         multiple = FALSE,
                         selectize = TRUE,
                         width = NULL,
                         size = NULL
                       ),
                      
                       
                      ),
      
        # Sidebar with a slider input
        conditionalPanel("input.tabset == 'Plot'",
                         sliderInput("dobs",
                                     "Number of asdas:",
                                     min = 0,
                                     max = 1000,
                                     value = 500)
                      ),
      
      ),
      
      
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          id = "tabset",
          tabPanel("Data",
                   layout_columns(h4('Study Data'), 
                                  tags$div(
                                    downloadButton("downloadExampleFile1", "Example 1"),
                                    downloadButton("downloadExampleFile2", "Example 2")
                                  )
                                  ),
                   DT::dataTableOutput("dataTable")
                   ),
          tabPanel("Plot",
                   plotOutput("survivalPlot")),
          tabPanel("Help", "three"),
          tabPanel("About", "three")
        )
      )
    )
)





















