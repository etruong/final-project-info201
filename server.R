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
# Gets the csv file for the data set of zip codes and filter with 
zip.code.data <- read.csv("./zip-code-data.csv")

# Only gets the data that has review counts greater than 100 for more reliable data
zip.code.filtered <- filter(zip.code.data, review_count >= 100)

my.server <- function (input, output, session) {
  # Creates a table
  table.data <- reactive({
      
      # Gets the data of the selected zip code and only show the name, rating and zip code in the table
      vector <- c(input$zip.code)
      zip.rate.data <- filter(zip.code.filtered, location.zip_code %in% vector)
      zip.rate.data <- select(zip.rate.data, name, rating, location.zip_code)
      
      # Changes the column names
      colnames(zip.rate.data)[colnames(zip.rate.data)=="name"] <- "Business Name"
      colnames(zip.rate.data)[colnames(zip.rate.data)=="rating"] <- "Rating"
      colnames(zip.rate.data)[colnames(zip.rate.data)=="location.zip_code"] <- "Zip Code"
      
    return(zip.rate.data)
  })
  
  # Outputs the table
  output$table <- renderTable({
    return(table.data())
  })
  
  
  # Creates a plot
  plot <- reactive({
    input.vector <- c(input$zip.code)
      
      # Gets the average rating for each of the selected input
      zip.rate.data <- filter(zip.code.filtered, location.zip_code %in% input.vector)
      averages.rate <- group_by(zip.rate.data, location.zip_code) %>%
        summarize(mean = mean(rating))
    
    
    # Makes the zip code and mean value from above into a vector
    mean <- c(averages.rate[,"mean"])
    zip.vector <- c(averages.rate[,"location.zip_code"])
    
    # Creates a bar graph of the selected zip codes and the average ratings for them
    gdp.visualization <- ggplot(data = averages.rate) +
      geom_bar(mapping = aes(x = as.factor(location.zip_code), y = mean, fill = as.factor(location.zip_code)), 
               stat = "identity") + labs(title = "The Average Rating for Selected Zip Code",
                                         y = "Average Rating", x = "Zip Code", fill = "Zip Code")
    
    return(gdp.visualization)
    
  })
  # Outputs the bar graph
  output$plot <- renderPlot({
    return(plot())
  })
  
  # Creates a sentence about the average ratings for the selected zip codes
  output$info <- renderPrint({
    input.vector <- c(input$zip.code)
    zip.rate.data <- filter(zip.code.filtered, location.zip_code %in% input.vector)
    averages.rate <- group_by(zip.rate.data, location.zip_code) %>%
      summarize(mean = round(mean(rating), digits = 3))
    
    # Finds the zip code that has the max and min averages
    averages.rate.max.row <- which(averages.rate[,"mean"] == max(averages.rate[,"mean"]))
    averages.rate.min.row <- which(averages.rate[,"mean"] == min(averages.rate[,"mean"]))
    average.rate.max <- averages.rate[averages.rate.max.row, "location.zip_code"]
    average.rate.min <- averages.rate[averages.rate.min.row, "location.zip_code"]
    
    # Prints out information about the zip code and average rating for it
    sentence <- paste0("The selected zip code(s) is/are: ", 
                       averages.rate[,"location.zip_code"], " and the corresponding rating(s) is/are: ",
                       averages.rate[,"mean"],
                       ". The highest rating was ", average.rate.max, ", and the lowest rating was ", average.rate.min, 
                       ". The lower the rating, the more likely the business will fail, so the business in, ", average.rate.min,
                       " is most likely to fail out of the selected zip codes.")
    
    return(sentence)
    
  })
  
  
}

shinyServer (my.server)
