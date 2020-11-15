library(fasterize)
library(raster)
library(tidyverse)
library(sf)


#grids <- list.files("Data/Temp/", pattern = "*.tif$") #list files (in this case raster TIFFs)


##### Load Data #####
ocean <- read_sf("Data/ocean/ne_110m_ocean.shp")
habitat_poly <- read_sf("Data/seagrasses/version7/014_001_WCMC013-014_SeagrassPtPy2020_v7/01_Data/WCMC013014-Seagrasses-Py-v7.shp")


# Chosen projection: World Eckert Iv (equal area)
eckert <- "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m no_defs"
ocean <- st_transform(ocean, crs = eckert)
habitat_poly <- st_transform(habitat_poly, crs = eckert)

habitat_poly$constant <- 1 # seagrasses


#### Rasterize #####

r <- raster(habitat_poly, res = 10000)

habitatR1 <- fasterize(habitat_poly, r, field = "constant")


#### Export ####
writeRaster(habitatR1, "Data/Temp/seagrasses_raster.tif")
