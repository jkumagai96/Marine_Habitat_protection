# Joy Kumagai
# Date: Feb 2021
# Raserizing Multiple Habitat Data
# Marine Habitat Protection Indicator or Marine Protection Index (MPI)


# Loading packages --------------------------------------------------------


library(tidyverse)
library(raster)
library(sf)
library(tools)
library(fasterize)
library(foreach)
library(doParallel)

# Loading data ------------------------------------------------------------

r <- raster("Data_processed/ocean_grid.tif")

shapefiles <- list.files("Data_original/habitats/", pattern = "\\.shp$")

#setup parallel backend to use many processors
cores = detectCores()
cl <- makeCluster(cores[1] - 1) #not to overload your computer
registerDoParallel(cl)


foreach(i = 1:length(shapefiles)) %dopar% {
  path <- paste0("Data_original/habitats/", shapefiles[i])
  habitat_poly <- read_sf(path)
  
  ##### Project Data #####
  crs(habitat_poly)
  
  # Chosen projection: World Eckert Iv (equal area)
  behrmann <- '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs'
  habitat_poly <- st_transform(habitat_poly, crs = behrmann)
  
  #### Rasterize #####
  habitat_poly$constant <- 1 
  
  if (unique(st_geometry_type(habitat_poly)) == "MULTIPOINT") {
    habitat_poly <- st_cast(habitat_poly, "POINT")
    print("Converting Multipoints to points")
    print("Attempting to convert to raster")
    habitatR <- rasterize(habitat_poly, r, progress = "text", field = "constant")
  } else if (unique(st_geometry_type(habitat_poly)) == "POINT") {
    print("Attempting to convert to raster")
    habitatR <- rasterize(habitat_poly, r, progress = "text", field = "constant")
  } else {
    print("Attempting to convert to raster")
    habitatR <- fasterize(habitat_poly, r, field = "constant") 
  }
  
  #### Export ####
  exportpath <- paste0("Data_processed/", file_path_sans_ext(shapefiles[i]), "habitat.tif")
  writeRaster(habitatR, exportpath, overwrite = TRUE)
  print(paste0("Habitat Raster has been written to ", exportpath))
}

#stop cluster
stopCluster(cl)