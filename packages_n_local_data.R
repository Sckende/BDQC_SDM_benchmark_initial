#### Packages ####
# -------------- #
library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(htmltools)
library(gdalcubes)
library(rstac)
library(terra)
library(stringr)
library(ENMeval)

#### Local data ####
# ---------------- #

# Species data
# ------------
# species <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/original_maps")
spe <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/original_maps")

species <- vector()
for (i in c("bonasa", "catharus", "falcipennis", "junco", "melospiza", "poecile", "setophaga")) {
    spee <- spe[str_detect(spe, i)]
    species <- c(species, spee)
}
# species

# Several Qc proj for model maps
# ------------------------------
queb_eb <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_for_eBird_maps.gpkg")
# ------
queb_Vince <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_for_Vince_maps.gpkg")
qc_fus <- vect(st_union(queb_Vince))
# -----
queb_Max <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_for_Maxent_maps.gpkg")
qc_fus_Max <- vect(st_union(queb_Max))
