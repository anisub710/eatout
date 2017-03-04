library(leaflet)
library(shiny)
library(httr)
library(jsonlite)

source("accessToken.R")

server <- function(input, output){
  
  #Gets the response based on input location
  locationData <- reactive({
    query = list(location = input$chosen.location)
    response <-GET ("https://api.yelp.com/v3/businesses/search?term=food&limit=50", query = query, add_headers(Authorization = access.code))
    print(response)
    body <- fromJSON(content(response, "text"))
    data <- body$businesses
    return(data)
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
                                                                                       "Rating:", locationData()$rating))
    }
    return(m)
  })
  
}

shinyServer(server)