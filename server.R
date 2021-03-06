############
## Set Up ##
############

# downloads all the packages required for application
source ("project.R")

# reads and sets up the dataset to be used to display 
# opening and closing times graph/information
combine.data <- read.csv ("data/combine-hour-zip-code-data.csv", 
                          stringsAsFactors = FALSE) 
combine.data <- select (combine.data, id, name, rating, start, end, 
                        is.overnight, location.zip_code) %>%
  mutate (start.n = round (start / 100), end.n = round (end / 100)) %>%
  select (id, name, rating, start.n, end.n, is.overnight, location.zip_code)
ratings <- unique (combine.data$rating) %>%
  sort ()

zip.code.data <- read.csv("data/zip-code-data.csv")

# Only gets the data that has review counts greater than 100 for 
# more reliable data
zip.code.filtered <- filter(zip.code.data, review_count >= 100)

# If there's time, we could also take a look at the correlation 
# between the number of reviews and the rating
yelp.data <- read.csv("data/zip-code-data.csv", stringsAsFactors = FALSE)
cuisines <- str_cap_words(c("asianfusion", "cajun", "caribbean", "cantonese", "chinese", "french", "german", "greek", "hawaiian", "italian", 
              "japanese", "korean", "mediterranean", "mexican", "newamerican", "taiwanese", "thai", 
              "tradamerican", "vietnamese"))

yelp.data$category <- str_cap_words(yelp.data$category)

yelp.data <- distinct(yelp.data, id, name, review_count, rating, price, 
                      phone, coordinates.latitude, coordinates.longitude, 
                      location.address1, location.city, location.zip_code, 
                      location.country, location.state, category)

