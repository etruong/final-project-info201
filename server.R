library(shiny)
library("ggplot2")
library("dplyr")
library("knitr")
library("maps")
library("tidyr")
library(sp)
library(maptools)
library(rsconnect)

# Get the csv file for the data set of zip codes and filter with 
zip.code.data <- read.csv("./zip-code-data.csv")
zip.code.filtered <- filter(zip.code.data, review_count >= 100)


my.server <- function (input, output, session) {
  
}

shinyServer (my.server)