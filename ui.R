library("knitr")
library("dplyr")
library("ggplot2")
library("httr")
library("jsonlite")
library("ggplot2")
library("shiny")
source ("project.R")
library ("DT")
library ("plotly")
# install.packages("shinyjs")
library("shinyjs")

########################
## SET UP FOR WIDGETS ##
########################

yelp.data <- read.csv("data/zip-code-data.csv")

cuisines <- c("asianfusion", "cajun", "caribbean", "cantonese", "chinese", "french", "german", "greek", "hawaiian", "italian", 
              "japanese", "korean", "mediterranean", "mexican", "newamerican", "taiwanese", "thai", 
              "tradamerican", "vietnamese")

prices <- c ("$", "$$", "$$$", "$$$$")
zip.codes <- c("All Locations", "98101", "98102", "98103", "98104", "98105", "98106", "98107", "98108", "98109",
               "98111", "98112", "98113", "98114", "98115", "98116", "98117", "98118", "98119",
               "98121", "98122", "98124", "98125", "98126", "98127", "98129",
               "98131", "98132", "98133", "98134", "98136", "98139",
               "98141", "98144", "98145", "98146", "98154", "98161", "98164", "98165",
               "98170", "98174", "98175", "98177", "98178", "98181", "98185",
               "98190", "98191", "98194", "98195", "98199")
data <- read.csv ("data/zip-code-data.csv", stringsAsFactors = FALSE)
data <- data %>%
  filter (is.na (price) != TRUE)
ratings <- unique (data$rating)
ratings <- sort (ratings)

################
## MY UI CODE ##
################

