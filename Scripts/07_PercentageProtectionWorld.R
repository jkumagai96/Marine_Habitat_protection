# Joy Kumagai 
# Date: 19/11/2020
# Calculating World Percentage Protection 
# Marine Habitat Protection Indicator

#### Load Packages ####
library(tidyverse)
library(raster)
library(stringr)

#### Declare Functions ####

#### Load Data ####
grids <- list.files("Data/Temp/", pattern = "*.tif$")
s <- stack(paste0("Data/Temp/", grids))

df <- data.frame(str_sub(grids, end = -5))
df[,2:3] <- NA
for (i in 1:length(grids)) {
  df[i,2] <- cellStats(s[[i]], 'sum')
}

colnames(df) <- c("Name", "pixel_counts", "ID")
df[,3] <- rep(1:(length(df$ID)/4), each = 4)

df %>% 
  mutate()
  group_by(ID) %>% 
  mutate(percent_protected = (pixel_counts/(max(pixel_counts)))*100) %>% 
  ungroup()
        