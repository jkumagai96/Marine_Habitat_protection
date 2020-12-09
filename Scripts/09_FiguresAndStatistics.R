# Joy Kumagai 
# Date: Dec 2020
# Figures V1 
# Marine Habitat Protection Indicator

#### Load Packages ####
library(tidyverse)
library(sf)
library(RColorBrewer)

#### Load Data ####
poly <- read_sf("data/data/EEZ_Land/EEZ_Land_v3_202030.shp")
countries <- read_sf("data/data/countries/Country_Polygon.shp")
data_world <- read.csv("data/percent_protected_world.csv")
data_countries <- read.csv("data/percent_protected_boundaries.csv")
data_countries <- data_countries[!is.na(data_countries$percent_protected),]

#### Basic Statistics ####
# Number of countries/territories with data per habitat
length(unique(data_countries$ISO_TER1)) # territories
length(unique(data_countries$ISO_SOV1)) # countries 

#### Figures ####
# Map of countries with average percentage of key habitats protected
data <- data_countries %>% 
  mutate(match = grepl(pattern = "(All_mpas)$", data_countries$category)) %>% 
  filter(match == TRUE) %>% 
  dplyr::select(category, percent_protected:ISO_SOV1) %>% 
  group_by(UNION) %>% 
  summarise(percent_protected_average = mean(percent_protected)) 

robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

poly_data <- full_join(data, poly, by = "UNION") %>% 
  st_as_sf() %>% 
  st_transform(crs = robin)
countries <- st_transform(countries, crs = robin)

my.palette <- colorRampPalette(brewer.pal(7, "Purples"))(10)

plot(poly_data[,2], main = NULL, graticule = TRUE, axes = TRUE, pal = my.palette, key.pos = NULL)
plot(countries[,1], main = NULL, graticule = TRUE, axes = TRUE, col = "lightgrey")

ggplot() +
  geom_sf(data = poly_data[,2], fill = poly_data$percent_protected_average) 

# Map of countries with total area of key habitats protected 


# Figure of global habitat protection (with values of countries as points) 


# Figure of effort gap??


