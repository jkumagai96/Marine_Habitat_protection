# Joy Kumagai
# Date: Nov 2020
# Combining Habitats and MPAs
# Marine Habitat Protection Indicator or Marine Protection Index (MPI)

# Purpose is to create the files with intersections of each MPA layer and each habitat, so we can summarize by boundaries in the next script

#### Load Packages ####
library(tidyverse)
library(raster)
library(stringr)

#### Load Data ####
mpas_files <- list.files("Data/Temp_MPAs/", pattern = "*.tif$") #list files (in this case raster TIFFs)
habitat_files <- list.files("Data/Temp/", pattern = "*.tif$") #list files (in this case raster TIFFs)

for (i in habitat_files) {
  habitat <- str_sub(i, end = -5)
  r1 <- raster(paste0("Data/Temp/", i))
  for (ii in mpas_files) {
    r2 <- raster(paste0("Data/Temp_MPAs/", ii))
    r3 <- r1*r2 
    mpa_type <- str_sub(ii, end = -5)
    path <- paste0("Data/Temp/", habitat, "_with_", mpa_type, ".tif")
    print(paste0("Writing Raster to ", path))
    writeRaster(r3, path, overwrite = TRUE)
  }
  
}