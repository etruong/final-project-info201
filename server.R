library(shiny)
library("ggplot2")
library("dplyr")
library("knitr")
library("maps")
library("tidyr")
library(sp)
library(maptools)
library(rsconnect)

Sys.setlocale(locale="C")
# Get the csv file for the data set of zip codes and filter with 
zip.code.data <- read.csv("./zip-code-data.csv")

# Seattle
#US <- map_data("US")
#states <- map_data("state")
#washington <- subset(states, region == "washington")
zip.code.filtered <- filter(zip.code.data, review_count >= 100)



my.server <- function (input, output, session) {
  table.data <- reactive({
   # if(input$zip.code == "all"){
   #   zip.rate.data <- select(zip.code.filtered, name, rating, location.zip_code)
   #} else {
     vector <- c(input$zip.code)
     zip.rate.data <- filter(zip.code.filtered, location.zip_code %in% vector)
   # zip.rate.data.row <- which(zip.code.filtered[,"location.zip_code"] == input$zip.code)
   # zip.rate.data <- zip.code.filtered[zip.rate.data.row,]
    zip.rate.data <- select(zip.rate.data, name, rating, location.zip_code)
    
   # }
   
    return(zip.rate.data)
  })
  
  output$table <- renderTable({
    return(table.data())
  })
  
  
  # scatter plot, group by colors/zip code, x= axis rating y-axis, how many of those zip codes have that rating
  plot <- reactive({
    input.vector <- c(input$zip.code)
    zip.rate.data <- filter(zip.code.filtered, location.zip_code %in% input.vector)
    averages.rate <- group_by(zip.rate.data, location.zip_code) %>%
      summarize(mean = mean(rating))
      
    #averages.rate 
    mean <- c(averages.rate[,"mean"])
    zip.vector <- c(averages.rate[,"location.zip_code"])
    gdp.visualization <- ggplot(data = averages.rate) +
      geom_bar(mapping = aes(x = as.factor(location.zip_code), y = mean), stat = "identity")
      
    
    return(gdp.visualization)
   
  })
  output$plot <- renderPlot({
    return(plot())
  })
  
  # when clicked on the zip code, it gives the city and rate
  
}

shinyServer (my.server)