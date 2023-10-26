source("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/packages_n_local_data.R")

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

#### Creation de la zone d'etude ####
# --------------------------------- #

# Downloads polygons using package geodata
can <- gadm("CAN", level = 1, path = paste0(getwd(), "/source_data")) |> st_as_sf()
usa <- gadm("USA", level = 1, path = paste0(getwd(), "/source_data")) |> st_as_sf()
na <- rbind(can, usa)
na <- st_transform(na, 32618)

# keep Québec and bordering provinces/states as a buffer
region <- na[na$NAME_1 %in% c("Québec", "New Brunswick", "Maine", "Vermont", "New Hampshire", "New York", "Ontario", "Nova Scotia", "Prince Edward Island", "Massachusetts", "Connecticut", "Rhode Island"), ]

# split NF into different polygons
labrador <- ms_explode(na[na$NAME_1 %in% c("Newfoundland and Labrador"), ])
labrador <- labrador[which.max(st_area(labrador)), ] # keep Labarador
region <- rbind(region, labrador)
qc <- ms_simplify(region, 0.01)

# Add it to the study region
region <- rbind(region, labrador)

# Simplify polygons to make things faster
region <- ms_simplify(region, 0.005)
# Conversion proj carte Vincent
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")

region <- st_transform(region, crs = st_crs(m_vin))
# st_write(region, "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_interet_sdm.gpkg", append = F)

region_fus <- st_union(region) |> st_as_sf()
# Conversion proj carte Vincent
region_fus <- st_transform(region_fus, crs = st_crs(m_vin))
# st_write(region_fus, "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_FUSION_interet_sdm.gpkg", append = T)

# lakes
lakes <- ne_download(scale = "medium", type = "lakes", destdir = paste0(getwd(), "/source_data"), category = "physical", returnclass = "sf") |> st_transform(32618)
lakes <- st_filter(lakes, region)
# Conversion proj carte Vincent
lakes <- st_transform(lakes, crs = st_crs(m_vin))
# st_write(lakes, "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_LAKES_interet_sdm.gpkg", append = F)

#### Creation de l'ensemble de rasters de predicteurs environnementaux ####
# ----------------------------------------------------------------------- #
#### Environmental data raster from Francois Rousseu ####
# ----------------------------------------------------- #
pred <- rast("/home/claire/BDQC-GEOBON/data/predictors.tif")
## --> keep tmean [1], prec [2], xxx_esa [39:51], elevation [20], truggedness [19]
pred2 <- subset(pred, c(1, 2, 19, 20, 39:51))
# Crop for the study region


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
list_Maxent <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps/", full.names = T)

for (i in list_Maxent) {
    map <- rast(i)
    map <- project(map, m_vin)
    print("DONE")
    writeRaster(map,
        i,
        overwrite = T
    )
}

#### Homogénéisation proj occurrences avec proj cartes ####
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")

list_occ <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/sf_converted_occ_pres_only2", full.names = T)
list_occ_short <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/sf_converted_occ_pres_only2", full.names = F)

for (i in 1:length(list_occ)) {
    occs <- st_read(list_occ[i])
    occs_tran <- st_transform(occs, crs = st_crs(m_vin))

    st_write(occs_tran,
        paste0("//home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/occurrences/", list_occ_short[i]),
        overwrite = T
    )
    print("DONE")
}

#### Homogénéisation proj pseudo-abs Maxent avec proj cartes ####
m_vin <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")

list_pabs <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs", full.names = T)
list_pabs_short <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs", full.names = F)

for (i in 1:length(list_pabs)) {
    pabs <- st_read(list_pabs[i])
    pabs_tran <- st_transform(pabs, crs = st_crs(m_vin))

    st_write(pabs_tran,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/pseudo_abs/", list_pabs_short[i]),
        append = F
    )
    print("DONE")
}

#### Croppage des cartes selon les limites du QC pour le TdeB ####
# ------------------------------------------------- #
qc_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QUEBEC_Unique_poly.gpkg")

list_Maxent <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps", full.names = T)
list_Maxent_short <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps", full.names = F)

for (i in 1:length(list_Maxent)) {
    map <- rast(list_Maxent[i])
    map_crop <- terra::crop(map, qc_fus)
    map_mask <- mask(map_crop, qc_fus)
    writeRaster(map_mask,
        paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/TdB_bench_maps/maps/CROPPED_", list_Maxent_short[i]),
        overwrite = T
    )
    print("DONE")
}

#### Tri des espèces pour les cartes eBird ####
# ------------------------------------------- #
# species absent of ebird -> aegolius_funereus & asio_flammeus
sp_ls <- list.files("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/Bellavance_maps")
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

        # writeRaster(
        #     eb_qc2,
        #     paste0("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps/", spe, "_range.tif"),
        #     overwrite = TRUE
        # )
    }
}


#### Creation du background points with no bias ####
# ------------------------------------------------ #
predictors <- terra::rast("/home/claire/BDQC-GEOBON/data/predictors.tif")[[1]]
region_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_FUSION_interet_sdm.gpkg")
region_fus <- st_transform(region_fus, crs = st_crs(predictors))
plot(predictors)
plot(st_geometry(region_fus), add = T)

env_to_sample <- crop(predictors, vect(region_fus), mask = T)

plot(env_to_sample, add = T, col = "grey")

bg <- raptr::randomPoints(
    env_to_sample,
    n = 10000
) %>% as.data.frame()

bg <- st_as_sf(bg,
    coords = c("x", "y"),
    crs = st_crs(env_to_sample)
)
x11()
plot(env_to_sample)
plot(bg, add = T)

st_write(
    bg,
    "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/Maxent_bbox_QC_bg_points_noBias.gpkg",
    append = F
)
