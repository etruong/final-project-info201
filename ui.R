library ("shiny")

my.ui <- fluidPage (
  
  includeCSS("styles.css"),
  
  navbarPage ("INFO 201 Application",
          
              tabPanel ("About", id = "about-pg", h1 ("Welcome!"), p ("This application explores the Yelp Fusion
                                                     API ( for more details ", a ("click here", href = "https://www.google.com"),
                                                     ") to answer the question about specific elements of a restaraunt in", strong ("Seattle"),
                                                     "."),
                        p ("Below details the specific elements of a restaraunt our team explored. You can click the above tags to
                           view how we answered these questions"),
                        tags$ul (tags$li ("Location"), tags$li ("Times"), tags$li ("Cuisine"))),
              tabPanel ("Creators", h2 ("The Team"),
                        tags$img (src = "", alt = ""),
                        tags$ul (
                          tags$li ("Elisa Truong"), tags$ul (tags$li ("Major: Intending HCDE or Design"), tags$li ("Year: 2nd"),
                                                             tags$li ("My interest")),
                          tags$li ("Itsumi Niiyake"), tags$ul (tags$li ("Major: Industrial Engineer"), tags$li ("Year: 2nd"),
                                                               tags$li ("Interest")),
                          tags$li ("Itsumi Niiyake"), tags$ul (tags$li ("Major: Industrial Engineer"), tags$li ("Year: 2nd"),
                                                               tags$li ("Interest")))),
              
             ##### Person assigned to 
             tabPanel ("Location",
                       titlePanel ("Title"),
                       p ("Which locations are more likely for a business to fail?")),
             
             
             tabPanel ("Opening Hours",
                       titlePanel ("Title"),
                       p ("Which locations are ideal for vegetarians?"),
                       sidebarLayout(
                         
                         sidebarPanel (
                           textInput ("hello", label = "hello")
                         ),
                         
                         mainPanel (
                           
                         ),
                         position = "left",
                         fluid = TRUE
                         
                       )),
             
             tabPanel ("Cuisine",
                       titlePanel("Title"),
                       p ("Description of question attempting to answer"))
  )
)

shinyUI (my.ui)