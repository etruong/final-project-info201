source ("project.R")
library ("maps")

map.data <- map_data ("state")
ggplot (map.data) +
  geom_polygon (mapping = aes (x = long, y = long))

my.server <- function (input, output, session) {
  
}

shinyServer (my.server)