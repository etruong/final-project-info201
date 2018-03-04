source ("project.R")
library("DT")
?distinct
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
  
}

shinyServer (my.server)

#############
##  DEBUG  ##
#############
# 
data <- read.csv ("data/zip-code-data.csv", stringsAsFactors = FALSE)
data <- distinct (data, id, rating)
ratings <- unique (data$rating)
 
sample.data <- data.frame (id = "test", rating = 0)
for (i in ratings) {
  data <- read.csv ("data/zip-code-data.csv", stringsAsFactors = FALSE)
  data <- distinct (data, id, rating)
  data <- data %>%
    select (id, rating) %>%
    filter (rating == i)
 data <- sample_n (data, 100, replace = TRUE)
 sample.data <- bind_rows (sample.data, data)
}
sample.data <- filter (sample.data, id != "test")
id <- unique (sample.data$id)
View (id)
 
hours <- data.frame (id = "test", start = 1, end = 1, is.overnight = TRUE)
 
for (i in 101:348) {
  select <- id[i]
  test.data <- GetContent (paste0("businesses/", select), "")
  is.overnight <- test.data$hours$open[[1]]
  
  start <- as.double (is.overnight$start)
  start <- mean (start)
  
  end <- as.double (is.overnight$end)
  end <- mean (end)
   
 is.overnight <- is.overnight$is_overnight
 is.overnight <- TRUE %in% is.overnight
   
  retrieve.data <- data.frame (id = select, start, end, is.overnight)
  hours <- bind_rows (hours, retrieve.data)
  if (i == 100) {
    print ("done")
  }
}

 ?write.csv
 hours <- filter (hours, id != "test") %>%
   mutate (start.r = round (start), end.r = round (end))
 View (hours)
 write.csv (hours, file = "data/hours-data.csv")

 hour.data <- read.csv ("data/hours-data.csv", stringsAsFactors = FALSE)
 data <- read.csv ("data/zip-code-data.csv", stringsAsFactors = FALSE) 
overall.data <- left_join (data, hour.data, by = "id") %>%
  filter (is.na (start) != TRUE) %>%
  distinct ()
View (overall.data)
write.csv (overall.data, file = "data/combine-hour-zip-code-data.csv")
