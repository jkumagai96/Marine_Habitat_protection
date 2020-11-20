# Joy Kumagai 
# Date: 20/11/2020
# Calculating Per Boundary (EEZ/land) Percentage Protection 
# Marine Habitat Protection Indicator

#### Load Packages ####
library(tidyverse)
library(sf)

#### Load and clean data ####
poly <- read_sf("Data/eez_land/EEZ_land_test.shp") 

area <- poly %>% 
  as.data.frame() %>% 
  select(UNION, ISO_TER1, ISO_SOV1) %>% 
  mutate(ID = 1:length(poly$UNION))


data <- read.csv("Data/Temp/habitat_area_2.csv")
data <- data %>% 
  gather(key = "category", value = "pixel_counts", -ID , -X, na.rm = F) %>% 
  select(-X)

#### Calculate Percent Protection ####
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
write.csv(data, "Outputs/percent_protected_boundaries.csv", row.names = F)
