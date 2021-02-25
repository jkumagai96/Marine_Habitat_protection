# Joy Kumagai 
# Date: 20/11/2020
# Calculating Per Boundary (EEZ/Land) Percentage Protection 
# Marine Habitat Protection Indicator

#### Load Packages ####
library(tidyverse)
library(sf)

#### Load and clean data ####
data <- read.csv("data/data/habitat_area.csv")
poly <- read_sf("data/data/EEZ_Land/EEZ_Land_v3_202030.shp")

area <- poly %>% 
  as.data.frame() %>% 
  dplyr::select(UNION, ISO_TER1, ISO_SOV1) %>% 
  mutate(ID = 1:length(poly$UNION))

column_names <- c("ID", "all_mpas", "managed", "no_take", "total", "habitat")

coldcorals <- data %>% 
  select(ID, starts_with("ColdCorals")) %>% 
  mutate(hab = "coldcorals")
colnames(coldcorals) <- column_names 

coralreefs <- data %>% 
  select(ID, starts_with("CoralReef")) %>% 
  mutate(hab = "coralreefs")
colnames(coralreefs) <- column_names 

mangroves <- data %>% 
  select(ID, starts_with("Mangroves")) %>% 
  mutate(hab = "mangroves")
colnames(mangroves) <- column_names 

saltmarshes <- data %>% 
  select(ID, starts_with("Saltmarshes")) %>% 
  mutate(hab = "saltmarshes")
colnames(saltmarshes) <- column_names 

seagrasses <- data %>% 
  select(ID, starts_with("Seagrasses")) %>% 
  mutate(hab = "seagrasses")
colnames(seagrasses) <- column_names 


df <- rbind(coldcorals, coralreefs, mangroves, saltmarshes, seagrasses) %>% 
  select(habitat, total, all_mpas, managed, no_take, ID)
df <- full_join(area, df, by = "ID")

###### Calculate Percent protected  #####
df <- df %>% mutate(pp_all_mpas = (all_mpas/total)*100, 
              pp_managed = (managed/total)*100, 
              pp_no_take = (no_take/total)*100)

#### Export ####
write.csv(df, "data/percent_protected_boundaries_new.csv", row.names = F)