my.server <- function (input, output, session) {

  cuisine.data <- reactiveValues()
  cuisine.data$curr.data <- na.omit(yelp.data %>%
                                    filter(category %in% cuisines) %>%
                                    select(name, category, rating, review_count))

  
  ####################
  ## Search Section ##
  ####################
  
  # returns and outputs a searchable and interactive table of 
  # the applications dataset
  output$output.all <- renderDT ({
    data <- read.csv ("data/zip-code-data.csv", stringsAsFactors = FALSE)
    data <- select (data, name, rating, price, location.address1, 
                    location.zip_code, url)
    data <- unique (data)
    return (data)
  })
  
  #########################
  ## Food Prices Section ##
  #########################
  
  # returns the yelp dataset with the information filtered according to
  # the widgets in the food price section
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

  # returns a bar graph of the food price dataset with the
  # specified preferences indicated
  output$price.plot <- renderPlot ({
    data <- price.data () %>%
      filter (price %in% input$price) %>%
      filter (rating %in% input$rating)
    
    price.graph <- ggplot (data) +
      geom_bar (mapping = aes (x = price, fill = factor(rating)), 
                position = "dodge") +
      scale_fill_brewer (type = "qual", palette = 8, name = "Rating")
    return (price.graph)
  })
  
  # returns an interactive data table of the dataset for food
  # prices filtered based on the user's filteration adjustments
  output$priced.restaraunts <- renderDT ({
    data <- price.data () %>%
      filter (price %in% input$price) %>%
      filter (rating %in% input$rating) %>%
      select (name, rating, price)
    return (data)
  })
  
  # returns and outputs a summary of the price data
  output$price.summary <- renderTable ({
    data <- price.data ()
    summary.data <- group_by (data, price) %>%
      summarise (average_rating = mean (rating), 
                 standard_deviation = sd (rating),
                 median_rating = median (rating))
    return (summary.data)
  })
  
  ###################
  ## Hours Section ##
  ###################
  
  # returns and outputs the interactive opening hours histogram
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
  
  # returns and outputs the interactive closing hours histogram
  output$close.hour.graph <- renderPlotly ({
    plot <- plot_ly(alpha = 0.6) 
    for (i in 1:length(ratings)) {
      test <- filter (combine.data, rating == ratings[i])
      plot <- plot %>% add_histogram (x = test$end.n, name = ratings[i])
    }
    x <- list (
      title = "Closing Times (hr)",
      showticklabels = TRUE,
      ticks = "outside"
    )
    y <- list (
      title = "Count",
      showticklabels = TRUE,
      ticks = "outside"
    )
    plot <- plot %>%
      layout (barmode = "overlay", xaxis = x, yaxis = y)
    return (plot)
  })
  
  #####################
  ## Cuisine Section ##
  #####################
  
  # filters yelp data with the user's chosen cuisine choices
  # to use for the cuisine section
  observeEvent(input$cuisine, {
      cuisine.data$curr.data <- yelp.data %>%
                                filter(category %in% input$cuisine) %>%
                                select(name, category, rating, review_count)
  })
  
  # updates the checkbox group input to select
  # all values if select button pressed
  observeEvent(input$select.all, {
    updateCheckboxGroupInput(session,
                             'cuisine',
                             label = "Cuisine", 
                             choices = cuisines,
                             selected = cuisines)
    cuisine.data$curr.data <- yelp.data %>%
      filter(category %in% input$cuisine) %>%
      select(name, category, rating, review_count)
  })
  
  # updates the checkbox group input to deselect
  # all values if deselect button pressed
  observeEvent(input$deselect.all, {
    updateCheckboxGroupInput(session,
                             'cuisine',
                             label = "Cuisine", 
                             choices = cuisines,
                             selected = c())
    
    cuisine.data$curr.data <- yelp.data %>%
      filter(category %in% input$cuisine) %>%
      select(name, category, rating, review_count)
  })
  
  # outputs a box and whiskers plot of cuisine data
  output$cuisine.plot <- renderPlot({
    grouped.data <- cuisine.data$curr.data %>%
      group_by(category) %>%
      filter((rating > mean(rating) - 3 * sd(rating)) & (rating < mean(rating) + 3 * sd(rating)))
    plot <- ggplot(data = grouped.data, aes(x = category, y = rating, fill = category)) +
      geom_boxplot() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1),
            axis.ticks.x = element_blank()) +
      labs(title = "Cuisine vs Rating", x = "Cuisine", y = "Rating")
    return(plot)
  })
  
  # outputs and returns a summary table in the cuisine
  # section
  output$cuisine.table <- renderDataTable({
    summary <- cuisine.data$curr.data %>%
      group_by(category) %>%
      summarise(max = round(max(rating), 2), min = round(min(rating), 2), mean = round(mean(rating), 2), 
                median = round(median(rating), 2), std.dev = round(sd(rating), 2), variance = round(var(rating), 2), 
                range = max(rating) - min(rating))
    colnames(summary) <- c("Cuisine", "Max", "Min", "Mean", "Median", "Standard Deviatation", "Variance", "Range")
    return(summary)
  })
  
  # outputs and returns the cuisines section conclusion
  output$cuisine.conclusion <- renderText({
    summary <- cuisine.data$curr.data %>%
      group_by(category) %>%
      summarise(max = round(max(rating), 2), min = round(min(rating), 2), mean = round(mean(rating), 2), 
                median = round(median(rating), 2), std.dev = round(sd(rating), 2), variance = round(var(rating), 2), 
                range = max(rating) - min(rating))
    min.mean <- min(summary$mean)
    max.mean <- max(summary$mean)
    min.mean.cat <- summary[summary$mean == min.mean, ][1, 1]
    max.mean.cat <- summary[summary$mean == max.mean, 1]
    
    min.range <- min(summary$range)
    max.range <- max(summary$range)
    min.range.cat <- summary[summary$range == min.range, 1]
    max.range.cat <- summary[summary$range == max.range, 1]
    
    min.var <- min(summary$variance)
    max.var <- max(summary$variance)
    min.var.cat <- summary[summary$variance == min.var, 1]
    max.var.cat <- summary[summary$variance == max.var, 1]
    conclusion <- paste0("From an average rating metric, the values range from, ", min.mean, " to ", max.mean, ". With respect to the
                         gathered data, ", max.mean.cat, " food is highly rated on average, while ", min.mean.cat, " food is
                         lowly rated on average.
                         With respect to range, ", max.range.cat, " restaurants had the highest range in their
                         ratings (", max.range, "), while ",  min.range.cat[1, 1], " and ", min.range.cat[2, 1], " cuisines had
                         less range (", min.range, "). With respect to variance, ", max.var.cat, " restaurants had the highest
                         variance (", max.var,"), while, ", min.var.cat," cuisines had the lowest variance (", min.var, ").
                         A reason for the large variance in ", max.var.cat, " is can be attributed to the wide spread of values
                         the ratings take.")
    return(conclusion)
  })
  
  ######################
  ## Location Section ##
  ######################
  
  table.data <- reactive({
    
    Sys.setlocale(locale="C")
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
  output$location.table <- renderTable({
    return(table.data())
  })
  
  # Creates a plot
  plot <- reactive({
    input.vector <- c(input$zip.code)
    
    # Gets the average rating for each of the selected input
    zip.rate.data <- filter(zip.code.filtered, location.zip_code %in% input.vector)
    averages.rate <- group_by(zip.rate.data, location.zip_code) %>%
      summarise(mean = mean(rating))
    
    
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
  output$location.plot <- renderPlot({
    return(plot())
  })
  
  # Creates a sentence about the average ratings for the selected zip codes
  output$info <- renderText({
    input.vector <- c(input$zip.code)
    if(length(input.vector) == 0){
      sentence <- paste0("Click on a zip code")
    } else {
      zip.rate.data <- filter(zip.code.filtered, location.zip_code %in% input.vector)
      averages.rate <- group_by(zip.rate.data, location.zip_code) %>%
        summarise(mean = round(mean(rating), digits = 3))
      
      # Finds the zip code that has the max and min averages
      averages.rate.max.row <- which(averages.rate[,"mean"] == max(averages.rate[,"mean"]))
      averages.rate.min.row <- which(averages.rate[,"mean"] == min(averages.rate[,"mean"]))
      average.rate.max <- averages.rate[averages.rate.max.row, "location.zip_code"]
      average.rate.min <- averages.rate[averages.rate.min.row, "location.zip_code"]
      
      # Prints out information about the zip code and average rating for it
      validate(
        need(length(input.vector) == 0, "Click on a zip code")
      )
      sentence <- paste0("The selected zip code(s) is/are: ", 
                         averages.rate[,"location.zip_code"], " and the corresponding rating(s) is/are: ",
                         averages.rate[,"mean"],
                         ". The highest rating was ", average.rate.max, ", and the lowest rating was ", average.rate.min, 
                         ". The lower the rating, the more likely the business will fail, so the business in, ", average.rate.min,
                         " is most likely to fail out of the selected zip codes.")
    }
    
    
    return(sentence)
  })

}

shinyServer (my.server)