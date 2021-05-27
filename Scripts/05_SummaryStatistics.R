# Fabio Favoretto
# Date: 15/11/2020
# Summary statistic of rasterized habitat polygons
# Habitat Protection Index Project

# Load Packages -----------------------------------------------------------

library(parallel)
library(snow)
library(tidyverse)
library(raster)
library(sf)


# Loading data ------------------------------------------------------------

grids <- list.files("Data_processed/", pattern = "*habitat.tif$") #list files (in this case raster TIFFs)

poly <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp") %>%
  st_transform(., crs = behrmann.crs) 

poly <- as(poly, "Spatial") # we need this format to speed extract function

poly$ID <- 1:length(poly$UNION)

# poly <- poly[1:10,] Uncomment this if you want to subset the polygon shapefile to less features

start.time <- Sys.time()
## create a raster stack (the stack will be formed by all the files in the Temp folders sourced by list.files)
dir.create(path = "Temp", showWarnings = FALSE)
tempwd <- "Temp/"
s <- raster::writeRaster(x = stack(paste0("Data_processed/", grids)), 
                         paste0(tempwd, "stacked"), 
                         overwrite = TRUE)

# Zonal statistic ---------------------------------------------------------

## Now we will extract in parallel, uncomment below to activate the cluster parallelization

beginCluster(n = cores) 

ex <- raster::extract(s, poly, fun = sum, na.rm = TRUE, df = TRUE)

endCluster() # this ends the cluster use of the cpu



# Save output -------------------------------------------------------------

write.csv(ex, file = "Data_processed/habitat_area.csv")

end.time <- Sys.time()
end.time - start.time


#### END OF SCRIPT #####