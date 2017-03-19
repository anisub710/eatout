library(leaflet)
library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
#install.packages('geojsonio')
library(geojsonio)
#install.packages('plotly')
library(plotly)
library(sp)

#containing apiKey.
source("accessToken.R")

ui <- fluidPage(#theme = "style.css",
  includeCSS("www/style.css"),
  includeScript("www/script.js"),
  #top navigation bar
  navbarPage("EATOUT"),
  leafletOutput('map'), #plots map
  div(id = "arrow_container",
    p("Restaurant Data"),
    a(href = "#arrow_link",id = "arrow_link",
        img(id = "down_arrow", src = "down_arrow.png", width = "auto", height = "auto", align = "center")
      )
  ),
  h2("Current Data", id="data_title"),
  dataTableOutput('table'), #data table reactive to map visualization
  
  #panel with control widgets and pie chart
  absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                draggable = FALSE, top = 60, left = "auto", right = 20, bottom = "auto",
                width = "500px", height = "auto",
                h4("Welcome!"),
                p(id = "intro", "This is a web application created using the Yelp Fusion API showing average ratings of each state, and allowing users to navigate through addresses to search for restaurants corresponding to that address."),
                p(a("Link to Yelp Fusion API",href="https://www.yelp.com/developers", target="_blank")),
                textInput('chosen.location', label = "Location", placeholder = "Enter a city, zip code or address"),
                checkboxInput('open', label = "Only Currently Open?", value = FALSE),
                a(href="..", "Go back to Choropleth Map"), #links back to choropleth
                plotlyOutput("pie") #pie chart
  ),
  div(id = "footer",
      h5("\"When in doubt, eat out!\" "),
      h5("EatOut Inc."),
      h6(a("Github",href="https://github.com/ask710/eatout", target="_blank"))
  )
)

shinyUI(ui)