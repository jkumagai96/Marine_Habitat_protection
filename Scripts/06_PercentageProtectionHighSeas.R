# Joy Kumagai 
# Date: Mar 2021
# Calculating High Seas Percentage Protection 
# Marine Habitat Protection Indicator

#### Load Packages and Data ####
library(raster)
library(sf)
library(fasterize)
library(tidyverse)

r <- raster("Data_processed/ocean_grid.tif")

# Habitat data
grids <- list.files("Data_processed/", pattern = "*habitat.tif$") 

#### Create High Seas ####
poly 

poly2 <- st_as_sf(poly) %>% 
  mutate(constant = 0)

eez_land_r <- fasterize(poly2, r, field = "constant") 
eez_land_r[is.na(eez_land_r[])] <- 1

high_seas <- eez_land_r
plot(high_seas)

#### Intersecting with Habitats

habitat <- raster(paste0("Data_processed/", grids[[2]]))
habitat_in_highseas <- habitat*high_seas
pixels <- cellStats(habitat_in_highseas, stat = "sum")
pixels