my.ui <- fluidPage (
  includeCSS("styles.css"),
  
  navbarPage (p ("INFO 201 Application"),
          
              tabPanel ("Home", id = "home-page", p (class = "center", tags$img (src = "www/logo.svg", width = "250px", height = "250px")), h1 ("Welcome!", class = "center"), 
                        p (class = "center", "This application explores the Yelp Fusion API ( for more details ", a ("click here", href = "https://www.google.com"),
                        ") to answer the question:"), p (id = "main-ques", class = "center", "What factors make a successful business (food restaraunt)?"),
                        p (class = "center", "Below details the specific elements of a restaraunt our team explored. You can click the above tags to
                        view how we answered these questions"),
                        tags$ul (class = "center", 
                                 tags$li (class = "index", "Location: Does restaraunt locations influence the rating?"), 
                                 tags$li (class = "index", em ("Opening/Closing Times:"), br(), "Is the opening and closing times of a restaraunt related to a restaraunt's success?"), 
                                 tags$li (class = "index", "Cuisine: "),
                                 tags$li (class = "index", "Price:", br(), "Does food price determine a business' success rate?"))),
              
              tabPanel ("About", h2 ("About", class = "center"), 
                        h3 ("The Project", class = "center divider"),
                        p (class = "center", em ("Title of application"), " was created for our INFO 201 (Technical Foundations of Informatics) assignment with Professor Joel Ross.
                           As a group, we were challenged to create our own application that would answer several critical questions
                           about a specific dataset. The API of our choosing was the Yelp Fusion API because the dataset provided
                           interesting data about food."),
                        h3 ("The Team", class = "center divider"),
                        tags$div (id = "about-section", 
                                  tags$div (id = "about-img", tags$img (class = "img-icon", src = "www/elisa.jpg"),
                                            tags$img (class = "img-icon", src = "www/elisa.jpg"),
                                            tags$img (class = "img-icon", src = "www/elisa.jpg")),
                                  tags$ul (id = "about-info",
                                           tags$li ("Elisa Truong"), tags$ul (tags$li ("Major: Intending HCDE or Design"), tags$li ("Year: 2nd"),
                                                                              tags$li ("Fun Fact: I love food, K-dramas and photography.")),
                                           tags$li ("Itsumi Niiyake"), tags$ul (tags$li ("Major: Industrial Engineer"), tags$li ("Year: 2nd"),
                                                                                tags$li ("Interest")),
                                           tags$li ("Tyler Muromoto"), tags$ul (tags$li ("Major: Intended Informatics"), tags$li ("Year: 2nd"),
                                                                                tags$li ("Interest")))
                        )),
              
              tabPanel ("Search", DTOutput ("output.all")),
              
             ##### Person assigned to 
             tabPanel ("Location",
                       titlePanel ("Title"),
                       p ("Which locations are more likely for a business to fail?")),
             
             
             tabPanel ("Price",
                       
                       titlePanel ("Food Prices"),
                       
                       sidebarLayout(
                         
                         sidebarPanel (
                           p ("Question:"), h4 ("Does food price determine a business' success rate?"), 
                           p ("Alter the graph (on right) with the widgets below."), hr (),
                           selectInput ("location", label = "Pick a zip code in the Seattle area to analyze:", choices = zip.codes),
                           checkboxGroupInput ("rating", label = "Specify a rating to analyze:", choices = ratings, selected = ratings),
                           checkboxGroupInput ("price", label = "Choose a price to analyze:", choices = prices, selected = prices)
                         ),
                         
                         mainPanel (
                           
                           tabsetPanel (
                             tabPanel ("Plot",
                               h3 ("Food Prices Association with Restaraunt Ratings"),
                               plotOutput ("price.plot")                
                             ),
                             
                             tabPanel ("Observation Table", br(), DTOutput ("priced.restaraunts")),
                             
                             tabPanel ( "Analysis",
                                        h3 ("Analysis"), 
                                        strong ("Background Information"),
                                        p ("In this section, our group analyzed whether food prices determined a business' success. This
                                           is an interesting question because food prices determine whether an individual 
                                           would choose to eat at the restaraunt over another. Most individuals tend to go to restaraunts
                                           that are cheaper, but does that mean the business' have quality food and are successful?
                                           We defined success as the overall rating individuals gave a business where
                                           a rating of 5.0 indicates a very successful business."), 
                                        strong ("The Data"), 
                                        p ("Analyzing the data for all locations (i.e. all locations in Seattle) support the idea that 
                                           more expensive food prices do not equate to a successful businesses. While there is a larger
                                           amount of data for low food priced restaraunts, low priced restaraunts seem to have
                                           better ratings in comparison to more expensive restaraunts. The low priced restaraunts are the
                                           only restaraunts recieving five star ratings. There are several additional observations we can also draw from this chart.
                                           Restaraunts charging their customers more for food do not recieve any ratings lower than 3.5.
                                           Also there are way more low priced ($ and $$) restaraunts in the Seattle area than there are expensive or high class
                                           restaraunts. The data suggests, though we cannot draw conclusive information, that a more
                                           successful business (operationally defined as the restaraunt's rating) in Seattle may be associated with lower food prices."), 
                                        strong ("Limitations"), 
                                        p ("The data reveals several interesting aspects about the relationship between
                                           food prices and ratings, but we cannot draw a causal relation for several reasons.
                                           The sample sizes attained for each independent variable are not the same; it is
                                           clear that there are more nonexpensive restaraunts than expensive restaraunts.
                                           Thus, it is plausible that if we attain equal sample sizes that are randomly chosen
                                           that the outcome of this data analysis would be different.")))),
                         position = "left",
                         fluid = TRUE
                         
                       )),
             
             tabPanel ("Cuisine",
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
             ),
             
             tabPanel ("Hours",
                       titlePanel ("Restaraunt Hours"),
                       sidebarLayout(
                         sidebarPanel (
                           p ("Question:"), h4 ("Is the opening and closing times of a restaraunt
                                                related to a restaraunt's success?"), hr (),
                           p ("Manipulate the visualization by clicking the legend for a specific value you'd
                              like to see or click and dragging a specific area to zoom in.")                         ),
                         mainPanel (
                           tabsetPanel (
                             tabPanel ("Opening Hours", h3 ("Opening Hours and Restaraunt Ratings"),
                                       p ("The graph reveals data on the number of restaraunts which opens at a specific time
                                          on average based on the ratings. Thus by interacting with the graph you can
                                          analyze the most common times that 5.0 rated or a specific rated restaraunts you are interested in
                                          are open.", em ("Note: The times are based on a 24 hour time format.")), plotlyOutput ("open.hour.graph")),
                             tabPanel ("Closing Hours", h3 ("Closing Hours and Restaraunt Ratings"), 
                                       p ("The graph reveals data on the number of restaraunts which closes at a specific time
                                          on average based on the ratings. Thus by interacting with the graph you can
                                          analyze the most common times that 5.0 rated or a specific rated restaraunts you are interested in
                                          are closed.", em ("Note: The times are based on a 24 hour time format.")), plotlyOutput ("close.hour.graph")),
                             tabPanel ("Analysis", h3 ("Analysis"), strong ("Background Information"),
                                       p ("In this section, we analyzed whether opening or closing times
                                          were related to the restaraunt's success. A successful business
                                          was operationally defined as the overall rating of a business
                                          because a rating considers the quality of food, service, and
                                          environment that a restaraunt has. Additionally, a higher rating
                                          tends to attract more customers. Thus, our group defined a
                                          successful business as having a high rating. Analyzing
                                          a restaraunt's opening and closing time is an interesting aspect
                                          that possibly contributes to a restaraunts success because
                                          having a longer opening time may mean more money to gain during
                                          those hours or more importantly an opportunity for more people
                                          to visit the restaraunt."), strong ("The Data"),
                                       p ("One apparent observation is evident"))
                           )
                           
                         ),
                         position = "left",
                         fluid = TRUE
                       )
                       
             ),
             
             tabPanel ("Conclusion", h2 ("Conclusion", class = "center"),
                       p ("Blah, blah"))
  )
)

shinyUI (my.ui)
