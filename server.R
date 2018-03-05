source ("project.R")
library ("DT")
library ("plotly")

combine.data <- read.csv ("data/combine-hour-zip-code-data.csv", stringsAsFactors = FALSE) 
combine.data <- select (combine.data, id, name, rating, start, end, is.overnight, location.zip_code) %>%
  mutate (start.n = round (start / 100), end.n = round (end / 100)) %>%
  select (id, name, rating, start.n, end.n, is.overnight, location.zip_code)
ratings <- unique (combine.data$rating) %>%
  sort ()

my.server <- function (input, output, session) {
  
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
  
}

shinyServer (my.server)

