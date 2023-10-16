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

#### Local data ####
# ---------------- #
# Data
species <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/original_maps")

queb_eb <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_for_eBird_maps.gpkg")
queb_Vince <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_for_Vince_maps.gpkg")
qc_fus <- vect(st_union(queb_Vince))
