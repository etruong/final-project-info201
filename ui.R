library("knitr")
library("dplyr")
library("ggplot2")
library("httr")
library("jsonlite")
library("ggplot2")
library("shiny")

library("shinyjs")

yelp.data <- read.csv("data/zip-code-data.csv")

cuisines <- c("asianfusion", "cajun", "caribbean", "cantonese", "chinese", "french", "german", "greek", "hawaiian", "italian", 
              "japanese", "korean", "mediterranean", "mexican", "newamerican", "taiwanese", "thai", 
              "tradamerican", "vietnamese")


my.ui <- fluidPage (
  #includeCSS("styles.css"),
  
  navbarPage ("INFO 201 Application",
          
              tabPanel ("About", h1 ("Welcome!"), p ("This application explores the Yelp Fusion
                                                     API ( for more details ", a ("click here", href = "https://www.google.com"),
                                                     ") answering several analysis questions through visualizations and charts
                                                     of the API's data."),
                        p ("Below details the questions our team explored. You can click the above tags to
                           view how we answered these questions"),
                        tags$ul (
                          tags$li ("Failed Businesses"), tags$li ("Ideal Vegan Locations"), tags$li ("Question 3")),
                        h2 ("The Team"),
                        tags$img (src = "", alt = ""),
                        tags$ul (
                          tags$li ("Elisa Truong"), tags$li ("Major: Intending HCDE or Design"), tags$li ("Year: 2nd"),
                          tags$li ("My interest"))
                        ),
              
             ##### Person assigned to 
             tabPanel ("Question 1",
                       titlePanel ("Title"),
                       p ("Which locations are more likely for a business to fail?")),
             
             
             tabPanel ("Question 2",
                       titlePanel ("Title"),
                       p ("Which locations are ideal for vegetarians?")),
             
             tabPanel ("Question 3",
                       titlePanel(h3("Which Types of Cuisines Are Most Successful in Seattle?")),
                       sidebarLayout(
                         sidebarPanel(
                           actionButton('select.all', label = "Select All"),
                           actionButton('deselect.all', label = "Deselect All"),
                           checkboxGroupInput('cuisine',
                                              label = h3("Cuisine"), 
                                              choices = cuisines,
                                              selected = cuisines[1])
                      ),
                         mainPanel(
                           tabsetPanel(
                             tabPanel("Plot", plotOutput('plot')),
                             tabPanel("Table", dataTableOutput('table'))
                           ),
                           textOutput('conclusion')
                      )
                    )
             ),
             
             tabPanel("Question 4",
                      tabPanel("Scatter", plotOutput('scatter'))
             )
  )
)
shinyUI (my.ui)