# Survival Analysis: A shiny application

## 1. Introduction
### 1.1 What is survival Analysis
Survival analysis is a statistical method used to analyze the time until an event of interest occurs, such as death, failure, or recovery. It accounts for "censored" data, where the event hasn't happened for all subjects by the study's end.

### 1.2 Use cases

* **Cancer Research**: Analyzing the survival time of cancer patients after receiving a particular treatment (e.g., chemotherapy) and identifying which factors (e.g., age, genetic mutations) affect survival.

* **Clinical Trials**: Estimating the time to relapse or recovery for patients receiving a new drug compared to those receiving a placebo.

* **Gene Expression Studies**: Linking specific gene expression profiles (e.g., high vs. low expression) to patient survival outcomes, helping to identify potential biomarkers for prognosis.

## 2. Build
1. Clone the project
2. Open the project directory in R Studio
3. Install all the required libraries
4. Click on **Run App** button (available on top-right)

## 3. How to use

### 3.1 Upload Data

1. Go to the **Data** tab
2. Upload the file in csv format
3. Choose the file separator used (csv, semicolon, space or Tab)
4. File contents will be displayed in the right panel
5. Choose the column representing *Time*, *Vital status*, *Dependent variable*

##### Points to remember
* Data file upto 10 MB is supported
* *Vital status* and *Dependent variable* should not contain NA values
* Choose the option representing censored data for the *Vital status* column
* Choose Numeric *Dependent variable type* option if the column to be used contains numeric values like gene expression

### 3.2 Visualization

1. Go to the **Plot** tab
2. The survival analysis plot would have been generated
3. Customize the plot with various options available in the left sidebar
4. Export the plot in the desired DPI (200,300,400,500) and format (png, jpg, tiff, svg)

## 4. Tech Stack

### 4.1 Structure
* **Shiny framework** was used to develop the web app along-with various libraries in R.
* **R Studio IDE** is used for the project maintenance and development
* **Git and Github** is used for version control and code maintainence.

##### Libraries
```{r}
library(shiny)
library(survminer)
library(survival)
library(plotly)
library(colourpicker)
library(bsplus)
library(bslib)
library(shinyjs)
library(svglite)
```
##### sessionInfo()
```{r}
R version 4.4.1 (2024-06-14)
Platform: x86_64-pc-linux-gnu
Running under: Ubuntu 20.04.6 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0 
LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
 [3] LC_TIME=en_GB.UTF-8        LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=en_GB.UTF-8    LC_MESSAGES=en_US.UTF-8   
 [7] LC_PAPER=en_GB.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=en_GB.UTF-8 LC_IDENTIFICATION=C       

time zone: Europe/Berlin
tzcode source: system (glibc)

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] svglite_2.1.3      shinyjs_2.1.0      bslib_0.8.0        bsplus_0.1.4      
 [5] colourpicker_1.3.0 plotly_4.10.4      survival_3.7-0     survminer_0.4.9   
 [9] ggpubr_0.6.0       ggplot2_3.5.1      shiny_1.9.1       

loaded via a namespace (and not attached):
 [1] gtable_0.3.5           xfun_0.47              htmlwidgets_1.6.4     
 [4] rstatix_0.7.2          lattice_0.22-5         vctrs_0.6.5           
 [7] tools_4.4.1            generics_0.1.3         tibble_3.2.1          
[10] fansi_1.0.6            pkgconfig_2.0.3        Matrix_1.6-5          
[13] data.table_1.15.4      lifecycle_1.0.4        compiler_4.4.1        
[16] munsell_0.5.1          carData_3.0-5          httpuv_1.6.15         
[19] htmltools_0.5.8.1      sass_0.4.9             yaml_2.3.10           
[22] lazyeval_0.2.2         later_1.3.2            pillar_1.9.0          
[25] car_3.1-2              jquerylib_0.1.4        tidyr_1.3.1           
[28] cachem_1.1.0           abind_1.4-5            mime_0.12             
[31] km.ci_0.5-6            tidyselect_1.2.1       digest_0.6.37         
[34] dplyr_1.1.4            purrr_1.0.2            splines_4.4.1         
[37] fastmap_1.2.0          grid_4.4.1             colorspace_2.1-1      
[40] cli_3.6.3              magrittr_2.0.3         utf8_1.2.4            
[43] broom_1.0.6            withr_3.0.1            scales_1.3.0          
[46] promises_1.3.0         backports_1.5.0        lubridate_1.9.3       
[49] timechange_0.3.0       rmarkdown_2.28         httr_1.4.7            
[52] gridExtra_2.3          ggsignif_0.6.4         zoo_1.8-12            
[55] evaluate_0.24.0        knitr_1.48             KMsurv_0.1-5          
[58] miniUI_0.1.1.1         viridisLite_0.4.2      survMisc_0.5.6        
[61] rlang_1.1.4            Rcpp_1.0.13            xtable_1.8-4          
[64] glue_1.7.0             jsonlite_1.8.8         R6_2.5.1              
[67] systemfonts_1.1.0.9000
```

### 4.2 Hosting

**Posit Cloud** is used to host the web app using *packrat* and *rsconnect* R package.
