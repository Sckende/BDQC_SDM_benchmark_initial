library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(htmltools)
library(gdalcubes)
library(rstac)
library(terra)



species <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/original_maps")


# occs <-
queb <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_raster_Vince.gpkg")

ui <- dashboardPage(
  dashboardHeader(title = "Explorateur de SDMs"),
  dashboardSidebar(width = "0px"),
  dashboardBody(
    # First row
    fluidRow(
      box(
        title = "choix",
        width = 4,
        selectInput("maps_Vincent",
          label = "SDMs Vincent",
          choices = species
        )
      ),
      box(
        title = "carte e-bird",
        width = 8
      )
    ),
    # Second row
    fluidRow(
      box(
        title = "carte INLA - auto-corrélation spatiale",
        width = 6,
        plotOutput("map_Vince")
      ),
      box(
        title = "carte mapSPecies",
        width = 6
      )
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
    plot(go_cat,
      axes = TRUE,
      main = "",
      col = c("#f6f8e0", "#009999"),
      legend = FALSE
    )

    legend("topright",
      fill = c("#f6f8e0", "#009999"),
      border = "black",
      legend = c("absente", "présente"),
      bty = "n"
    )
  })


  plot(st_geometry(queb), axes = T, add = T)
}
shinyApp(ui, server)



# aegolius_funereus
# aegolius_acadicus
# asia otus
# tympanuchus_phasianellus
