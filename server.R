library("knitr")
library("dplyr")
library("ggplot2")
library("httr")
library("jsonlite")
library("ggplot2")
library("shiny")
# For capitalize function
source ("project.R")
library ("DT")
library ("plotly")

combine.data <- read.csv ("data/combine-hour-zip-code-data.csv", stringsAsFactors = FALSE) 
combine.data <- select (combine.data, id, name, rating, start, end, is.overnight, location.zip_code) %>%
  mutate (start.n = round (start / 100), end.n = round (end / 100)) %>%
  select (id, name, rating, start.n, end.n, is.overnight, location.zip_code)
ratings <- unique (combine.data$rating) %>%
  sort ()

# If there's time, we could also take a look at the correlation between the number of reviews and the rating

yelp.data <- read.csv("data/zip-code-data.csv", stringsAsFactors = FALSE)
cuisines <- str_cap_words(c("asianfusion", "cajun", "caribbean", "cantonese", "chinese", "french", "german", "greek", "hawaiian", "italian", 
              "japanese", "korean", "mediterranean", "mexican", "newamerican", "taiwanese", "thai", 
              "tradamerican", "vietnamese"))
yelp.data$category <- str_cap_words(yelp.data$category)
yelp.data <- distinct(yelp.data, id, name, review_count, rating, price, 
                      phone, coordinates.latitude, coordinates.longitude, 
                      location.address1, location.city, location.zip_code, location.country, location.state, category)

