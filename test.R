# This file can be used to test code you may want to use for your code. This file is otherwise not needed

source("project.R")
yelp.data <- read.csv("data/zip-code-data.csv")

cusines <- c("American", "caribbean", "Chinese", "French", "German", "Greek", "Indian", "Italian", 
             "Japanese", "Mediterranean", "Mexican", "Thai", "Vietnamese")

zip.codes <- c("98101", "98102", "98103", "98104", "98105", "98106", "98107", "98108", "98109",
               "98111", "98112", "98113", "98114", "98115", "98116", "98117", "98118", "98119",
               "98121", "98122", "98124", "98125", "98126", "98127", "98129",
               "98131", "98132", "98133", "98134", "98136", "98139",
               "98141", "98144", "98145", "98146", "98154", "98161", "98164", "98165",
               "98170", "98174", "98175", "98177", "98178", "98181", "98185",
               "98190", "98191", "98194", "98195", "98199")


resource <- "businesses/search"
# query.params <- list(term = "restaurants", location = paste("Seattle, Washington, 98103"), limit = 50)

