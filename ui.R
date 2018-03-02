library ("shiny")

cusines <- c("American", "caribbean", "Chinese", "French", "German", "Greek", "Indian", "Italian", 
            "Japanese", "Mediterranean", "Mexican", "Thai", "Vietnamese")


my.ui <- fluidPage (
  
  #includeCSS("styles.css"),
  
  navbarPage ("INFO 201 Application",
          
              tabPanel ("About", h1 ("Welcome!"), p ("This application explores the Yelp Fusion
                                                     API ( for more details ", a ("click here", href = "https://www.google.com"),
                                                     ") answering several analysis questions through visualizations and charts
                                                     of the API's data."),
                        p ("Below details the questions our team explored. You can click the above tags to
                           view how we answered these questions"),
                        tags$ul (
                          tags$li ("Failed Businesses"), tags$li ("Ideal Vegan Locations"), tags$li ("Question 3")),
                        h2 ("The Team"),
                        tags$img (src = "", alt = ""),
                        tags$ul (
                          tags$li ("Elisa Truong"), tags$li ("Major: Intending HCDE or Design"), tags$li ("Year: 2nd"),
                          tags$li ("My interest"))
                        ),
              
             ##### Person assigned to 
             tabPanel ("Question 1",
                       titlePanel ("Title"),
                       p ("Which locations are more likely for a business to fail?")),
             
             
             tabPanel ("Question 2",
                       titlePanel ("Title"),
                       p ("Which locations are ideal for vegetarians?")),
             
             tabPanel ("Question 3",
                       titlePanel("Title"),
                       h2("What types of cuisines are more successful in Seattle?"),
                       sidebarLayout(
                         radioButtons('visual',
                                    choices = c("Boxplot", "Table", "Cloud")),
                         selectInput('cuisine', 
                                     choices = cuisines)
                       ))
  )
)

shinyUI (my.ui)