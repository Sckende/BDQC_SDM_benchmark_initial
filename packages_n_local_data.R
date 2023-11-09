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
library(rgbif)
library(geodata)
library(rmapshaper)
library(rnaturalearth)

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
species

# Several Polygons for Qc
# -----------------------
qc <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QUEBEC_CR_NIV_01.gpkg")
qc_fus <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QUEBEC_Unique_poly.gpkg")

region <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_interet_sdm.gpkg")
lakes_qc <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/REGION_LAKES_QC_sdm.gpkg")
