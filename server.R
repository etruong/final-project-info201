library("knitr")
library("dplyr")
library("ggplot2")
library("httr")
library("jsonlite")
library("ggplot2")
library("shiny")
# For capitalize function



# If there's time, we could also take a look at the correlation between the number of reviews and the rating

yelp.data <- read.csv("data/zip-code-data.csv")
cuisines <- c("asianfusion", "cajun", "caribbean", "cantonese", "chinese", "french", "german", "greek", "hawaiian", "italian", 
              "japanese", "korean", "mediterranean", "mexican", "newamerican", "shanghainese", "taiwanese", "thai", 
              "tradamerican", "vietnamese")
yelp.data <- distinct(yelp.data, id, name, review_count, rating, price, 
                      phone, coordinates.latitude, coordinates.longitude, 
                      location.address1, location.city, location.zip_code, location.country, location.state, category)

my.server <- function (input, output, session) {
  
  data <- reactiveValues()
  
  
  # Tyler's Page
  output$plot <- renderPlot({
    # print(input$cuisine)
    curr.data <- na.omit(yelp.data %>%
                           filter(review_count >= 100 & (category %in% input$cuisine)) %>%
                           select(name, category, rating, review_count))
    # summary <- curr.data %>%
    #   group_by(category) %>%
    #   summarize(std.dev = sd(rating), mean = mean(rating), median = median(rating))
     grouped.data <- curr.data %>%
       group_by(category) %>%
       filter((rating > mean(rating) - 3 * sd(rating)) & (rating < mean(rating) + 3 * sd(rating)))
    ggplot(data = grouped.data, aes(x = category, y = rating, fill = category)) +
      geom_boxplot() +
      theme(axis.text.x = element_blank(),
            axis.ticks.x = element_blank())
    
    
  })
  
  output$table <- renderDataTable({
    
  })
  
  output$cloud <- renderPlot({
    
  })
  
}

shinyServer (my.server)