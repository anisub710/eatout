library(leaflet)
library(shiny)
library(httr)
library(jsonlite)
library(maps)
library(ggplot2)
library(geojsonio)
library(plotly)

source("accessToken.R")

static.data <- read.csv("data/yelpRatings.csv")
data.names <- c("rating", "county", "state")
colnames(static.data) <- data.names
state.data <- static.data %>% group_by(state) %>% summarise('Average Rating' = mean(rating)) 

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
  
  output$table <- renderDataTable({
    if(is.null(locationData()))
      return(state.data)
    final.frame <- locationData() %>% select(name, rating)
    return(final.frame)
  })
  
  output$foodCategory <- renderPlotly({
    data.categories <- (locationData())
    data.categories <- data.frame(tolower(matrix(unlist(data.categories$categories), byrow = TRUE)))
    colnames(data.categories) <- "Food_Category"
    data.categories <- group_by(data.categories, Food_Category) %>% summarise('Count' = n()) %>% arrange(-Count)
    data.categories <- head(data.categories)
    p <- plot_ly(data.categories, labels = ~Food_Category, values = ~Count, type = 'pie', textposition = 'inside',
                 textinfo = 'label+percent',
                 insidetextfont = list(color = '#FFFFFF'),
                 hoverinfo = 'text',
                 text = ~paste(Count, 'Places')) %>%
      layout(title = 'Top 6 Food Categories in Given Location',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    return(p)
  })
  
}

shinyServer(server)