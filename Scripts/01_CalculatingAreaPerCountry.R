# Load Packages
library(tidyverse)
library(sf)
library(rgeos)
##### Load Data #####
eez_land <- st_read("Data/EEZ_land_union_v3_202003/EEZ_Land_v3_202030.shp")
mangroves <- st_read("Data/GMW_001_GlobalMangroveWatch_2016/01_Data/GMW_2016_v2.shp")

##### Clean Data #####
st_crs(mangroves) == st_crs(eez_land) # Same Projection

# Clip data
region <- eez_land %>% 
  filter(TERRITORY1 == "Mexico" | TERRITORY1 == "Guatemala" | TERRITORY1 == "Belize")

#st_crop(mangroves, st_bbox(region))
library(raster)
test <- raster::intersect(mangroves, regions)
