source ("project.R")
library ("DT")
library ("plotly")
library("lettercase")

########################
## SET UP FOR WIDGETS ##
########################
library("shinyjs")

yelp.data <- read.csv("data/zip-code-data.csv", stringsAsFactors = FALSE)


cuisines <- str_cap_words(c("asianfusion", "cajun", "caribbean", "cantonese", "chinese", "french", "german", "greek", "hawaiian", "italian", 
                            "japanese", "korean", "mediterranean", "mexican", "newamerican", "taiwanese", "thai", 
                            "tradamerican", "vietnamese"))

yelp.data$category <- str_cap_words(yelp.data$category)
prices <- c ("$", "$$", "$$$", "$$$$")
zip.codes <- c("All Locations", "98101", "98102", "98103", "98104", "98105", "98106", "98107", "98108", "98109",
               "98111", "98112", "98113", "98114", "98115", "98116", "98117", "98118", "98119",
               "98121", "98122", "98124", "98125", "98126", "98127", "98129",
               "98131", "98132", "98133", "98134", "98136", "98139",
               "98141", "98144", "98145", "98146", "98154", "98161", "98164", "98165",
               "98170", "98174", "98175", "98177", "98178", "98181", "98185",
               "98190", "98191", "98194", "98195", "98199")

data <- read.csv ("data/zip-code-data.csv", stringsAsFactors = FALSE)
data <- distinct(yelp.data, id, name, review_count, rating, price, 
                 phone, coordinates.latitude, coordinates.longitude, 
                 location.address1, location.city, location.zip_code, 
                 location.country, location.state, category)

data <- data %>%
  filter (is.na (price) != TRUE)
ratings <- unique (data$rating)
ratings <- sort (ratings)

################
## MY UI CODE ##
################

