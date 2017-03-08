library(leaflet)
library(shiny)
library(httr)
library(jsonlite)
library(dplyr)

source("accessToken.R")

ui <- fluidPage(#theme = "style.css",
  includeCSS("www/style.css"),
  #tags$head(
  #  tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  #),
  
  navbarPage("EATOUT"),
    leafletOutput('map'),
    tags$img(src = "img/down_arrow.png", width = "auto", height = "auto"),
    dataTableOutput('table'),
    absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                  draggable = FALSE, top = 60, left = "auto", right = 20, bottom = "auto",
                  width = "auto", height = "auto",
        textInput('chosen.location', label = "Location", placeholder = "Enter a city, zip code or address"),
        checkboxInput('open', label = "Only Currently Open?", value = FALSE)#,
        #checkboxInput('choropleth', "Go back to choropleth map?", value = FALSE)
      )

)

shinyUI(ui)