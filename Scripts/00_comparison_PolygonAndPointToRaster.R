# Joy Kumagai
# Date: August/Sep 2020
# Exploratory - Comparing polygon to raster percent protected methodologies
# Marine Habitat Protection Indicator

##### Load Packages #####
library(raster)
library(sf)
library(tidyverse)

##### Load Data #####
mpas_mex <- st_read("Data/Mexican_MPAs/MX_MPAs.shp")
eez_mex <- st_read("Data/eez_land/EEZ_Land_v3_202030.shp") %>% filter(TERRITORY1 == "Mexico")
wilderness <- raster("Data/marine_wilderness/global_wild.tif")
mangroves <- st_read("Data/Temp/mangroves_selected.shp")

# Clean data 
crs(wilderness) <- "+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs" # Assigns World Behrman
mpas_mex <- st_transform(mpas_mex, crs(wilderness))
eez_mex <- st_transform(eez_mex, crs(wilderness))
mangroves <- st_transform(mangroves, crs(wilderness))
mangroves <- st_buffer(mangroves, dist = 0)
mangroves <- st_intersection(mangroves, eez_mex)

##### Comparison - Percent Area w/ Raster#####
# Raster 
r <- raster(eez_mex, res = 1000)

mangroves_r2 <- rasterize(mangroves, r, getCover = FALSE, progress = "text") # Get cover increases time by too much!
mangroves_r2 <- mangroves_r2 > 0 

mpas_mex_r <- rasterize(mpas_mex, r, progress = "text")
mpas_mex_r <-mpas_mex_r > 0 
total_mangroves <- cellStats(mangroves_r2, stat = "sum") 

protected_mangroves_r <- mangroves_r2*mpas_mex_r
protected_mangroves <- cellStats(protected_mangroves_r, stat = "sum")
pp <- (protected_mangroves/total_mangroves)*100 

# Polygon

mangroves_union <- st_union(mangroves, by_feature = F) 
area_mangroves <- sum(st_area(mangroves_union))
mpas_mex <- st_union(mpas_mex, by_feature = F)
protected_mangroves_poly <- st_intersection(mangroves_union, mpas_mex)
protected_mangroves_area <- sum(st_area(protected_mangroves_poly))
pp_poly <- (protected_mangroves_area/area_mangroves)*100

similarity <- pp_poly/pp # 99.7 - that is pretty great! Polygon area was also confirmed in QGIS to be 51.75%