my.ui <- fluidPage (
  
  includeCSS("styles.css"),
  
  navbarPage (p (id = "app-title", tags$img (src = "logo.svg", width = "20px", height = "20px"), "Food Success"),
              tabPanel ("Home", tags$div (id = "welcome-page",
                                          
                                          p (class = "center",
                                             tags$img (id = "main-logo", src = "logo.svg", width = "250px", height = "250px")), 
                                          h1 ("Welcome!", class = "center"), 
                                          p (class = "center", "This application explores the Yelp Fusion API ( for more details ", 
                                             a ("click here", href = "https://www.yelp.com/fusion"), ") to answer the question:"), 
                                          p (id = "main-ques", class = "center", "What factors make a successful food business?"),
                                          p (class = "center", "Start exploring this application by clicking the above tabs")), 
                        tags$div (id = "index-section",
                                  h4 (class = "center", id = "index-title", "Index"),
                                  tags$ul (tags$li (class = "index", "Location: Does restaraunt locations influence the rating?"), 
                                           tags$li (class = "index", "Opening/Closing Times: Is the opening and closing times of a 
                                                    restaraunt related to a restaraunt's success?"), 
                                           tags$li (class = "index", "Cuisine: Which Types of Cuisines Are Most Successful in Seattle?"),
                                           tags$li (class = "index", "Price: Does food price determine a business' success rate?")))),
              
              
              tabPanel ("About", h2 ("About", class = "center"), 
                        h3 ("The Project", class = "center divider"),
                        p (class = "center", em ("Food Success"), " was created for our INFO 201 (Technical Foundations of Informatics with Professor Joel Ross) assignment.
                           As a group, we were challenged to create our own application that would answer several critical questions
                           about a specific dataset. The API of our choosing was the Yelp Fusion API because the dataset provided
                           interesting data about food."),
                        h3("Why", class = "center"),
                        p(class = "center", "At first we wanted to look at which restaurants are good, so we could recommend consumers 
                          restaurants to try. But as we explored the dataset, we found a lot more information that we could analyze 
                          to determine elements of successful businesses."),
                        h3("Who", class = "center"),
                        p(class = "center", "We believe business owners can use the information from our questions to aid their decision making 
                          when choosing to start a restaurant. They can read about our questions and conclusions, but also filter 
                          for data they are interested in to draw their own conclusions."),
                        h3 ("The Team", class = "center divider"),
                        tags$div (id = "about-section", 
                                  tags$div (id = "about-img", tags$img (class = "img-icon", src = "elisa.jpg"),
                                            tags$img (class = "img-icon", src = "itsumi.jpg"),
                                            tags$img (class = "img-icon", src = "tyler.jpg")),
                                  tags$ul (id = "about-info",
                                           tags$li ("Elisa Truong"), tags$ul (tags$li ("Major: Intending HCDE or Design"), tags$li ("Year: 2nd"),
                                                                              tags$li ("Fun Fact: I love food, K-dramas and photography.")),
                                           
                                           tags$li ("Itsumi Niiyama"), tags$ul (tags$li ("Major: Industrial Engineer"), tags$li ("Year: 2nd"),
                                                                                
                                                                                tags$li ("Fun Fact: I love soccer, kettle corn and lord of the rings")),
                                           tags$li ("Tyler Muromoto"), tags$ul (tags$li ("Major: Intended Informatics"), tags$li ("Year: 2nd"),
                                                                                tags$li ("Fun Fact: I enjoy playing piano and skiing, and I still have a baby tooth")))
                        )),
              
              tabPanel ("Search", DTOutput ("output.all")),
              
              tabPanel ("Location",
                        titlePanel("Best and Worst Business Locations"),
                        sidebarLayout(
                          sidebarPanel(
                            p ("Question:"), h4 ("Which locations are more likely for a business to fail?"), hr (),
                            # Allows the user to choose one or more zip codes
                            checkboxGroupInput('zip.code', "Select one or more zip codes: ", c(98020, 98026, 98028, 98047, 98056,
                                                                                               98057, 98101, 98102, 98103, 98104,
                                                                                               98105, 98106, 98107, 98108, 98109,
                                                                                               98112, 98115, 98116, 98117, 98118,
                                                                                               98119, 98121, 98122, 98125, 98126,
                                                                                               98127, 98133, 98134, 98136, 98144,
                                                                                               98146, 98154, 98155, 98161, 98166,
                                                                                               98168, 98177, 98178, 98188, 98195,
                                                                                               98199, 98346), selected = c(98020))
                          ),
                          mainPanel(
                            tabsetPanel(
                              tabPanel("Plot", plotOutput('location.plot', click = 'plot.click')),
                              tabPanel("Table", tableOutput('location.table')),
                              tabPanel("Analysis",
                                       "     Looking at the relationship between the zip code of a business and
                                       its average rating provides information on whether the location of
                                       a business will affect the success of it. An assumption was made that the
                                       rating of a restaurant will affect the success of it because if a business has 
                                       bad ratings, customers will not go there leading to the failure of a business. 
                                       A bar graph was chosen to show the relationship between the rating and zip code
                                       because this allows users to easily visualize a relationship between them. However,
                                       from this data of zip codes in Seattle, it can be seen that many of the the average ratings are
                                       all very close. This means that the zip code does not have a noticable effect on the ratings 
                                       of a business. However, not all zip code ratings are similar, for example, the zip codes with the
                                       highest average rating are, 98028, 98056, 98155, 98178, 
                                       with a rating of 4.5. The zip code with the lowest average rating is 98127, with a rating of 
                                       2.5 which is noticably different from 4.5. In conclusion, the question of, which locations are more likely for a 
                                       business to fail, cannot be clearly answered with this data because most of the average
                                       ratings for each zip code are very similar. Neverless there is an outlier, the zip code 98127 that had 
                                       the lowest rating, which means that that business is most likely to fail."
                              )
                              ),
                            verbatimTextOutput("info"),
                            verbatimTextOutput("map.info")
                              )
                            )
                        
                          ),
              
              
              tabPanel ("Price",
                        
                        titlePanel ("Food Prices"),
                        
                        sidebarLayout(
                          
                          sidebarPanel (
                            p ("Question:"), h4 ("Does food price determine a business' success rate?"), 
                            p ("Alter the graph (on right) with the widgets below."), hr (),
                            selectInput ("location", label = "Pick a zip code in the Seattle area to analyze:", choices = zip.codes),
                            checkboxGroupInput("rating", label = "Specify a rating to analyze:", choices = ratings, selected = ratings),
                            checkboxGroupInput ("price", label = "Choose a price to analyze:", choices = prices, selected = prices)
                          ),
                          
                          mainPanel (
                            
                            tabsetPanel (
                              tabPanel ("Plot", conditionalPanel (
                                condition = "nrow (price.data()) != 0",
                                h3 ("Food Prices Association with Restaraunt Ratings"), 
                                em ("Note: if the graph becomes grey this indicates we currently have no data
                                    that match the preferences and zipcode specified"),
                                plotOutput ("price.plot")                
                                )),
                              
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
                        titlePanel("Most Successful Cuisines"),
                        sidebarLayout(
                          sidebarPanel(
                            p ("Question:"), h4 ("Which Types of Cuisines Are Most 
                                                 Successful in Seattle?"), hr (),
                            actionButton('select.all', label = "Select All"),
                            actionButton('deselect.all', label = "Deselect All"),
                            checkboxGroupInput('cuisine',
                                               label = h3("Cuisine"), 
                                               choices = cuisines,
                                               selected = cuisines)
                            ),
                          mainPanel(
                            tabsetPanel(
                              tabPanel ("Plot", plotOutput('cuisine.plot')),
                              tabPanel ("Table", dataTableOutput('cuisine.table')),
                              tabPanel ("Analysis",
                                        h3("Analysis"),
                                        strong("The Data"), 
                                        p( "The restaurants were rated on a scale of 1 of 5 stars, where 1 star is the worst and 
                                           5 stars is the best.A total of 581 restaurants were included in this analysis. 
                                           From these, 577 were included in the final result. The 4 restaurants were removed were 
                                           considered outliers because their rating was greater than 3 standard deviations above or 
                                           below the mean of their respective categories. The main metrics examiend are the mean
                                           ratings of the cuisines and the variance in ratings (the spread of the data)."),
                                        strong("The Numbers"),
                                        textOutput('cuisine.conclusion'),
                                        p(),
                                        strong("Conclusion"),
                                        p("Overall if one is looking to open a restaurant, French cuisines tend to fare better in 
                                          terms of consistency. However, from a raw average rating standpoint, Caribbean
                                          restaurants are highly rated, so one could make an argument that these restaurants
                                          are most successful. Thus, Caribbean and French cuisines are slightly more successful
                                          in the Seattle are."),
                                        p("Cajun food, on the other hand, tend to fare worse than Caribben and French food. They
                                          are rated rather low on average. Vietnamese food, though relatively highly rated, has
                                          high variance in ratings. Thus, when looking to start a business, one should consider
                                          the variance in ratings. There are a few possible reasons for high variance, one of 
                                          which would be the varying expectations of restaurants. This could be linked to the
                                          area in which the restaurant is, such as the competitiveness for the cuisine in an area
                                          or the average expectation level of a customer."),
                                        p("From the types of cuisines and data analyzed, we can conclude that although there is not a 
                                          significant correlation between the cuisine and the rating, there are some cuisines that 
                                          tend to fare better than others. Although there is no one cuisine that is definitively 
                                          better, there are some that are more successful in the Seattle area, and thus should have 
                                          influence in one's decision of starting a business.")
                                        )
                                        )
                                        )
                                        )
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
                                        p ("Overall, there does not seem like any significant relationship between opening and
                                           closing times and ratings, but there is evidently common features that 
                                           higher rated restaraunts have. Higher rated restaraunts seem to on average
                                           open later in the day (the evening) in comparison to lower rated restaraunts
                                           that open earlier. A likely explanation for this observation is that higher rated restaraunts
                                           because they are successful are able to afford opening later in the day while
                                           low rated restaraunts need to be open longer. This was one of the
                                           only unique observation when comparing high and low rated restaraunts.
                                           Common and expected observations is that a majority of the restaraunts opened
                                           around 10:30AM and closed around 8:00PM to 10:00PM."),
                                        strong ("Limitations"),
                                        p ("We are unable to draw conclusive information from this data for several reasons. 
                                           The data is based on the average times restaraunts are open or closed which was
                                           calculated by averaging the times a restaraunt closes within a week. A restaraunts
                                           closing and opening times can be significantly altered by outliers. For example,
                                           if a restaraunt were to open at 10:30AM for five days a week, but open at 5:00PM
                                           (or 17:00) on one day of the week, this could yield an observation that does not
                                           accurately display the data of one restaraunt. In a larger scale, if this occurred
                                           for all of the data, this could significantly skew our results. Our group made the
                                           assumption that this was not the case."))
                                        )
                            
                                        ),
                          position = "left",
                          fluid = TRUE
                                        )
                        
                                        ),
              
              tabPanel ("Conclusion", h2 ("Conclusion", class = "center"),
                        p("   The main overarching question that was being answered was \"What factors make a 
                                  successful food business?\". There were 4 questions that stemed off from this question which
                                  led to a conclusion for the main question. All of the data we looked at had no signficant correlation
                                  but we were able to draw some points that supports the answer to the main question. We concluded that
                                  a more successful business in Seattle may be associated with lower food prices, Caribbean or French cuisines,
                                  and opens later in the day. The zip code of a location has no correlation between if a business will fail or succeed.
                                  Even though there are small relationships, there are no major correlations that will fully help answer
                                  the question of what factors make a successful food business based on our data of Seattle. ")),
              
              tabPanel ("Source",
                        h2("Source", class = "center"),
                        p("Our group used the ", a("Yelp API", href = "https://www.yelp.com/fusion"), "to obtain data from restaurants in the Seattle area. This was done by requesting
                          data from Yelp multiple times until we had a sufficient sample size. Each call used a different Seattle zip
                          code in order to access restaurants all across Seattle. All zip codes were included in each API requests. From
                          there, we assigned each restaurant a cuisine based off the category section of the the data. From there, the 
                          data was saved to a csv file and filtered for unique entries (some duplicate entries were present). The data
                          used in the app is stored as a csv file and sourced each time the application is run. We chose to save 
                          the data this way instead of requesting data from the API because we have a limited number of API 
                          requests per day. Thus, we wanted to ensure that we would not go over the limit when running this application."))
                        )
                        )






shinyUI (my.ui)