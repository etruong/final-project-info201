source ("project.R")

########################
## SET UP FOR WIDGETS ##
########################

cusines <- c("American", "caribbean", "Chinese", "French", "German", "Greek", "Indian", "Italian", 
            "Japanese", "Mediterranean", "Mexican", "Thai", "Vietnamese")

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
  
  navbarPage ("INFO 201 Application",
          
              tabPanel ("Home", id = "about-pg", tags$img (src = "logo-2.jpg", width = "100px", height = "100px"), h1 ("Welcome!"), p ("This application explores the Yelp Fusion
                                                     API ( for more details ", a ("click here", href = "https://www.google.com"),
                                                     ") to answer the question about specific elements of a restaraunt in", strong ("Seattle"),
                                                     "."),
                        p ("Below details the specific elements of a restaraunt our team explored. You can click the above tags to
                           view how we answered these questions"),
                        tags$ul (tags$li ("Location"), tags$li ("Times"), tags$li ("Cuisine"))),
              
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
                       titlePanel ("Title")
                       #h2("What types of cuisines are more successful in Seattle?"),
                       #sidebarLayout(
                      #   radioButtons('visual',
                       #             choices = c("Boxplot", "Table", "Cloud")),
                        # selectInput('cuisine', 
                         #            choices = cuisines)
                       ),
             
             tabPanel ("Restaraunt Name",
                       titlePanel ("Length of Restaraunt Name"),
                       sidebarLayout (
                         
                         sidebarPanel (
                           p ("Question:"), h4 ("Is the length of a restaraunt's name related
                                                   to a restaraunt's success?"), hr (),
                           selectInput ("location.name", label = "Pick a zip code in the Seattle area to analyze:", choices = zip.codes),
                           actionButton ("all.location", label = "View All Locations"), br (), br(),
                           sliderInput ("length", label = "Choose", min = 0, max = 100, value = 0)
                           
                         ),
                         
                         mainPanel (
                           
                         ),
                         position = "left",
                         fluid = TRUE
                       )
                       ),
             
             tabPanel ("Hours",
                       titlePanel ("")
                       
             ),
             
             tabPanel ("About", h2 ("The Team"),
                       tags$img (src = "", alt = ""),
                       tags$ul (
                         tags$li ("Elisa Truong"), tags$ul (tags$li ("Major: Intending HCDE or Design"), tags$li ("Year: 2nd"),
                                                            tags$li ("My interest")),
                         tags$li ("Itsumi Niiyake"), tags$ul (tags$li ("Major: Industrial Engineer"), tags$li ("Year: 2nd"),
                                                              tags$li ("Interest")),
                         tags$li ("Itsumi Niiyake"), tags$ul (tags$li ("Major: Industrial Engineer"), tags$li ("Year: 2nd"),
                                                              tags$li ("Interest"))))
  )
)

shinyUI (my.ui)