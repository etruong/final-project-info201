source("project.R")

cusines <- c("American", "caribbean", "Chinese", "French", "German", "Greek", "Indian", "Italian", 
             "Japanese", "Mediterranean", "Mexican", "Thai", "Vietnamese")

# 98101 not included because it is used at the first parameter
zip.codes <- c("98102", "98103", "98104", "98105", "98106", "98107", "98108", "98109",
               "98111", "98112", "98113", "98114", "98115", "98116", "98117", "98118", "98119",
               "98121", "98122", "98124", "98125", "98126", "98127", "98129",
               "98131", "98132", "98133", "98134", "98136", "98139",
               "98141", "98144", "98145", "98146", "98154", "98161", "98164", "98165",
               "98170", "98174", "98175", "98177", "98178", "98181", "98185",
               "98190", "98191", "98194", "98195", "98199")


resource <- "businesses/search"
initial.query <- list(term = "restaurants", location = "Seattle, Washington, 98101", limit = 50)

zip.content <- GetContent(resource, initial.query)
zip.data <- zip.content$businesses
rownames(zip.data) <- 1:50

query <- list(term = "restaurants", location = paste("Seattle, Washington, 98103"), limit = 50)
content2 <- GetContent(resource, query)
data2 <- content2$businesses
rownames(data2) <- 51:100


row1 <- zip.data[1, ]
rownames(row1) <- "bleh"
row51 <- data2[1, ]
rownames(row51) <- "test"
test <- rbind(row1, row51)
View(test)

View(data2)
View(zip.data)
combined <- rbind(zip.data, data2)
View(combined)

# for(zip in zip.codes) {
#   query.params <- list(term = "restaurants", location = paste("Seattle, Washington,", zip), limit = 50)
#   content <- GetContent(resource, query.params)
#   data <-- content$businesses
#   zip.data <- left_join(zip.data, data)
# }