my.server <- function (input, output, session) {
  
  data <- reactiveValues()
  # Search Section
  output$output.all <- renderDT ({
    data <- read.csv ("data/zip-code-data.csv", stringsAsFactors = FALSE)
    data <- select (data, name, rating, price, location.address1, location.zip_code, url)
    data <- unique (data)
    return (data)
  })
  
  # Food Prices Section
  # Questions: (1) when select and unselect by itself?
  #            (2) how to validate if no data is returned
  #            (3) if update options longer than other select all
  
  price.data <- reactive({
    data <- read.csv ("data/zip-code-data.csv", stringsAsFactors = FALSE)
    data <- select (data, id, name, rating, price, location.zip_code) %>%
      filter (is.na (price) != TRUE) 
    data <- unique (data)
    if (input$location != "All Locations") {
      data <- filter (data, location.zip_code == input$location)
    }
    return (data)
  })
  
   observe ({
     data <- price.data () %>%
       filter (price == input$price)
     ratings <- unique (data$rating) %>%
       sort ()
     select.ratings <- input$rating
     updateCheckboxGroupInput (session, "rating", choices = ratings, selected = input$rating)
   })
  
  output$price.plot <- renderPlot ({
    data <- price.data () %>%
      filter (price %in% input$price) %>%
      filter (rating %in% input$rating)
    
    price.graph <- ggplot (data) +
      geom_bar (mapping = aes (x = price, fill = factor(rating)), position = "dodge") +
      scale_fill_brewer (type = "qual", palette = 8, name = "Rating")
    return (price.graph)
  })
  
  output$priced.restaraunts <- renderDT ({
    data <- price.data () %>%
      filter (price %in% input$price) %>%
      filter (rating %in% input$rating) %>%
      select (name, rating, price)
    return (data)
  })
  
  # Hours Section
  output$open.hour.graph <- renderPlotly ({
    plot <- plot_ly(alpha = 0.6) 
    for (i in 1:length(ratings)) {
      test <- filter (combine.data, rating == ratings[i])
      plot <- plot %>% add_histogram (x = test$start.n, name = ratings[i])
    }
    x <- list(
      title = "Opening Times (hr)",
      showticklabels = TRUE,
      ticks = "outside"
    )
    y <- list(
      title = "Count",
      showticklabels = TRUE,
      ticks = "outside"
    )
    plot <- plot %>%
      layout(barmode = "overlay", xaxis =  x, yaxis = y)
    return (plot)
  })
  
  output$close.hour.graph <- renderPlotly ({
    plot <- plot_ly(alpha = 0.6) 
    for (i in 1:length(ratings)) {
      test <- filter (combine.data, rating == ratings[i])
      plot <- plot %>% add_histogram (x = test$end.n, name = ratings[i])
    }
    x <- list(
      title = "Closing Times (hr)",
      showticklabels = TRUE,
      ticks = "outside"
    )
    y <- list(
      title = "Count",
      showticklabels = TRUE,
      ticks = "outside"
    )
    plot <- plot %>%
      layout(barmode = "overlay", xaxis = x, yaxis = y)
    return (plot)
  })
  
  # Tyler's Page
  observeEvent(input$select.all, {
    updateCheckboxGroupInput(session,
                             'cuisine',
                             label = "Cuisine", 
                             choices = cuisines,
                             selected = cuisines)
  })
  
  observeEvent(input$deselect.all, {
    updateCheckboxGroupInput(session,
                             'cuisine',
                             label = "Cuisine", 
                             choices = cuisines,
                             selected = c())
  })
  
  output$plot <- renderPlot({
    curr.data <- na.omit(yelp.data %>%
                           filter(category %in% input$cuisine) %>%
                           select(name, category, rating, review_count))
    grouped.data <- curr.data %>%
      group_by(category) %>%
      filter((rating > mean(rating) - 3 * sd(rating)) & (rating < mean(rating) + 3 * sd(rating)))
    plot <- ggplot(data = grouped.data, aes(x = category, y = rating, fill = category)) +
      geom_boxplot() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1),
            axis.ticks.x = element_blank()) +
      labs(title = "Cuisine vs Rating", x = "Cuisine", y = "Rating")
    return(plot)
  })
  
  output$table <- renderDataTable({
    curr.data <- na.omit(yelp.data %>%
                           filter(category %in% input$cuisine) %>%
                           select(name, category, rating, review_count))
    summary <- curr.data %>%
      group_by(category) %>%
      summarise(max = round(max(rating), 2), min = round(min(rating), 2), mean = round(mean(rating), 2), 
                median = round(median(rating), 2), std.dev = round(sd(rating), 2), variance = round(var(rating), 2), 
                range = max(rating) - min(rating))
    colnames(summary) <- c("Cuisine", "Max", "Min", "Mean", "Median", "Standard Deviatation", "Variance", "Range")
    return(summary)
  })
  
  output$conclusion <- renderText({
    curr.data <- na.omit(yelp.data %>%
                           filter(review_count >= 100 & category %in% cuisines) %>%
                           select(name, category, rating, review_count))
    summary <- curr.data %>%
      group_by(category) %>%
      summarise(max = round(max(rating), 2), min = round(min(rating), 2), mean = round(mean(rating), 2), 
                median = round(median(rating), 2), std.dev = round(sd(rating), 2), variance = round(var(rating), 2), 
                range = max(rating) - min(rating))
    # View(summary)
    min.mean <- min(summary$mean)
    max.mean <- max(summary$mean)
    min.mean.cat <- summary[summary$mean == min.mean, ][1, 1]
    # min.mean.cat <- filter(summary, mean == min.mean) %>%
    #   select(category)
    max.mean.cat <- summary[summary$mean == max.mean, 1]
    
    min.range <- min(summary$range)
    max.range <- max(summary$range)
    min.range.cat <- summary[summary$range == min.range, 1]
    max.range.cat <- summary[summary$range == max.range, 1]
    
    min.var <- min(summary$variance)
    max.var <- max(summary$variance)
    min.var.cat <- summary[summary$variance == min.var, 1]
    max.var.cat <- summary[summary$variance == max.var, 1]
    conclusion <- paste0("A total of 581 restaurants were included in this analysis. From these, 577 were included in
                         the final result. The 4 restaurants were removed were considered outliers because their rating
                         was greater than 3 standard deviations above or below the mean.
                         From the types of cuisines and data analyzed, we can conclude that although there is not a significant
                         correlation between the cuisine and the rating, there are some cuisines that tend to fare better than others.
                         From an average rating metric, the values range from, ", min.mean, " to ", max.mean, ". With respect to the
                         gathered data, ", max.mean.cat, " food is highly rated on average, while ", min.mean.cat, " food is
                         lowly rated on average.
                         With respect to range, ", max.range.cat, " restaurants had the highest range in their
                         ratings (", max.range, "), while ",  min.range.cat, " and ", min.range.cat, " cuisines had
                         less range (", min.range, "). With respect to variance, ", max.var.cat, " restaurants had the highest
                         variance (", max.var,"), while, ", min.var.cat," cuisines had the lowest variance (", min.var, ").")
    return(conclusion)
  })
  
  output$scatter <- renderPlot({
    scatter <- ggplot(data = yelp.data, aes(x = rating, y = review_count, color = price)) +
      geom_point() +
      labs(title = "Review Count vs Rating", x = "Rating", y = "Review Count")
    return(scatter)
  })
    
}

shinyServer (my.server)

