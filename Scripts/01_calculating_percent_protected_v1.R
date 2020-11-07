# Joy Kumagai
# Date: Oct 2020
# Calculate habitat within proposed protected areas - general (versoin 1)
# Diving Atlas 2 (protection)

##### Load Packages #####
library(tidyverse)
library(raster)
library(sf)
library(wdpar)
##### Load Data #####
proposed_mpas <- st_read("Data_Final_Outputs/proposed_MPAs_all.shp")
mpas <- st_read("Data_Original/SHAPE_ANPS_2_SUBZONIF/Subzonificacion_ANP.shp") # Santiago's layer
eez <- read_sf("Data_Original/eez/eez_Mexico.shp")
habitat_poly <- read_sf("Data_Original/seagrasses/01_Data/WCMC_013_014_SeagrassesPy_v6.shp")

# Global Protected Areas Download and cleaning
wdpa_latest_version() # states which version we are using 
global_pas <- wdpa_fetch(x = "MEX", wait = F)
global_pas_clean <- wdpa_clean(global_pas, erase_overlaps = F)
crs(global_pas_clean)

# remove terrestrial areas 
mpas_global <- global_pas_clean %>% 
  filter(MARINE == "partial" | MARINE == "marine")

### Rasterize mpas layer 

# create base raster layer 
r_extent <- read_sf("Data_Original/ocean/ne_110m_ocean.shp")
r_extent <- st_transform(r_extent, crs(mpas_global))
r <- raster(r_extent, res = 10000)

# rasterize mpas layer 
mpas_global$one <- 1
mpas_global_r <- rasterize(mpas_global, r, progress = "text", field = "one") 

##### Clean Data #####
mpas <- st_transform(mpas, crs(proposed_mpas))
eez <- st_transform(eez, crs(proposed_mpas))
habitat_poly <- st_transform(habitat_poly, crs(proposed_mpas))

##### Analysis ####
# Calculate the current percent protection (Raster)

#r <- raster(eez, res = 100000)  # 100,000 meters
habitat_poly$one <- 1
habitat_r <- rasterize(habitat_poly, r, progress = "text", field = "one") 

habitat_n <- cellStats(habitat_r, stat = "sum") 
p_habitat <- habitat_r*mpas_global_r
p_habitat_n <- cellStats(p_habitat, stat = "sum")
pp <- (p_habitat_n/habitat_n)*100 
