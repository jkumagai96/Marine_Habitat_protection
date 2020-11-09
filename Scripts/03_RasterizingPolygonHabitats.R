# Joy Kumagai
# Date: Nov 2020
# Raserizing Polygon Habitat Data
# Marine Habitat Protection Indicator or Marine Protection Index (MPI)


##### Load Packages #####
library(tidyverse)
library(raster)
library(sf)

##### Load Data #####
ocean <- read_sf("Data/ocean/ne_110m_ocean.shp")
habitat_poly <- read_sf("Data/seagrasses/version7/014_001_WCMC013-014_SeagrassPtPy2020_v7/01_Data/WCMC013014-Seagrasses-Py-v7.shp")

##### Project Data #####
crs(habitat_poly)

# Chosen projection: World Eckert Iv (equal area)
eckert <- "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m no_defs"
ocean <- st_transform(ocean, crs = eckert)
habitat_poly <- st_transform(habitat_poly, crs = eckert)

#### Rasterize #####
r <- raster(ocean, res = 10000)
habitat_poly$constant <- 1 # seagrasses
habitatR <- rasterize(habitat_poly, r, progress = "text", field = "constant")


#### Export ####
writeRaster(habitatR, "Data/Temp/seagrasses_raster.tif")