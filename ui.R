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
  
  tabsetPanel(
    tabPanel('Map',
    leafletOutput('map'),
    dataTableOutput('table'),
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                  draggable = FALSE, top = 60, left = "auto", right = 20, bottom = "auto",
                  width = "auto", height = "auto",
  # sidebarLayout(
  #   sidebarPanel(
        textInput('chosen.location', label = "Location", placeholder = "Enter a city, zip code or address"),
        checkboxInput('open', label = "Only Currently Open?", value = FALSE)
      )

    )
  )
    
)



shinyUI(ui)