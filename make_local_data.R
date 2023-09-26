library(sf)
library(terra)

# Récuperation des cartes de Vincent - range
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
