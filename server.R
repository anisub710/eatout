library(leaflet)
library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
#install.packages('geojsonio')
#install.packages('plotly')
library(geojsonio)
library(plotly)
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
  addProviderTiles(providers$CartoDB.Positron) %>%
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
    query <- list(location = input$chosen.location,open_now = input$open)
    response <- GET ("https://api.yelp.com/v3/businesses/search?term=food&limit=50", query = query, add_headers(Authorization = access.code))
    body <- fromJSON(content(response, "text"))
    data <- body$businesses
    return(data)
  })
  
  #Gets the response data based on clicked state.
  locationDataByBounds <- reactive({
    click.coordinates <- input$map_shape_click
    location.bound <- list(latitude = click.coordinates$lat, longitude = click.coordinates$lng, open_now = input$open)
    bounds.response <- GET ("https://api.yelp.com/v3/businesses/search?term=food&limit=50", query = location.bound, add_headers(Authorization = access.code))
    bound.body <- fromJSON(content(bounds.response, "text"))
    bound.data <- bound.body$businesses
    return(bound.data)
  })
  
  #creates map based on data above. Displays choropleth map if 
  #nothing is entered in the filters.
  
  output$map <- renderLeaflet({
    
    if(input$chosen.location == ""){
      if(is.null(input$map_shape_click)){  
        m <- choropleth
      }
      else{
        data.bound <- locationDataByBounds()
        rest.coordinates <- data.bound$coordinates 
        m <- leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron) %>% 
          addMarkers(lng= rest.coordinates$longitude, lat= rest.coordinates$latitude, popup= paste(paste0("<a href='",data.bound$url,"'>",data.bound$name,"</a>"), "<br>",
                                                                                                   "Price:", data.bound$price,"<br>",
                                                                                                   "Rating:", data.bound$rating, "<br>",
                                                                                                   "<img src='", data.bound$image_url, "'/>")
          )
      }
    }else{
      coordinates <- locationData()$coordinates  
      m <- leaflet() %>%
        addProviderTiles(providers$CartoDB.Positron) %>% 
        addMarkers(lng= coordinates$longitude, lat= coordinates$latitude, popup= paste(paste0("<a href='",locationData()$url,"'>",locationData()$name,"</a>"), "<br>",
                                                                                       "Price:", locationData()$price,"<br>",
                                                                                       "Rating:", locationData()$rating, "<br>",
                                                                                       "<img src='", locationData()$image_url, "'/>")
        )
      return(m)

    }
  })
  
  
  
  #Outputs table with state and rating when choropleth map is displayed,
  #and outputs table with restaurant and rating when filters are used.
  output$table <- renderDataTable({
    if(is.null(locationData())){
      if(is.null(input$map_shape_click)){
        state.data.names <- c("State", "Average Rating")
        colnames(state.data) <- state.data.names
        return(state.data)
      }
      else{
        table <- locationDataByBounds() %>% select(name, rating)
        return(table)
      }
    }else{
      
      final.frame <- locationData() %>% select(name, rating)
      return(final.frame)
      
      
    }
    
    
    return(m)
  })
  
  output$pie <- renderPlotly({
    if(input$chosen.location == ""){
        if(is.null(input$map_shape_click)){
          p <- NULL
        }
        else{
        data.categories <- locationDataByBounds()
        data.categories <- data.frame(tolower(matrix(unlist(data.categories$categories), byrow = TRUE)))
        colnames(data.categories) <- "Food_Category"
        data.categories <- group_by(data.categories, Food_Category) %>% summarise('Count' = n()) %>% arrange(-Count)
        data.categories <- head(data.categories)
        
        p <- plot_ly(data.categories, labels = ~Food_Category, values = ~Count, type = 'pie', textposition = 'inside',
                     textinfo = 'label+percent',
                     insidetextfont = list(color = '#FFFFFF '),
                     hoverinfo = 'text',
                     text = ~paste(Count, 'Places')) %>%
          layout(xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 showlegend = FALSE)
        }
    }
    else{
        data.categories <- locationData()
        data.categories <- data.frame(tolower(matrix(unlist(data.categories$categories), byrow = TRUE)))
        colnames(data.categories) <- "Food_Category"
        data.categories <- group_by(data.categories, Food_Category) %>% summarise('Count' = n()) %>% arrange(-Count)
        data.categories <- head(data.categories)
        
        p <- plot_ly(data.categories, labels = ~Food_Category, values = ~Count, type = 'pie', textposition = 'inside',
                     textinfo = 'label+percent',
                     insidetextfont = list(color = '#FFFFFF '),
                     hoverinfo = 'text',
                     text = ~paste(Count, 'Places')) %>%
          layout(xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 showlegend = FALSE)
    }
    return(p)
  })
  
}

shinyServer(server)