library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(osmdata)
library(mapview)
library(htmltools)
library(gdalcubes)
library(rstac)



species <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/original_maps")
queb <-
  ui <- fluidPage(
    sidebarLayout(
      sidebarPanel(
        selectInput("maps_Vincent", label = "SDMs Vincent", choices = species)
      ),
      mainPanel(
        plotOutput("map_Vince")
      )
    )
  )






server <- function(input, output, session) {
  #### With stacCatalog
  id_feat <- reactive({
    paste0(input$maps_Vincent, "_range_2017")
  })

  output$map_Vince <- renderPlot({
    feat <- stac("https://acer.biodiversite-quebec.ca/stac/") %>%
      collections("oiseaux-nicheurs-qc") %>%
      items(feature_id = id_feat()) %>%
      get_request()

    tif_path <- feat$assets$data$href

    go_cat <- stars::read_stars(paste0("/vsicurl/", tif_path),
      proxy = TRUE
    )
    plot(go_cat)
  })
}
shinyApp(ui, server)
