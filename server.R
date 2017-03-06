library(leaflet)
library(shiny)
library(httr)
library(jsonlite)
library(dplyr)

source("accessToken.R")
restaurant.ratings <- read.csv("data/yelpRatings.csv")
colnames(restaurant.ratings) <- c("ratings", "county", "state")

static.data <- read.csv("data/yelpRatings.csv")
data.names <- c("rating", "county", "state")
colnames(static.data) <- data.names
state.data <- static.data %>% group_by(state) %>% summarise('Average Rating' = mean(rating)) 

server <- function(input, output){
  
  #Gets the response based on input location
  locationData <- reactive({
    query = list(location = input$chosen.location)
    response <-GET ("https://api.yelp.com/v3/businesses/search?term=food&limit=50", query = query, add_headers(Authorization = access.code))
    body <- fromJSON(content(response, "text"))
    data <- body$businesses
    return(data)
  })
  
  getBounds <- reactive({
    if(input$chosen.location == "")
      print(input$map_bounds)
  })
  
  #creates map based on data above
  output$map <- renderLeaflet({
    coordinates <- locationData()$coordinates  
    if(is.null(coordinates)){
      m <- leaflet() %>% 
        addTiles() %>% 
        setView(lng = -94, lat = 37.45, zoom = 4)
    }
    
    else{
      m <- leaflet() %>%
        addTiles() %>%  # Add default OpenStreetMap map tiles
        addMarkers(lng= coordinates$longitude, lat= coordinates$latitude, popup= paste(locationData()$name, "<br>",
                                                                                       "Price:", locationData()$price,"<br>",
<<<<<<< HEAD
                                                                                      "Rating:", locationData()$rating))
=======
                                                                                       "Rating:", locationData()$rating))
>>>>>>> parker
    }
  
  return(m)
  })
  
<<<<<<< HEAD
=======
  output$table <- renderDataTable({
    if(is.null(locationData()))
      return(state.data)
    final.frame <- locationData() %>% select(name, rating)
    return(final.frame)
  })
>>>>>>> parker
  
}

shinyServer(server)