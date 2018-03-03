source('project.R')
library(dplyr)

cuisines <- c("asianfusion", "cajun", "caribbean", "cantonese", "chinese", "french", "german", "greek", "hawaiian", "italian", 
             "japanese", "korean", "mediterranean", "mexican", "newamerican", "taiwanese", "thai", 
             "tradamerican", "vietnamese")

# 98101 not included because it is used as an initial parameter
zip.codes <- c("98102", "98103", "98104", "98105", "98106", "98107", "98108", "98109",
               "98111", "98112", "98113", "98114", "98115", "98116", "98117", "98118", "98119",
               "98121", "98122", "98124", "98125", "98126", "98127", "98129",
               "98131", "98132", "98133", "98134", "98136", "98139",
               "98141", "98144", "98145", "98146", "98154", "98161", "98164", "98165",
               "98170", "98174", "98175", "98177", "98178", "98181", "98185",
               "98190", "98191", "98194", "98195", "98199")


zip.columns <- c("id", "name", "image_url", "is_closed", "url", "review_count", "rating", "price", "phone", "display_phone", 
             "distance", "coordinates.latitude", "coordinates.longitude", "location.address1", "location.city", 
             "location.zip_code", "location.country", "location.state")

resource <- "businesses/search"
initial.query.zip <- list(term = "restaurants", location = "Seattle, Washington, 98101", limit = 50)

zip.content <- GetContent(resource, initial.query.zip)
zip.data <- flatten(zip.content$businesses)


for (zip in zip.codes) {
  query.params <- list(term = "restaurants", location = paste("Seattle, Washington,", zip), limit = 50)
  content <- GetContent(resource, query.params)
  data <- flatten(content$businesses)
  zip.data <- rbind(zip.data, data)
}

to.csv.zip <- select(zip.data, id, name, image_url, is_closed, url, review_count, rating, price, 
                     phone, display_phone, distance, coordinates.latitude, coordinates.longitude, 
                     location.address1, location.city, location.zip_code, location.country, location.state)
categories <- zip.data$categories

for (num in 1:length(categories)) {
  categories[num] <- categories[[num]][1]
}

category <- c()

for (index in 1:length(categories)) {
  for (element in categories[[index]]) {
    if (element %in% cuisines) {
      category[[index]] <- element
      break
    }
  }
}

to.csv.zip$category <- category

write.csv(to.csv.zip, "data/zip-code-data.csv", row.names = FALSE)



# The following code is not needed but we'll keep it here of we want to use it for whatever reason later

# View(zip.data)
# 
# initial.query.cuisine <- list(term = "restaurants", location = "Seattle, Washington", categories = "American", limit = 50)
# 
# cuisine.content <- GetContent(resource, initial.query.cuisine)
# cuisine.data <- flatten(cuisine.content$businesses)
# 
# # Gather data based off categories in cuisines
# for(cuisine in cuisines) {
#   query.params <- list(term = "restaurants", location = "Seattle, Washington", categories = cuisine, limit = 50)
#   content <- GetContent(resource, query.params)
#   data <- flatten(content$businesses)
#   cusine.data <- rbind(cuisine.data, data)
# }
# 
# View(cuisine.data)
# write.csv(cuisine.data, "data/cuisine-data", row.names = FALSE)
