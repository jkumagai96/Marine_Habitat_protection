# Joy Kumagai 
# Date: Jan 2022
# Calculating World Percentage Protection 
# Habitat Protection Index Project

#### Load Packages ####
library(tidyverse)
library(raster)
library(stringr)

#### Load Data ####
grids <- list.files("Data_processed/", pattern = "*habitat.tif$")
s 

df <- data.frame(str_sub(grids, end = -5))
df[,2:3] <- NA
for (i in 1:length(grids)) {
  df[i,2] <- cellStats(s[[i]], 'sum')
}

colnames(df) <- c("Name", "pixel_counts", "ID")
df[,3] <- rep(1:(length(df$ID)/2), each = 2)

df <- df %>% 
  mutate(area_km2 = pixel_counts) %>% 
  group_by(ID) %>% 
  mutate(percent_protected = (pixel_counts/(max(pixel_counts)))*100) %>% 
  ungroup()

write.csv(df, "Data_final/percent_protected_world.csv", row.names = F)


#### END OF SCRIPT ####

