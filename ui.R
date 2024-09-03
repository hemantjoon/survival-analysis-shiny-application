library(shiny)

options(shiny.host = '0.0.0.0')
options(shiny.port = 7777)

# Allow files up to 10 Mb
options(shiny.maxRequestSize=10*1024^2)

source('libraries.R')
source('functions.R')

# Define UI
ui <- fluidPage(
    
    tags$head(
      tags$link(rel="icon", type="image/png", sizes="32x32", href="/images/favicon-32x32.png"),
      tags$style(HTML("hr {border-top: 1px solid #000000;}"))
      ),

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
                       
                       h4('Select Time, Status and Dependent variables'),
                      
                      selectInput(
                        inputId = "selectedTimeColumn",
                        label = "Time",
                        choices = c("inst", "time", "status", "age", "sex", "ph_ecog", "ph_karno", "pat_karno"),
                        selected = "time",
                        multiple = FALSE,
                        selectize = TRUE,
                        width = NULL,
                        size = NULL
                      ),
                      
                      selectInput(
                        inputId = "selectedStatusColumn",
                        label = "Status (Dead/Alive)",
                        choices = c("status", "sex"),
                        selected = "status",
                        multiple = FALSE,
                        selectize = TRUE,
                        width = NULL,
                        size = NULL
                      ),
                       
                       selectInput(
                         inputId = "selectedDependentVariableColumn",
                         label = "Dependent variable (male/female)",
                         choices = c("status", "sex"),
                         selected = "sex",
                         multiple = FALSE,
                         selectize = TRUE,
                         width = NULL,
                         size = NULL
                       ),
  
                      
                       
                      ),
      
        # Sidebar with a slider input
        conditionalPanel("input.tabset == 'Plot'",
                         layout_columns(
                           selectInput("crLineType", "Survival Line Type", 
                                       choices = c("Two Dashed" = "twodash", "Solid line" = "solid", "Long Dash" = "longdash", 
                                                   "Dotted" = "dotted", "Dot Dash" = "dotdash", "Dashed" = "dashed"), 
                                       selected = "solid"),
                           numericInput("crLineWidth", "Survival Line width", value =1, min = 0, max = 15, step = 0.1)
                         ),
                         layout_columns(
                           selectInput("crCensorShape", "Censor Shape", 
                                       choices = c("Vertical Line"=124, "Square"=0, "Circle"=1, "Triangle point-up"=2, "Plus"=3, "Cross"=4, "Diamond"=5, 
                                                   "Triangle point-down"=6, "Square cross"=7, "Star"=8, "Diamond plus"=9, "Circle plus"=10, "Triangles up and down"=11, 
                                                   "Square Plus"=12, "Circle Cross"=13, "Square and Triangle down"=14, "Filled Square"=15, "Filled Circle"=16, 
                                                   "Filled Triangle point-up"=17, "Filled Diamond"=18, "Solid Circle"=19, "Bullet"=20), 
                                       selected = 124),
                           numericInput("crCensorWidth", "Censor Size", value =2.5, min = 0, max = 20, step = 0.1)
                         ),
                         hr(),
                         layout_columns(
                           radioButtons("crPValueBoolean", "Embed p-value?", inline = TRUE,
                                        choices = c("Yes" = "TRUE",
                                                    "No" = "FALSE"),
                                        selected = "TRUE"),
                           radioButtons("crCIBoolean", "Draw confidence interval?", inline = TRUE,
                                        choices = c("Yes" = "TRUE",
                                                    "No" = "FALSE"),
                                        selected = "FALSE")
                         ),
                         br(),
                         layout_columns(
                           colourInput("crClass1Color", "Class 1 color", "#F8766D"),
                           colourInput("crClass2Color", "Class 2 color", "#619CFF"),
                         ),
                         layout_columns(
                           textInput("crXTitle", "X-axis Title", value = "", width = NULL, placeholder = "Time in months"),
                           textInput("crYTitle", "Y-axis Title", value = "", width = NULL, placeholder = "Survival Probability")
                         ),
                         hr(),
                         layout_columns(
                           textInput("crLegendTitle", "Legend Title", value = "", width = NULL, placeholder = "Class")
                         ),
                         layout_columns(
                           textInput("crLegendTitle1", "Class 1 Title", value = "", width = NULL, placeholder = "Title 1"),
                           textInput("crLegendTitle2", "Class 2 Title", value = "", width = NULL, placeholder = "Title 2")
                         ),
                         
                         bs_accordion(
                           id = "accordion"
                         )  |> 
                           bs_set_opts(
                             use_heading_link = TRUE
                           ) |> 
                           bs_append(
                             title = "Advance",
                             content = div(
                               layout_columns(
                                 selectInput("crGridType", "Grid Type", 
                                             choices = c("Two Dashed" = "twodash", "Solid line" = "solid", "Long Dash" = "longdash", 
                                                         "Dotted" = "dotted", "Dot Dash" = "dotdash", "Dashed" = "dashed"), 
                                             selected = "solid"),
                                 numericInput("crGridSize", "Grid Width", value =1, min = 0, max = 15, step = 0.1),
                                 colourInput("crGridColor", "Grid Color", "#000000")
                               ),
                               layout_columns(
                                 colourInput("crBgColor", "Background Color", "#FFFFFF"),
                                 selectInput("crMedianLineType", "Median Line Type", 
                                             choices = c("No Median Line" = "none", "Horizontal" = "h", "Vertical" = "v", "Horizontal and Vertical" = "hv"), 
                                             selected = "none"),
                               ),
                               layout_columns(
                                 numericInput("crXAxisStepSize", "X Axis Step Size", value =1, min = 0, max = 15, step = 0.1),
                                 numericInput("crYAxisStepSize", "Y Axis Step Size", value =200, min = 10, max = 1000, step = 200),
                               )
                             )
                           ) 
                         
                         
                         
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
                   div(DT::dataTableOutput("dataTable"), style = "overflow-x: auto; width: 100%;")
                   
                   ),
          tabPanel("Plot",
                   plotlyOutput("survivalPlot", height = "600px")),
          tabPanel("Help", "three"),
          tabPanel("About", "three")
        )
      )
    )
)





















