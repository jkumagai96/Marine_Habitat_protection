# Joy Kumagai 
# Date: March 2021
# Calculating Percent Protection for High Seas 
# Marine Habitat Protection Indicator

#### Load Packages ####
library(tidyverse)
library(raster)
library(sf)
library(fasterize)

#### Load Data ####
grids <- list.files("Data_processed/", pattern = "*habitat.tif$")
poly <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp") %>%
  st_transform(., crs = behrmann.crs) %>% 
  mutate(constant = 1)

r <- raster("Data_processed/ocean_grid.tif")

##### Create High Seas Raster #####
eez_land <-  fasterize::fasterize(poly, r, field = "constant") 
eez_land[is.na(eez_land[])] <- 0 
eez_land[eez_land > 0] <- NA
eez_land[eez_land == 0] <- 1
plot(eez_land) 

high_seas <- eez_land 

df <- data.frame(str_sub(grids, end = -5))
df[,2] <- NA
for (i in 1:length(grids)) {
  habitat_r <- raster(paste0("Data_processed/", grids[i]))
  habitat_in_hs <- high_seas*habitat_r
  df[i,2] <- cellStats(habitat_in_hs, 'sum')
}

df
df[,3] <- NA
colnames(df) <- c("Name", "pixel_counts", "ID")
df[,3] <- rep(1:(length(df$ID)/4), each = 4)
save <- df
df <- df %>% 
  mutate(area_km2 = pixel_counts) %>% 
  group_by(ID) %>% 
  mutate(percent_protected = (pixel_counts/(max(pixel_counts)))*100) %>% 
  ungroup()

write.csv(df, "Data_final/percent_protected_highseas.csv", row.names = F)