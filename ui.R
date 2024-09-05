library(shiny)

options(shiny.host = '0.0.0.0')
options(shiny.port = 7777)

# Allow files up to 10 Mb
options(shiny.maxRequestSize=10*1024^2)

source('libraries.R')
source('functions.R')

# Define UI
ui <- fluidPage(
    useShinyjs(),
    tags$head(
      tags$link(rel="icon", type="image/png", sizes="32x32", href="/images/favicon-32x32.png"),
      tags$style(HTML("hr {border-top: 1px solid #000000;}")),
      
      tags$style(HTML(
        "@font-face {
          font-family: 'Rocher';
          src: url(https://assets.codepen.io/9632/RocherColorGX.woff2);
        }
    
        @font-palette-values --Purples {
            font-family: Rocher;
            base-palette: 6;
        }
            
        
        #creativeHeading{
        font-family: 'Rocher';
        font-palette: --Purples;
        font-size: 3.5em;
        width: fit-content; 
        margin: auto;
        
        background-image: linear-gradient(gold, gold);
        background-size: 100% 10px;
        background-repeat: no-repeat;
        background-position: 100% 0%;
        transition: background-size .7s, background-position .5s ease-in-out;
        }

        #creativeHeading:hover {
        background-size: 100% 100%;
        background-position: 0% 100%;
        transition: background-position .7s, background-size .5s ease-in-out;}"
      ))
      ),

    # Application title
    br(),
    h1("Survival Analysis", id = "creativeHeading"),
    br(), br(),
    
    sidebarLayout(
      
      # Sidebar for data input
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
                                      selected = ",")
                       
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
                        label = "Vital Status (Dead/Alive)",
                        choices = c("status", "sex"),
                        selected = "status",
                        multiple = FALSE,
                        selectize = TRUE,
                        width = NULL,
                        size = NULL
                      ),
                      
                      selectInput(
                        inputId = "selectCensoredLabel",
                        label = "Label for Censored data",
                        choices = c(0, 1),
                        selected = 0,
                        multiple = FALSE,
                        selectize = TRUE,
                        width = NULL,
                        size = NULL
                      ),
                      
                      # Dependent Variable Type
                      radioButtons("selectedDependentVariableType", "Dependent Variable Type", 
                                   choices = c("Boolean (Dead/Alive or Low/High)" = "bool",
                                               "Numeric (Gene Expression or Age)" = "number"),
                                   selected = "bool"), 
                      
                      layout_columns(
                        selectInput(
                          inputId = "selectedDependentVariableColumn",
                          label = "Dependent variable",
                          choices = c("status", "sex"),
                          selected = "sex",
                          multiple = FALSE,
                          selectize = TRUE,
                          width = NULL,
                          size = NULL
                        ),
                      
                        conditionalPanel("input.selectedDependentVariableType == 'number' ",
                          selectInput(
                            inputId = "selectedDependentVariableSplit",
                            label = "Split by",
                            choices = c("Median" = "median", "Upper quartile" = "upper", "Lower quartile" = "lower"),
                            selected = "median",
                            multiple = FALSE,
                            selectize = TRUE,
                            width = NULL,
                            size = NULL
                          ),
                        )
                      )
  
                      
                       
                      ),
      
        # Sidebar for plot
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
                                       choices = c("Vertical Line"= 124, "Square"=0, "Circle"=1, "Triangle point-up"=2, "Plus"=3, "Cross"=4, "Diamond"=5, 
                                                   "Triangle point-down"=6, "Square cross"=7, "Star"=8, "Diamond plus"=9, "Circle plus"=10, "Triangles up and down"=11, 
                                                   "Square Plus"=12, "Circle Cross"=13, "Square and Triangle down"=14, "Filled Square"=15, "Filled Circle"=16, 
                                                   "Filled Triangle point-up"=17, "Filled Diamond"=18, "Solid Circle"=19, "Bullet"=20), 
                                       selected = 3),
                           numericInput("crCensorWidth", "Censor Size", value =2.5, min = 0, max = 20, step = 0.1),
                         ),
                         hr(),
                         layout_columns(
                           radioButtons("crPValueBoolean", "Embed p-value?", inline = TRUE,
                                        choices = c("Yes" = "TRUE",
                                                    "No" = "FALSE"),
                                        selected = "TRUE"),
                           selectInput("crPvaluePosition", "p-value position", 
                                       choices = c("Bottom Left" = "bottom-left", "Bottom Center" = "bottom-center", "Bottom Right" = "bottom-right", 
                                                   "Center Left" = "center-left", "Center Right" = "center-right", "Upper Left" = "upper-left", 
                                                   "Upper Center" = "upper-center", "Upper Right" = "upper-right"), 
                                       selected = "bottom-left"),
                         ),
                         layout_columns(
                           numericInput("crPvalueSize", "p-value size", value = 4, min = 0, max = 15, step = 0.1),
                           colourpicker::colourInput("crPvalueColor", "p-value color", "#000000"),
                         ),
                         br(),
                         layout_columns(
                           colourpicker::colourInput("crClass1Color", "Class 1 color", "#F8766D"),
                           colourpicker::colourInput("crClass2Color", "Class 2 color", "#619CFF"),
                         ),
                         layout_columns(
                           textInput("crXTitle", "X Axis Title", value = "", width = NULL, placeholder = "Time in months"),
                           textInput("crYTitle", "Y Axis Title", value = "", width = NULL, placeholder = "Survival Probability")
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
                                 radioButtons("crGridBoolean", "Draw grid?", inline = TRUE,
                                              choices = c("Yes" = "TRUE",
                                                          "No" = "FALSE"),
                                              selected = "TRUE"),
                                 numericInput("crGridSize", "Grid Width", value =1, min = 0, max = 15, step = 0.1),
                                 colourpicker::colourInput("crGridColor", "Grid Color", "#000000")
                               ),
                               layout_columns(
                                 colourpicker::colourInput("crBgColor", "Background Color", "#FFFFFF"),
                                 selectInput("crMedianLineType", "Median Line Type", 
                                             choices = c("No Median Line" = "none", "Horizontal" = "h", "Vertical" = "v", "Horizontal and Vertical" = "hv"), 
                                             selected = "none"),
                               ),
                               layout_columns(
                                 numericInput("crXAxisStepSize", "X Axis Step Size", value = 200, min = 10, max = 1000, step = 1),
                                 numericInput("crYAxisStepSize", "Y Axis Step Size", value = 0.25, min = 0.01, max = 1, step = 0.01),
                               ),
                               layout_columns(
                                 radioButtons("crTruncateXBoolean", "Truncate X Axis?", inline = TRUE,
                                              choices = c("Yes" = "TRUE",
                                                          "No" = "FALSE"),
                                              selected = "FALSE"),
                                 numericInput("crTruncateXCoordinate", "X Axis Coordinate", value = 900, min = 10, max = 1000, step = 10),
                               ),
                               layout_columns(
                                 numericInput("crPlotHeight", "Plot Height (cm)", value =15, min = 2, max = 50, step = 1),
                                 numericInput("crPlotWidth", "Plot Width (cm)", value =30, min = 2, max = 50, step = 1),
                               )
                             )
                           ) 
                         
                         
                         
                      ),
        
        # Sidebar for plot
        conditionalPanel("input.tabset == 'About'", class = "aboutSidebar" ,
                         tags$link(rel = "stylesheet", type = "text/css", href = "survival.css"),
                         br(),
                         img(class="hemant-img", src="hemant.jpg", alt="Hemant Kumar Joon"),
                         h2("Hemant Kumar Joon"),
                         div(class="intro-social",
                           tags$a(href="https://www.linkedin.com/in/hemantjoon/",
                                  tags$img(src="images/linkedln.png",
                                           title="hello",
                                           height="30"
                                           )
                            ),
                           tags$a(href="https://www.researchgate.net/profile/Hemant-Joon",
                                  tags$img(src="images/researchGate.png",
                                           title="Research Gate.png",
                                           height="30"
                                  )
                           ),
                           tags$a(href="https://github.com/hemantjoon", target="_blank",
                                  tags$img(src="images/github.png",
                                           title="Github",
                                           height="30"
                                  )
                           )
                         ),
                         br(),
                         div(class="sidebar-info",
                           h4("Portfolio"),
                           tags$a(href="https://hemantjoon.github.io/", "https://hemantjoon.github.io",
                                  target="_blank")
                         ),
                         div(class="sidebar-info",
                             h4("Projects"),
                             tags$a(href="https://hemantjoon.github.io/#projects", "https://hemantjoon.github.io/#projects",
                                    target="_blank")
                         ),
                         div(class="sidebar-info",
                             h4("Email"),
                             tags$a(href="mailto:hemant.joon@rcb.res.in", "hemant.joon@rcb.res.in",
                                    target="_blank")
                         ),
                         
                         
        )
      
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
                   layout_columns(h4(''), 
                                  tags$style(HTML(".exportButton {margin-top: auto; margin-bottom: auto;}")),
                                  div(style="display: flex; justify-content: space-between;",
                                    # layout_columns(
                                      selectInput("plotDPI", "DPI", width = "100px", 
                                                  choices = c(200, 300, 400, 500), 
                                                  selected = 300),
                                      selectInput("plotFormat", "Format", width = "100px",  
                                                  choices = c("PNG" = "png", "JPG" = "jpg", "TIFF" = "tiff", "SVG" = "svg"), 
                                                  selected = "png"),
                                      downloadButton("plotDownload", "Export", class = "exportButton"),
                                    # )
                                  )
                   ),
                   br(), br(),
                   plotlyOutput("survivalPlot", height = 15*37.795275591, width = 30*37.795275591)),
          
          tabPanel("Help",
                   
                   tags$iframe(src = "help.html", 
                               width = "100%", 
                               height = "800px", 
                               frameborder = "0",
                               scrolling = "yes")
                  
                   
                   # End of Help Panel
                   ),
          
          tabPanel("About",
                   
                   # tags$style(HTML(".about-hr {border-top: 1px dotted; width: 80%;}")),
                   
                   # tags$style(HTML(".about-hr {border: 0; text-align: center; height: 30px; background-color: transparent;}")),
                   # tags$style(HTML(".about-hr:before {content: '•••'; font-size: 30px; color: #009879;}")),
                   
                   h3("About the app"),
                   h5("A user-friendly platform for survival analysis. User may upload their data, choose relevant columns representing time,
                      vital status and dependent variable (optimal options are dynamically loaded to choose from). A survival analysis plot using
                      ggsurvplot and plotly is generated with various customization options. The plots can be exported in DPI (200 to 500) and 
                      various formats like png, jpg, tiff and svg"),
                   # br(),
                   # hr(class="about-hr"),
                   h3("Codebase"),
                   h5("The entire codebase for the application is available at: ", 
                      tags$a(href="https://github.com/hemantjoon/survival-analysis-shiny-application", 
                             "https://github.com/hemantjoon/survival-analysis-shiny-application", target="_blank")),
                   # br(),
                   # hr(class="about-hr"),
                   h3("Credits"),
                   h5("Several articles of Posit and Stack Overflow along-with inspiration from shiny applications were utilized for the
                      development of the web app."),
                   tags$ul(
                     tags$li(tags$a(href="https://hkjoon.shinyapps.io/sars-shiny-dashboard/", "SARS-CoV-2",
                                    target="_blank")),
                     tags$li(tags$a(href="http://14.139.62.220/volfis/home.html", "VolFIS",
                                    target="_blank")),
                     tags$li(tags$a(href="https://github.com/JoachimGoedhart/VolcaNoseR", "VolcaNoseR",
                                    target="_blank"))
                   ),
                   # br(),
                   # hr(class="about-hr"),
                   h3("Future goals"),
                   tags$ul(
                     tags$li("API support for remote CSV files"),
                     tags$li("Integration with NCBI-GEO and TCGA datasets, directly with the accession number"),
                     tags$li("Support for CoxPH")
                   ),
                   br(),
                   h5("Do you have an idea or need support, please feel free to contact.")
                   
                   # End of About tabPanel
                   )
        )
      )
    )
)





















