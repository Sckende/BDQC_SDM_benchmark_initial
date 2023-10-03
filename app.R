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
        selectInput("species_select",
          label = "Species",
          choices = species
        )
      ),
      box(
        title = "carte e-bird",
        width = 4,
        plotOutput("map_eBird")
      ),
      box(
        title = "carte INLA - auto-corrélation spatiale",
        width = 4,
        plotOutput("map_Vince")
      )
    ),
    # Second row
    fluidRow(
      box(
        title = "carte mapSPecies",
        width = 6
      )
    )
  )
)


server <- function(input, output, session) {
  #### Map selection
  # eBird
  path_map_ebird <- reactive({
    paste0(input$species_select, "_range.tif")
  })

  # Vincent - INLA
  id_feat_Vince <- reactive({
    paste0(input$species_select, "_range_2017")
  })

  #### Map visualization
  # eBird
  output$map_eBird <- renderPlot({
    mp <- terra::rast(paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps/", path_map_ebird()))

    terra::plot(mp,
      axes = TRUE,
      main = ""
    )
  })

  # Vincent
  output$map_Vince <- renderPlot({
    feat <- stac("https://acer.biodiversite-quebec.ca/stac/") %>%
      collections("oiseaux-nicheurs-qc") %>%
      items(feature_id = id_feat_Vince()) %>%
      get_request()

    tif_path <- feat$assets$data$href

    go_cat <- stars::read_stars(paste0("/vsicurl/", tif_path),
      proxy = TRUE
    ) # stars object
    terra::plot(go_cat,
      axes = TRUE,
      main = "",
      col = c("#f6f8e0", "#009999"),
      key.pos = NULL
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
