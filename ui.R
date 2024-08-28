library(shiny)

options(shiny.host = '0.0.0.0')
options(shiny.port = 7777)

# Allow files up to 10 Mb
options(shiny.maxRequestSize=10*1024^2)

source('libraries.R')
source('functions.R')

# Define UI
ui <- fluidPage(
  
    # Application title
    titlePanel("Survival Analysis"),
    
    sidebarLayout(
      
      # Sidebar with a slider input
      sidebarPanel(
      conditionalPanel("input.tabset == 'Data' ",
                       
                       
                       # Input: Select a file ----
                       fileInput("selectedFile", "Choose a CSV File",
                                 multiple = FALSE,
                                 accept = c("text/csv",
                                            "text/comma-separated-values,text/plain",
                                            ".csv")),
                       
                       # Horizontal line ----
                       tags$hr(),
                       
                       # Input: Checkbox if file has header ----
                       checkboxInput("selectedHeader", "Header", TRUE),
                       
                       # Input: Select separator ----
                       radioButtons("selectedSeparator", "Separator", inline = TRUE,
                                    choices = c(Comma = ",",
                                                Semicolon = ";",
                                                Tab = "\t"),
                                    selected = ","),
                       
                       
                       # Horizontal line ----
                       tags$hr(),
                       
                       h4('Select Gene, Outcome and Duration variables'),
                       
                       selectInput(
                         inputId = "selectedGene",
                         label = "Select Gene",
                         choices = c("PEG3", "BCL11A", "PIK3CA", "TP63"),
                         selected = "PEG3",
                         multiple = FALSE,
                         selectize = TRUE,
                         width = NULL,
                         size = NULL
                       ),
                       
                       selectInput(
                         inputId = "selectedOutcomeColumn",
                         label = "Outcome column (Dead or Alive)",
                         choices = c("Col 1", "Col 2", "Col 3", "Col 4"),
                         selected = "Col 4",
                         multiple = FALSE,
                         selectize = TRUE,
                         width = NULL,
                         size = NULL
                       ),
                       
                       selectInput(
                         inputId = "selectedDurationColumn",
                         label = "Time duration column",
                         choices = c("Col 1", "Col 2", "Col 3", "Col 4"),
                         selected = "Col 3",
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
                   h4('Study Data'),
                   DT::dataTableOutput("dataTable")
                   ),
          tabPanel("Plot", "two"),
          tabPanel("Help", "three"),
          tabPanel("About", "three")
        )
      )
    )
)





















