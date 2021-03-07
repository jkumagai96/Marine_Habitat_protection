# Joy Kumagai
# Date: Feb 2021
# Combining Habitats and MPAs
# Marine Habitat Protection Indicator or Marine Protection Index (MPI)

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


#setup parallel backend to use many processors
cores = detectCores()
cl <- makeCluster(cores[1] - 1) #not to overload your computer
registerDoParallel(cl)


foreach(i = habitat_files) %dopar% {
  habitat <- str_sub(i, end = -5)
  r1 <- raster(paste0("Data_processed/", i))
  for (ii in mpas_files) {
    r2 <- raster(paste0("Data_processed/", ii))
    r3 <- r1*r2 
    mpa_type <- str_sub(ii, end = -5)
    path <- paste0("Data_processed/", habitat, "_with_", mpa_type, "habitat.tif")
    print(paste0("Writing Raster to ", path))
    writeRaster(r3, path, overwrite = TRUE)
  }
  
}