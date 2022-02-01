# Joy Kumagai 
# Date: January 2022
# Calculating Percent Protection for High Seas 
# Habitat Protection Index Project

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
mpas <- raster("Data_processed/All_mpas.tif")

##### Put temp files in a place with more space
rasterOptions(tmpdir = "Temp/")

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
df[,3] <- rep(1:(length(df$ID)/2), each = 2)
save <- df
df <- df %>% 
  mutate(area_km2 = pixel_counts) %>% 
  group_by(ID) %>% 
  mutate(percent_protected = (pixel_counts/(max(pixel_counts)))*100) %>% 
  ungroup()

write.csv(df, "Data_final/percent_protected_highseas.csv", row.names = F)

##### Calculate High Seas Area and Protected Area ####
a <- freq(high_seas) # calculate area of high seas 

pa <- high_seas*mpas # Calculate area of protected areas in high seas
b <- freq(pa)

dat <- data.frame(matrix(ncol = 3, nrow = 0))
vect <- c("High Seas", a[1,2], b[1,2]) 
dat <- rbind(dat, vect)
colnames(dat) <- c("UNION", "EEZ_km2", "Protected_area")

# export
write.csv(dat, "Data_processed/high_seas_eez_area_and_pa.csv", row.names = F)

# remove temp files
to_delete <- list.files("Temp/", pattern = "r_tmp", full.names = T)
unlink(to_delete, recursive = TRUE)

#### END OF SCRIPT ####
