# Joy Kumagai
# Date: Feb 2021
# Cleaning Protected Areas - version 1
# Marine Habitat Protection Indicator


##### Load Packages #####
library(tidyverse)
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
ntz <- future_lapply(mpa_poly_files, FUN = clean_NTZ, future.seed = TRUE)
managed <- future_lapply(mpa_poly_files, FUN = clean_managed, future.seed = TRUE)
gc()


# Checking projection

if(!st_crs(mpas[[1]])$proj4string == st_crs(behrmann.crs)$proj4string) {
  stop()
}

# Checking if there are null features
v <- c()
for (i in 1:length(ntz)) {
  if (length(ntz[[i]]$PA_DEF) == 0) {v <- c(v, i)}
}

ntz[[v]] <- NULL
#### Rasterization and Export ####

all_mpas <- future_lapply(mpas, FUN = function(mpas) fasterize(mpas, r, field = "constant"), future.seed = TRUE)

save_raster(all_mpas, "Data_processed/All_mpas.tif")

ntz_mpas <- future_lapply(ntz, FUN = function(ntz) fasterize(ntz, r, field = "constant"), future.seed = TRUE)

save_raster(ntz_mpas, "Data_processed/No_take_mpas.tif")

managed_mpas <- future_lapply(managed, FUN = function(managed) fasterize(managed, r, field = "constant"), future.seed = TRUE)

save_raster(managed_mpas, "Data_processed/Managed_mpas.tif")


rm(list = ls()[ls() %in% c("all_mpas", "managed", "managed_mpas", "mpas", "ntz")])

