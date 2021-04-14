# Joy Kumagai 
# Date: March 2021
# Calculating Habitat Protection Indexes Script
# Marine Habitat Protection Indicator

##### Load Packages ######
library(tidyverse)
library(sf)
library(raster)

##### Load Data ######

eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp") %>% # necessary to join data
  dplyr::select(UNION, MRGID_EEZ) %>% 
  st_drop_geometry()

# Load other processed datasets 
highseas <- read.csv("Data_final/percent_protected_highseas.csv")
world <- read.csv("Data_final/percent_protected_world.csv")
habitat_data <- read.csv("Data_final/percent_protected_boundaries.csv") %>% 
  left_join(., eez_land, by = "UNION")

##### Joining Data #####
# Prepare high seas habitat data 
highseas <- highseas %>% 
  na.omit() %>% 
  filter(!grepl("with_Managed", Name),
         !grepl("with_No_take", Name)) %>% 
  dplyr::select(Name, pixel_counts) %>% 
  mutate(habitat = c("coldcorals", "coldcorals", "knolls_seamounts", "knolls_seamounts", "seagrasses", "seagrasses")) %>% 
  mutate(key = c("all_mpas", "total", "all_mpas", "total", "all_mpas", "total")) %>% 
  dplyr::select(-Name) %>% 
  pivot_wider(values_from = pixel_counts, names_from = key) %>% 
  mutate(UNION = "High Seas",
         ISO_TER1 = NA,
         MRGID_EEZ = NA)

# Prepare world Habitat Data 
total_areas <- world %>% # Prepare total area dataset
  dplyr::filter(!grepl('with', Name)) %>% 
  dplyr::select(Name, area_km2) %>% 
  pivot_wider(values_from = area_km2, names_from = Name)

# Prepare habitat specific datasets 
coldcorals <- habitat_data %>% 
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, habitat, total, all_mpas) %>% 
  rbind(highseas) %>% 
  filter(habitat == "coldcorals") %>% # Filter by habitat 
  add_column(world_area = total_areas$ColdCorals_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

coralreefs <- habitat_data %>% 
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, habitat, total, all_mpas) %>% 
  rbind(highseas) %>%
  filter(habitat == "coralreefs") %>% # Filter by habitat 
  add_column(world_area = total_areas$CoralReefs_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

knolls_seamounts <- habitat_data %>% 
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, habitat, total, all_mpas) %>% 
  rbind(highseas) %>%
  filter(habitat == "knolls_seamounts") %>% # Filter by habitat 
  add_column(world_area = total_areas$KnollsSeamounts_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

mangroves <- habitat_data %>% 
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, habitat, total, all_mpas) %>%
  rbind(highseas) %>%
  filter(habitat == "mangroves") %>% # Filter by habitat 
  add_column(world_area = total_areas$Mangroves_v2_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

saltmarshes <- habitat_data %>% 
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, habitat, total, all_mpas) %>% 
  rbind(highseas) %>%
  filter(habitat == "saltmarshes") %>% # Filter by habitat 
  add_column(world_area = total_areas$Saltmarshes_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

seagrasses <- habitat_data %>% 
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, habitat, total, all_mpas) %>% 
  rbind(highseas) %>%
  filter(habitat == "seagrasses") %>% # Filter by habitat 
  add_column(world_area = total_areas$Seagrasses_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

##### Calculate Index ######
df <- rbind(coldcorals, coralreefs, knolls_seamounts, mangroves, saltmarshes, seagrasses)

df <- df %>%  
  rename(F_G_H = global_fraction) %>% # Fraction of Global Habitat in the EEZ/Land
  mutate(F_H_P = all_mpas/total,  # Fraction of Habitat Protected in the EEZ/land
         t_F_H_P = F_G_H * 0.3,
         G_H_I = F_H_P * F_G_H, # Global Habitat Index
         T_H_I = (F_H_P * F_G_H) - t_F_H_P) # Target Habitat Index 

##### Export ######

write.csv(df, "Data_final/habitat_protection_indexes.csv", row.names = F)

