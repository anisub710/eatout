library(leaflet)
library(shiny)
library(httr)
library(jsonlite)

source("accessToken.R")

ui <- fluidPage(#theme = "style.css",
  includeCSS("www/style.css"),
  #tags$head(
  #  tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  #),
  
  navbarPage("EATOUT"),
  tabsetPanel(
    tabPanel('Map',
    leafletOutput('map'),
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                  draggable = FALSE, top = 60, left = "auto", right = 20, bottom = "auto",
                  width = 330, height = "auto",
  # sidebarLayout(
  #   sidebarPanel(
        textInput('chosen.location', label = "Location", placeholder = "Enter a city, zip code or address")
      )
    )
  )
    
)


shinyUI(ui)