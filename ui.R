library(leaflet)
library(shiny)
library(httr)
library(jsonlite)

source("accessToken.R")

ui <- fluidPage(
  titlePanel("EatOut"),
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