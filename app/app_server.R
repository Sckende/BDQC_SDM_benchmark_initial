server <- function(input, output, session) {
    #### Map selection
    # eBird
    path_map_ebird <- reactive({
        paste0(input$species_select, "_range.tif")
    })

    # Vincent - INLA
    id_feat_Vince <- reactive({
        paste0(input$species_select, "_", input$inla_sortie, "_2017")
    })

    # Maxent
    path_map_Maxent <- reactive({
        paste0("/home/claire/BDQC-GEOBON/SDM_Maxent_results/Narval_first_test/", input$species_select, "_", input$Maxent_sortie, "_1-2_QC-buffer_Maxent-jar.rds")
    })

    #### Map visualization
    # eBird
    output$map_eBird <- renderPlot({
        if (input$species_select %in% c("aegolius_funereus", "asio_flammeus")) {
            mp <- terra::rast("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps/acanthis_flammea_range.tif")

            terra::plot(mp,
                col = "#edf5f5",
                axes = F,
                main = ""
            )
            plot(st_geometry(queb), axes = T, add = T)
        } else {
            mp <- terra::rast(paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps/", path_map_ebird()))

            terra::plot(mp,
                axes = F,
                main = "Abondance"
            )
            plot(st_geometry(queb_eb), add = T, border = "grey")
        }
    })

    # Vincent
    output$map_Vince <- renderPlot({
        feat <- stac("https://acer.biodiversite-quebec.ca/stac/") %>%
            collections("oiseaux-nicheurs-qc") %>%
            items(feature_id = id_feat_Vince()) %>%
            get_request()

        tif_path <- feat$assets$data$href

        go_cat <- rast(stars::read_stars(paste0("/vsicurl/", tif_path),
            proxy = TRUE
        )) # stars object

        if (input$inla_sortie == "range") {
            terra::plot(go_cat,
                axes = F,
                main = "Occurrence",
                col = c("#f6f8e0", "#009999"),
                key.pos = NULL
            )

            legend("topright",
                fill = c("#f6f8e0", "#009999"),
                border = "black",
                legend = c("absente", "présente"),
                bty = "n"
            )

            plot(queb_Vince,
                add = T,
                border = "grey"
            )
        } else {
            rr_crop <- crop(go_cat, qc_fus)
            rr_mask <- mask(rr_crop, qc_fus)

            plot(rr_mask,
                axes = F,
                main = "Probabilité de présence"
            )
            plot(queb_Vince,
                add = T,
                border = "grey"
            )
        }
    })

    # Maxent
    output$map_Maxent <- renderPlot({
        predictions <- rast(readRDS(path_map_Maxent())@predictions[[1]])
        plot(predictions)

        pred_crop <- crop(predictions, qc_fus_Max)
        pred_mask <- mask(pred_crop, qc_fus_Max)

        plot(pred_mask,
            axes = F,
            main = "Probabilité de présence"
        )
        plot(st_geometry(queb_Max),
            add = T,
            border = "grey"
        )
    })
}
