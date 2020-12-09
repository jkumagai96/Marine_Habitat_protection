# Joy Kumagai 
# Date: 20/11/2020
# Calculating Per Boundary (EEZ/Land) Percentage Protection 
# Marine Habitat Protection Indicator

#### Load Packages ####
library(tidyverse)
library(sf)

#### Load and clean data ####
poly <- read_sf("data/data/EEZ_Land/EEZ_Land_v3_202030.shp")

area <- poly %>% 
  as.data.frame() %>% 
  dplyr::select(UNION, ISO_TER1, ISO_SOV1) %>% 
  mutate(ID = 1:length(poly$UNION))


data <- read.csv("data/data/habitat_area.csv")
data <- data %>% 
  gather(key = "category", value = "pixel_counts", -ID , -X, na.rm = F) %>% 
  dplyr::select(-X)

#### Calculate Percent Protection ####
n <- length(data$ID)

data <- data %>% 
  arrange(ID, category) %>% 
  mutate(group = rep(1:(n/4), each = 4)) %>% 
  group_by(group) %>% 
  mutate(percent_protected = (pixel_counts/(max(pixel_counts)))*100) %>% 
  ungroup()

# Join with Area Name/ISO's 
data <- data %>% 
  full_join(x = data, y = area, by = "ID")

#### Export ####
write.csv(data, "data/percent_protected_boundaries.csv", row.names = F)
