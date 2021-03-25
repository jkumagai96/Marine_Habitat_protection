## Joy Kumagai and Fabio
# Date: March 2021
# Raserizing Multiple Habitat Data
# Marine Habitat Protection Indicator or Marine Protection Index (MPI)


# Loading packages --------------------------------------------------------

library(sf)
library(tidyverse)
library(raster)
library(tools)
library(fasterize)
library(doParallel)
library(foreach)

# Loading data ------------------------------------------------------------

shapefiles <- list.files("Data_original/habitats/", pattern = "\\.shp$", full.names = T)
behrmann <- '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs'
r <- raster("Data_processed/ocean_grid.tif")

# Rasterizing habitats with parallel processing ------------------------------------------------------------

cl <- makeCluster(cores) 
registerDoParallel(cl)


foreach(i = 1:length(shapefiles)) %dopar% {
  require(tidyverse)
  require(sf)
  require(raster)
  require(tools)
  
  habitat <- st_read(shapefiles[i]) %>% 
    mutate(constant = 1) # for rasterization 
  
  ##### Project Data #####
  # Chosen projection: Behrmann (equal area)
  habitat <- st_transform(habitat, crs = behrmann)
  
  
  
  # Setting Area 
  if ("REP_AREA_K" %in% colnames(habitat)) {
    habitat$area = habitat$REP_AREA_K
    if (class(habitat$area) != "numeric") {
      habitat$area = 0 
    }
  } else { habitat$area = 0 }
  
  
  
  # Convert multipoints to points 
  if (unique(st_geometry_type(habitat)) == "MULTIPOINT") { 
    habitat <- st_cast(habitat, "POINT")
    print("Converted MULTIPOINT TO POINT")
  }
  
  # Convert Points and Polygons to Raster
  if (unique(st_geometry_type(habitat)) == "POINT") {
    if (sum(habitat$area) > 0) { # if there is area reported, buffer 
      habitat <- habitat %>% 
        mutate(area = ifelse(REP_AREA_K == 0, 1, REP_AREA_K),
               radius = (sqrt(area/3.14))/0.001)
      print("Attempting to Buffer points")
      habitat <- st_buffer(habitat, dist = habitat$radius)
      
      # Rasterize the resulting polygons 
      print("Attempting to convert buffered points to raster")
      habitatR <- rasterize(habitat, r, progress = "text", field = "constant")
      
    } else {
      # If there is no area reported, rasterize immediately 
      print("Attempting to convert points to raster")
      habitatR <- rasterize(habitat, r, progress = "text", field = "constant")
    }
  } else {
    # Rasterize polygons 
    print("Attempting to convert polygons to raster")
    habitatR <- fasterize::fasterize(habitat, r, field = "constant") 
  }
  
  #### Export ####
  writeRaster(habitatR, 
              filename = paste0("Data_processed/", 
                                file_path_sans_ext(basename(shapefiles[i])), 
                                "_habitat.tif"),
              overwrite = TRUE)
  print(paste0("Rasterized and written to ", file_path_sans_ext(basename(shapefiles[i])), "_habitat.tif" ))
  
}



##### merging points and polygons #####

## Full raster list
rasters <- list.files("Data_processed/", pattern = "\\.tif$", full.names = T)

## Seagrasses 
seagrasses <- str_subset(rasters, "Seagrasses")

do.call(merge, list(raster(seagrasses[1]), raster(seagrasses[2]))) %>% 
  writeRaster(., filename = "Data_processed/Seagrasses_habitat.tif", overwrite = TRUE)
beepr::beep(2)
unlink(seagrasses)


## Coral Reefs 

coralreefs <- str_subset(rasters, "CoralReef")

do.call(merge, list(raster(coralreefs[1]), raster(coralreefs[2]))) %>% 
  writeRaster(., filename = "Data_processed/CoralReefs_habitat.tif", overwrite = TRUE)
beepr::beep(2)
unlink(coralreefs)

## Satmarshes

salthmarshes <- str_subset(rasters, "Saltmarsh")

do.call(merge, list(raster(salthmarshes[1]), raster(salthmarshes[2]))) %>% 
  writeRaster(., filename = "Data_processed/Saltmarshes_habitat.tif", overwrite = TRUE)
beepr::beep(2)
unlink(salthmarshes)

## Cold Corals 

coldcorals <- str_subset(rasters, "ColdCorals")

do.call(merge, list(raster(coldcorals[1]), raster(coldcorals[2]))) %>% 
  writeRaster(., filename = "Data_processed/ColdCorals_habitat.tif", overwrite = TRUE)
beepr::beep(2)
unlink(coldcorals)

