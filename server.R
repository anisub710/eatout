library(leaflet)
library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
#install.package('geojsonio')
library(geojsonio)
library(sp)

#holds the api key for Yelp Fusion.
source("accessToken.R")

#reads geojson data for the United States outline.
states <- geojsonio::geojson_read("json/us-states.json", what = "sp")

#reads accumulated data containing average rating for each county in the United States
restaurant.ratings <- read.csv("data/yelpRatings.csv", stringsAsFactors = FALSE)
colnames(restaurant.ratings) <- c("ratings", "county", "NAME")
restaurant.ratings <- restaurant.ratings %>% 
                      group_by(NAME) %>% 
                      summarise(ratings = mean(ratings))

#To prevent unsuccessful merge due to different spelling.
restaurant.ratings[12, 1] <- "Hawaii"
restaurant.data <- merge(states, restaurant.ratings)

#palette for the choropleth map.
pal <- colorBin(palette = "Reds", 
                domain = restaurant.data$ratings, 
                bins = c(3.13, 3.36, 3.59, 3.82, 4.06))

#Makes labels for the choropleth map when hovered over each state.
labels <- sprintf("<strong>%s</strong><br/><strong> Rating: </strong> <em>%g</em> ",
                as.character(restaurant.data$NAME), round(restaurant.data$ratings, 2)) %>% 
                lapply(htmltools::HTML)



#makes the choropleth map
 choropleth <- leaflet(restaurant.data) %>%
              setView(lng = -94, lat = 37.45, zoom = 4) %>% 
              addTiles()%>%
               addLegend(pal = pal, values = ~density, opacity = 0.7, title = "Ratings",
                           position = "bottomright") %>% 
               addPolygons(fillColor = ~pal(ratings),
                          weight = 1, #2
                          opacity = 1,
                          color = "white",
                          dashArray = "1",
                          fillOpacity = 0.7,
                          highlight = highlightOptions(
                                        weight = 3, #5
                                        color = "#666",
                                        dashArray = "",
                                        fillOpacity = 0.7,
                                        bringToFront = TRUE),
                          label = labels,
                          labelOptions = labelOptions(
                                          style = list("font-weight" = "normal", padding = "3px 8px"),
                                          textsize = "15px",
                                          direction = "auto"))   

choropleth 

#reads data for table
static.data <- read.csv("data/yelpRatings.csv")
data.names <- c("rating", "county", "state")
colnames(static.data) <- data.names

#groups data by state
state.data <- static.data %>% 
              group_by(state) %>% 
              summarise('Average Rating' = round(mean(rating), 2))

server <- function(input, output){
  
  #Gets the response based on input location
  locationData <- reactive({
    query = list(location = input$chosen.location,open_now = input$open)
    response <- GET ("https://api.yelp.com/v3/businesses/search?term=food&limit=50", query = query, add_headers(Authorization = access.code))
    body <- fromJSON(content(response, "text"))
    data <- body$businesses
    return(data)
  })
  
  # getBounds <- reactive({
  #   if(input$chosen.location == "")
  #     print(input$map_bounds)
  # })
  
  #creates map based on data above. Displays choropleth map if 
  #nothing is entered in the filters.
  output$map <- renderLeaflet({
    coordinates <- locationData()$coordinates  
    if(is.null(coordinates)){
      m <- choropleth
    }else{
      m <- leaflet() %>%
        addTiles() %>%  # Add default OpenStreetMap map tiles
        addMarkers(lng= coordinates$longitude, lat= coordinates$latitude, popup= paste(locationData()$name, "<br>",
                                                                                       "Price:", locationData()$price,"<br>",
                                                                                      "Rating:", locationData()$rating))
    }
  
  return(m)
  })
  
  #Outputs table with state and rating when choropleth map is displayed,
  #and outputs table with restaurant and rating when filters are used.
  output$table <- renderDataTable({
    if(is.null(locationData())){
      state.data.names <- c("State", "Average Rating")
      colnames(state.data) <- state.data.names
      return(state.data)
    }else{
    final.frame <- locationData() %>% select(name, rating)
    return(final.frame)
    }
  })
  
}

shinyServer(server)