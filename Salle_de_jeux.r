library(sf)
library(terra)

#### BROUILLON
species <- list.files("/home/claire/BDQC-GEOBON/data/Bellavance_data/original_maps")

input <- species[1]
id <- paste0(input, "_range_2017")
feat <- stac("https://acer.biodiversite-quebec.ca/stac/") %>%
  collections("oiseaux-nicheurs-qc") %>%
  items(feature_id = id) %>%
  get_request()

tif_path <- feat$assets$data$href

go_cat <- stars::read_stars(paste0("/vsicurl/", tif_path),
  proxy = TRUE
)
plot(go_cat)


r <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/acanthis_flammea_range_2017.tif")

r <- terra::rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/aegolius_funereus_range_2017.tif")

r
plot(r)


occs <- st_read("/home/claire/BDQC-GEOBON/data/Bellavance_data/total_occ_pres_only_versionR_UTM.gpkg",
  query = "SELECT * FROM total_occ_pres_only_versionR WHERE species='acanthis_flammea'"
)

qc <- st_read("/home/claire/BDQC-GEOBON/data/QUEBEC_regions/sf_CERQ_SHP/QUEBEC_CR_NIV_01.gpkg")
st_crs(qc) == st_crs(r)
qc2 <- st_transform(qc, crs = st_crs(r))
st_crs(qc2) == st_crs(r)
qc3 <- st_transform(qc2, "+units=km")


x11()
par(mfrow = c(1, 2))
plot(r, axes = T)
plot(st_geometry(qc2), axes = T)

plot(r, axes = T)
plot(st_geometry(qc2) / 1000, add = TRUE)

test <- st_transform(qc, crs = feat$properties$"proj:wkt2")

feat$properties$"proj:wkt2"

plot(st_geometry(occs[1000, ]), add = T)
st_crs(r) == st_crs(occs)
occs2 <- st_transform(occs, crs = st_crs(r))
occs3 <- st_transform(occs2, "+units=km")
st_crs(r) == st_crs(occs2)

x11()
par(mfrow = c(1, 2))
plot(r)
plot(st_geometry(occs2) / 100, axes = T)

plot(st_geometry(qc2), axes = T)
plot(st_geometry(occs2), axes = T)
st_crs(qc2) == st_crs(occs2)

plot(st_geometry(qc2))
plot(st_geometry(occs2), add = T)


# Plotting raster with leaflet
library(leaflet)

r <- rast("/home/claire/BDQC-GEOBON/data/Bellavance_data/terra_converted_maps/aegolius_funereus/maps_range.tif")[[6]]
x11()
plot(r)
crs(r)

r2 <- raster::raster(r)
plot(r2)
crs(r2)

pal <- colorNumeric(c("#f6f8e0", "#009999"), values(r2),
  na.color = "transparent"
)

leaflet() %>%
  addTiles() %>%
  addRasterImage(r2, colors = pal, opacity = 0.8)

library(terra)
library(leaflet)



remotes::install_github("https://github.com/rhijmans/leaflet")
library(leaflet)

# SpatRaster
r <- rast(xmin = -2.8, xmax = -2.79, ymin = 54.04, ymax = 54.05, nrow = 30, ncol = 30, crs = "epsg:4326", vals = 1:900)
x11()
plot(r)
x11()
leaflet() |>
  addTiles() |>
  addRasterImage(r, colors = "Spectral", opacity = 0.8)

# SpatVector
v <- geodata::gadm("Uganda", level = 1, path = ".") |>
  simplifyGeom(.01) |>
  makeValid()

leaflet() |>
  addTiles() |>
  addPolygons(data = v)
# or
leaflet(v) |>
  addTiles() |>
  addPolygons()



r <- terra::rast("/home/claire/Desktop/ebird/Corvus_corax_eb.tif")
terra::plot(r)

#### Carte de fond sur les eBird maps

eb <- rast("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps/accipiter_cooperii_range.tif")
plot(eb)
queb <- st_read("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/QC_region_raster_Vince.gpkg")
plot(st_geometry(queb) / 100, axes = T)

x11()
par(mfrow = c(1, 2))
plot(eb)
plot(st_geometry(queb), axes = T)
x11()
plot(eb)
plot(st_geometry(queb) * 1000, add = T)


#### Carte de fond pour pocc Vincent INLA
feat <- stac("https://acer.biodiversite-quebec.ca/stac/") %>%
  collections("oiseaux-nicheurs-qc") %>%
  items(feature_id = "acanthis_flammea_pocc_1992") %>%
  get_request()
tif_path <- feat$assets$data$href

go_cat <- stars::read_stars(paste0("/vsicurl/", tif_path),
  proxy = TRUE
) # stars object
plot(go_cat, axes = T)
st_crs(go_cat) == st_crs(queb)
pocc <- st_transform(go_cat, crs = st_crs(queb))
plot(pocc)
plot(st_geometry(queb), add = T)

mapview::mapview(go_cat)


pocc <- raster::raster("/home/claire/BDQC-GEOBON/data/Bellavance_data/terra_converted_maps/acanthis_flammea/maps_pocc.tif")
mapview::mapview(pocc)




r <- rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/zonotrichia_leucophrys_pocc_2017.tif")

r_local <- rast("/home/claire/BDQC-GEOBON/data/Bellavance_data/terra_converted_maps/zonotrichia_leucophrys/maps_pocc.tif")[[26]]

plot(r_local)
x11()
par(mfrow = c(1, 2))
plot(queb_Vince)
plot(r * 1000, axes = T)

st_crs(queb_Vince) == st_crs(r)

plot(r, axes = T)
plot(queb_Vince, add = T)
mapview::mapview(raster::raster(r))
mapview::mapview(raster::raster(r_local))



r2 <- rast("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/zonotrichia_leucophrys_range_2017.tif")

r2_local <- rast("/home/claire/BDQC-GEOBON/data/Bellavance_data/terra_converted_maps/acanthis_flammea/maps_range.tif")[[26]]

mapview::mapview(raster::raster(r2))
mapview::mapview(raster::raster(r2_local))
