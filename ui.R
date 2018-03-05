library ("shiny")
library("ggplot2")
library("dplyr")
library("knitr")
library("maps")
library("tidyr")
library(sp)
library(maptools)
library(rsconnect)

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
                       titlePanel(h3("Which locations are more likely for a business to fail?")),
                       sidebarLayout(
                         sidebarPanel(
                           # Allows the user to choose one or more zip codes
                           checkboxGroupInput('zip.code', "Select one or more zip codes: ", c(98020, 98026, 98028, 98047, 98056,
                                                                                              98057, 98101, 98102, 98103, 98104,
                                                                                              98105, 98106, 98107, 98108, 98109,
                                                                                              98112, 98115, 98116, 98117, 98118,
                                                                                              98119, 98121, 98122, 98125, 98126,
                                                                                              98127, 98133, 98134, 98136, 98144,
                                                                                              98146, 98154, 98155, 98161, 98166,
                                                                                              98168, 98177, 98178, 98188, 98195,
                                                                                              98199, 98346), selected = c(98020))
                         ),
                         mainPanel(
                             tabsetPanel(
                               tabPanel("Plot", plotOutput('plot', click = 'plot.click')),
                               tabPanel("Table", tableOutput('table'))
                             ),
                             verbatimTextOutput("info"),
                             verbatimTextOutput("map.info")
                         )
                      )
                           
              ),
                       
                      
            
             
             
             tabPanel ("Question 2",
                       titlePanel ("Title"),
                       p ("Which locations are ideal for vegetarians?"))
             
          
             
             
             
             
  )
)

shinyUI (my.ui)