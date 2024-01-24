source("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/packages_n_local_data.R")

#### Récuperation des cartes de Vincent - range ####
# ------------------------------------------------- #
# Conservation uniquement de la derniere couche - 2015-2019 => 2017

# file_name <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/terra_converted_maps")

# for (i in seq_along(file_name)) {
#     spe <- file_name[i]

#     path <- paste("/home/claire/BDQC-GEOBON/data/Bellavance_data/terra_converted_maps/", spe, sep = "")

#     if(length(list.files(path)) != 0) {

#             maps <- terra::rast(paste(path, "/maps_range.tif", sep = ""))
#             mp <- maps[[dim(maps)[3]]]
#             writeRaster(mp,
#                 paste("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/Bellavance_maps/", spe, "_range.tif", sep = ""),
#                 overwrite=TRUE)

#             print(spe)

#     }
# }

#### Tri des espèces pour les cartes eBird ####
# ------------------------------------------- #
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")

# species absent of ebird -> aegolius_funereus & asio_flammeus
sp_ls <- list.files("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/Bellavance_maps")
sp <- stringr::str_remove(sp_ls, "_range.tif")

for (i in seq_along(sp)) {
    spe <- sp[i]
    spe_eb <- stringr::str_to_title(spe)

    if (spe %in% c("aegolius_funereus", "asio_flammeus")) {
        print(paste0("No data in eBird for ", spe))
    } else if (!file.exists(paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/ebird/", spe_eb, "_eb.tif"))) {
        print(paste("---> species ", spe, " doesn't exist in eBird maps"))
    } else {
        print(paste0("-----------------> ", spe))

        eb_map <- terra::rast(paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/ebird/", spe_eb, "_eb.tif"))
        eb_qc <- crop(eb_map, qc_fus)
        eb_qc2 <- mask(eb_qc, qc_fus)

        eb_qc2 <- st_transform(eb_qc2, crs = st_crs())

        # writeRaster(
        #     eb_qc2,
        #     paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps/", spe, "_range.tif"),
        #     overwrite = TRUE
        # )
    }
}

#### Creation de la zone d'etude ####
# --------------------------------- #

# Downloads polygons using package geodata
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")

can <- gadm("CAN", level = 1, path = paste0(getwd(), "/source_data")) |> st_as_sf()
usa <- gadm("USA", level = 1, path = paste0(getwd(), "/source_data")) |> st_as_sf()
na <- rbind(can, usa)
# na <- st_transform(na, 32618)
na <- st_transform(na, st_crs(m_vin))


# keep Québec and bordering provinces/states as a buffer
region <- na[na$NAME_1 %in% c("Québec", "New Brunswick", "Maine", "Vermont", "New Hampshire", "New York", "Ontario", "Nova Scotia", "Prince Edward Island", "Massachusetts", "Connecticut", "Rhode Island"), ]

# split NF into different polygons
labrador <- ms_explode(na[na$NAME_1 %in% c("Newfoundland and Labrador"), ])
labrador <- labrador[which.max(st_area(labrador)), ] # keep Labarador
region <- rbind(region, labrador)
qc <- ms_simplify(region, 0.01)

# Add it to the study region
region <- rbind(region, labrador)
# Conversion proj carte Vincent
# region <- st_transform(region, crs = st_crs(m_vin))

# Simplify polygons to make things faster
region_simpl <- ms_simplify(region, 0.005)
region_fus_simpl <- ms_simplify(st_union(st_geometry(region)), 0.005)

# st_write(region_simpl, "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_interet_sdm.gpkg", append = F)
# st_write(region_fus_simpl, "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_FUSION_interet_sdm.gpkg", append = F)

# lakes
lakes <- ne_download(scale = "medium", type = "lakes", destdir = paste0(getwd(), "/source_data"), category = "physical", returnclass = "sf") |> st_transform(32618)
lakes <- st_filter(lakes, region)
# Conversion proj carte Vincent
lakes <- st_transform(lakes, crs = st_crs(m_vin))
# st_write(lakes, "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_LAKES_interet_sdm.gpkg", append = F)

lakes <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_LAKES_interet_sdm.gpkg")
qc_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QUEBEC_Unique_poly.gpkg")
st_crs(lakes) == st_crs(qc_fus)
lakes_qc <- st_intersection(lakes, qc_fus)

# st_write(lakes_qc, "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_LAKES_QC_sdm.gpkg", append = F)

#### Creation de l'ensemble de rasters de predicteurs environnementaux ####
# ----------------------------------------------------------------------- #
#### Environmental data raster from Francois Rousseu ####
# ----------------------------------------------------- #
pred <- rast("/home/claire/BDQC-GEOBON/data/Maxent/predictors.tif")
## --> keep tmean [1], prec [2], xxx_esa [39:51], elevation [20], truggedness [19]
pred2 <- subset(pred, c(1, 2, 19, 20, 39:51))

# Ajout des couches pour la composante autocorrelation spatiale
# x des centroides pour chaque pixel
x <- init(pred2[[1]], "x")
names(x) <- "x"

# y des centroides pour chaque pixel
y <- init(pred2[[1]], "y")
names(y) <- "y"

# interaction entre x & y
xy <- x * y
names(xy) <- "xy"

predictors <- c(pred2, x, y, xy)

# Crop for the study region
region_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_FUSION_interet_sdm.gpkg")
st_crs(region_fus) == st_crs(pred)
region_fus <- st_transform(region_fus, crs = st_crs(predictors))
pred_crop <- terra::crop(predictors, vect(region_fus))
pred_mask <- terra::mask(pred_crop, vect(region_fus))
x11()
plot(pred_mask[[20]], main = names(pred_mask[[20]]))
# writeRaster(pred_mask, "/home/claire/BDQC-GEOBON/data/Maxent/CROPPED_predictors.tif", overwrite = T)

#### Creation du background points with no bias ####
# ------------------------------------------------ #
predictors <- terra::rast("/home/claire/BDQC-GEOBON/data/Maxent/CROPPED_predictors.tif")[[1]]
X11()
plot(predictors)

bg <- raptr::randomPoints(
    predictors,
    n = 10000
) %>% as.data.frame()

bg <- st_as_sf(bg,
    coords = c("x", "y"),
    crs = st_crs(predictors)
)

plot(st_geometry(bg), add = T)

# st_write(
#     bg,
#     "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs/pseudo-abs_region_Maxent_noBias.gpkg",
#     append = F
# )



#### APRES RECUPERATION DES FICHIERS SUR NARVAL ####

#### Homogénéisation des projections des cartes ####
# ---------------------------------- #
# Utilisation de la proj des cartes de Vincent

## --> cartes eBird
# -----------------
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")

# cartes eBird
# ------------
list_ebird <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps", full.names = T)

for (i in list_ebird) {
    map <- rast(i)
    map <- project(map, m_vin)
    print("DONE")
    writeRaster(map,
        i,
        overwrite = T
    )
}

## --> cartes Maxent
# ------------------
list_Maxent <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/Narval_SDM_maps/", full.names = T)

for (i in list_Maxent) {
    map <- rast(i)
    map <- project(map, m_vin)
    print("DONE")
    writeRaster(map,
        i,
        overwrite = T
    )
}

#### Homogénéisation proj occurrences avec proj cartes & crop depending on reg_fus####
# ------------------------------------------------------ #
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")
region_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_FUSION_interet_sdm.gpkg")
qc_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QUEBEC_Unique_poly.gpkg")
wkt_region <- st_as_text(st_geometry(region_fus))
wkt_qc <- st_as_text(st_geometry(qc_fus))


list_occ <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/occurrences", full.names = T)
list_occ_short <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/occurrences", full.names = F)

for (i in 1:length(list_occ)) {
    occs <- st_read(list_occ[i], quiet = T)

    # Projection change
    occs_tran <- st_transform(occs, crs = st_crs(m_vin))
    occs_tran <- occs_tran[!duplicated(st_geometry(occs_tran)), ]

    st_write(occs_tran,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/occurrences/", list_occ_short[i]),
        append = F
    )
    # croppage des occurrences
    occs_crop_reg <- st_read(paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/occurrences/", list_occ_short[i]),
        quiet = T,
        wkt_filter = wkt_region
    )

    occs_crop_qc <- st_read(paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/occurrences/", list_occ_short[i]),
        quiet = T,
        wkt_filter = wkt_qc
    )

    st_write(occs_crop_reg,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/occurrences/CROPPED_", list_occ_short[i]),
        append = F,
        quiet = T
    )

    st_write(occs_crop_qc,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/occurrences/CROPPED_QC_", list_occ_short[i]),
        append = F,
        quiet = T
    )

    print(paste0("DONE ", i, "/", length(list_occ)))
}


#### Homogénéisation proj pseudo-abs Maxent avec proj cartes & crop depending on reg_fus ####
# ------------------------------------------------------------ #
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")
region_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_FUSION_interet_sdm.gpkg")
qc_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QUEBEC_Unique_poly.gpkg")
wkt_reg <- st_as_text(st_geometry(region_fus))
wkt_qc <- st_as_text(st_geometry(qc_fus))


list_pabs <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/pseudo_abs", full.names = T)
list_pabs_short <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/pseudo_abs", full.names = F)

for (i in 1:length(list_pabs)) {
    pabs <- st_read(list_pabs[i], quiet = T)

    # Projection change
    pabs_tran <- st_transform(pabs, crs = st_crs(m_vin))
    pabs_tran <- pabs[!duplicated(st_geometry(pabs)), ]

    st_write(pabs_tran,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs/", list_pabs_short[i]),
        append = F,
        quiet = T
    )
    # croppage des pseudo-abs selon la region d'etude
    pabs_crop_reg <- st_read(paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs/", list_pabs_short[i]),
        quiet = T,
        wkt_filter = wkt_reg
    )

    st_write(pabs_crop_reg,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs/CROPPED_REG_", list_pabs_short[i]),
        append = F,
        quiet = T
    )

    # croppage des pseudo-abs selon le Quebec
    pabs_crop_qc <- st_read(paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs/", list_pabs_short[i]),
        quiet = T,
        wkt_filter = wkt_qc
    )

    st_write(pabs_crop_qc,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs/CROPPED_QC_", list_pabs_short[i]),
        append = F,
        quiet = T
    )

    print(paste0("DONE ", i, "/", length(list_pabs)))
}

#### Croppage des cartes selon les limites du QC pour le TdeB ####
# ------------------------------------------------- #
qc_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QUEBEC_Unique_poly.gpkg")
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")

#### Maxent models
list_Maxent <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/Narval_SDM_maps/", full.names = T)
list_Maxent_short <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/Narval_SDM_maps/", full.names = F)

for (i in 1:length(list_Maxent)) {
    map <- rast(list_Maxent[i])
    # st_crs(map) == st_crs(qc_fus)
    map_crop <- terra::crop(map, qc_fus)
    map_mask <- mask(map_crop, qc_fus)
    writeRaster(map_mask,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps/CROPPED_QC_", list_Maxent_short[i]),
        overwrite = T
    )
    print(paste0(i, "/", length(list_Maxent), " ----> DONE"))
}

#### brt, ewlgcpSDM, randomForest models
list_model <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/BRT_MapSpecies_models", full.names = T)
list_model_short <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/BRT_MapSpecies_models", full.names = F)

for (i in 1:length(list_model)) {
    map <- rast(list_model[i])
    map <- project(map, m_vin)
    # st_crs(map) == st_crs(qc_fus)
    map_crop <- terra::crop(map, qc_fus)
    map_mask <- mask(map_crop, qc_fus)
    writeRaster(map_mask,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps/CROPPED_QC_", list_model_short[i]),
        overwrite = T
    )
    print(paste0(i, "/", length(list_model), " ----> DONE"))
}

#### Croppage des cartes selon les limites de la region d'etude (QC et al) pour le TdeB ####
# ------------------------------------------------- #
# region_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_FUSION_interet_sdm.gpkg")

# list_Maxent <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps", full.names = T)
# list_Maxent_short <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps", full.names = F)

# for (i in 1:length(list_Maxent)) {
#     # st_crs(map) == st_crs(region_fus)
#     map <- rast(list_Maxent[i])
#     map_crop <- terra::crop(map, region_fus)
#     map_mask <- mask(map_crop, region_fus)
#     writeRaster(map_mask,
#         paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps/CROPPED_", list_Maxent_short[i]),
#         overwrite = T
#     )
#     print("DONE")


#### Calcul de la richesse specifique ####
# ------------------------------------- #
species # to update with all bird species !

all_rast <- list()

for (i in seq_along(species)) {
    r <- terra::rast(paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/", species[i], "_range_2017.tif"))
    all_rast[[i]] <- r

    print(i)
}

stack_rast <- rast(all_rast)
rs <- sum(stack_rast)
x11()
plot(rs)
# writeRaster(rs,
#     "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/species_richness/INLA_range_2017.tif",
#     overwrite = T
# )
