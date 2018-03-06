#################
#     SET UP    #
#################

# Note: make sure you have access to the api key

library("knitr")
library("dplyr")
library("ggplot2")
library("httr")
library("jsonlite")
library("ggplot2")
library("shiny")

###############
#    CODE     #
###############

# given the endpoint (resource) and query parameters makes a request
# to the yelp api website returning data from yelp fusion api
GetContent <- function(resource, query.params) {
  source ("api-key.R")
  base.uri <- "https://api.yelp.com/v3/"
  resource.uri <- paste0(base.uri, resource)
  access <- paste("Bearer", api.key)
  response <- GET (resource.uri, add_headers(Authorization = access),
                   query = query.params)
  body <- content (response, "text")
  api.data <- fromJSON (body) 
  return (api.data)

}