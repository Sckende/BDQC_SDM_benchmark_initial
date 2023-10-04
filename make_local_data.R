library(sf)
library(terra)

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


#### Transfo projection carte region Qc ####
# --------------------------------------- #

# Transf for eBird maps
# ---------------------
qc <- st_read("/home/claire/BDQC-GEOBON/data/QUEBEC_regions/sf_CERQ_SHP/QUEBEC_CR_NIV_01.gpkg")
plot(st_geometry(qc), axes = T)

eb_map <- terra::rast("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps/acanthis_flammea_range.tif")
plot(eb_map)

qc2 <- st_transform(qc, crs = st_crs(eb_map))
plot(eb_map)
plot(st_geometry(qc2), add = T)

# st_write(qc2,
#          "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_for_eBird_maps.gpkg")

# Transf for INLA - Vince maps
# ----------------------------
r <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")
rr <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_pocc_2017.tif")

st_crs(r) == st_crs(rr)
st_crs(r) == st_crs(qc)

qc3 <- st_transform(qc, crs = st_crs(r))
st_crs(r) == st_crs(qc3)

x11()
par(mfrow = c(1, 2))
plot(rr)
plot(st_geometry(qc3) / 1000, axes = T)

plot(r, col = c("#f6f8e0", "#009999"), legend = F)
plot(st_geometry(qc3) / 1000, add = T)
qc4 <- st_geometry(qc3) / 1000

qc_fus <- vect(st_union(qc4)) # to obtain an unique spatVector polygon

rr_crop <- crop(rr, qc_fus)
rr_mask <- mask(rr_crop, qc_fus)

plot(rr_mask)
plot(qc4, add = T) # ==> OK!

# Test avec stars object
sta <- rast(stars::read_stars("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_pocc_2017.tif",
    proxy = TRUE
)) # stars object

rr_crop <- crop(sta, qc_fus)
rr_mask <- mask(rr_crop, qc_fus)

plot(rr_mask)
plot(qc4, add = T) # ==> OK!

# st_write(qc4, "/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_for_Vince_maps.gpkg", append = F)

queb <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_raster_Vince.gpkg")
plot(st_geometry(queb), axes = T, add = T)



#### Traitement des cartes ebird ####
# ---------------------------------- #
# Conversion Qc projection
map_eb <- terra::rast("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/source_data/ebird/Corvus_corax_eb.tif")
queb <- st_read("/home/claire/BDQC-GEOBON/data/QUEBEC_regions/sf_CERQ_SHP/QUEBEC_CR_NIV_01.gpkg")
queb2 <- st_transform(queb, crs = st_crs(map_eb))
st_crs(map_eb) == st_crs(queb2)

qc_fus <- vect(st_union(queb2)) # to obtain an unique spatVector polygon


# species list
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
