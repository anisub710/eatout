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


source("accessToken.R")


ui <- fluidPage(#theme = "style.css",
  includeCSS("www/style.css"),
  #includeScript("https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"),
  includeScript("www/script.js"),
  #tags$head(
  #  tags$script(rel = "stylesheet", type = "text/css", href = "style.css")
  #),
  
  navbarPage("EATOUT"),
    leafletOutput('map'),
    div(id = "arrow_container",
      p("Restaurant Data"),
      a(href = "#arrow_link",id = "arrow_link",
          img(id = "down_arrow", src = "down_arrow.png", width = "auto", height = "auto", align = "center")
        )
    ),
    h2("Current Data", id="data_title"),
    dataTableOutput('table'),
    absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                  draggable = FALSE, top = 60, left = "auto", right = 20, bottom = "auto",
                  width = "auto", height = "auto",
                  textInput('chosen.location', label = "Location", placeholder = "Enter a city, zip code or address"),
                  checkboxInput('open', label = "Only Currently Open?", value = FALSE),
                  a(href="..", "Go back to Chloropleth Map"),
                  plotlyOutput("pie")
                  #checkboxInput('choropleth', "Go back to choropleth map?", value = FALSE)
    ),
    div(id = "footer",
        h5("\"When in doubt, eat out!\" "),
        h5("B) EatOut Inc.")
    )

)

shinyUI(ui)