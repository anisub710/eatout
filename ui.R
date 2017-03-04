library(leaflet)
library(shiny)
library(httr)
library(jsonlite)

source("accessToken.R")

ui <- fluidPage(
  titlePanel("EatOut"),
  sidebarLayout(
    sidebarPanel(
      textInput('chosen.location', label = "Location", placeholder = "Enter a city, zip code or address")
    ),
    mainPanel(
      leafletOutput('map')
      #dataTableOutput('table')
    )
  )
)

shinyUI(ui)