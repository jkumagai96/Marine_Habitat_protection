# Joy Kumagai and Fabio Favoretto
# Date: Jan 2022
# Combining Habitats and MPAs
# Habitat Protection Index Project

# Purpose is to create the files with intersections of each MPA layer and each 
# habitat, so we can summarize by boundaries in the next script

# Loading packages --------------------------------------------------------

library(tidyverse)
library(raster)
library(stringr)
library(foreach)
library(doParallel)

# Loading data ------------------------------------------------------------


mpas_files <- list.files("Data_processed/", pattern = "*mpas.tif$") #list files (in this case raster TIFFs)
habitat_files <- list.files("Data_processed/", pattern = "*habitat.tif$") #list files (in this case raster TIFFs)


cl <- makeCluster(cores)
registerDoParallel(cl)


for (i in 1:length(habitat_files)) {
  habitat <- stringr::str_sub(habitat_files[i], end = -5)
  r1 <- raster(paste0("Data_processed/", habitat_files[i]))
  print(i)
  foreach(ii = mpas_files) %dopar% {
    r2 <- raster::raster(paste0("Data_processed/", ii))
    r3 <- r1*r2 
    mpa_type <- stringr::str_sub(ii, end = -5)
    path <- paste0("Data_processed/", habitat, "_with_", mpa_type, "habitat.tif")
    print(paste0("Writing Raster to ", path))
    raster::writeRaster(r3, path, overwrite = TRUE)
  }
  
}

stopCluster(cl)

#### END OF SCRIPT ####