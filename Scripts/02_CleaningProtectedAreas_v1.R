# Joy Kumagai and Fabio Favoretto
# Date: Jan 2022
# Cleaning Protected Areas 
# Habitat Protection Index Project

##### Load Packages #####
library(raster)
library(sf)
library(fasterize)
require(future.apply)

# Creating output directory -----------------------------------------------

dir.create(path = "Data_processed", showWarnings = FALSE)

# Ocean rasterizing and saving --------------------------------------------

r <- raster(st_transform(read_sf("Data_original/ocean/ne_110m_ocean.shp"), crs = behrmann), res = 1000)

writeRaster(r, "Data_processed/ocean_grid.tif", overwrite = TRUE)

# MPA layers --------------------------------------------------------------


plan(multisession, gc = TRUE, workers = cores)
mpas <- future_lapply(mpa_poly_files, FUN = clean, future.seed = TRUE)
gc()

#### Rasterization and Export ####

all_mpas <- future_lapply(mpas, FUN = function(mpas) fasterize(mpas, r, field = "constant"), future.seed = TRUE)

save_raster(all_mpas, "Data_processed/All_mpas.tif")
rm(all_mpas)
gc()


rm(list = ls()[ls() %in% c("all_mpas", "mpas")])


#### END OF SCRIPT ####