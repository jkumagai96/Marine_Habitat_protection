# Joy Kumagai 
# Date: March 2021
# Calculating the Area and Protected Area for each EEZ
# Marine Habitat Protection Indicator

##### Load Packages ######
library(tidyverse)
library(sf)
library(raster)

##### Load Data ######
eez <- read_sf("Data_original/eez/eez_v11.shp") %>% 
  mutate(ID = 1:length(.$MRGID)) %>% 
  st_transform(crs = behrmann.crs) 

eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp") %>% # necessary to join data
  select(UNION, MRGID_EEZ) %>% 
  st_drop_geometry()

pas <- raster("Data_processed/All_mpas.tif")
r <- raster("Data_processed/ocean_grid.tif")

# Load other processed datasets 
highseas <- read.csv("Data_final/percent_protected_highseas.csv")
world <- read.csv("Data_final/percent_protected_world.csv")
habitat_data <- read.csv("Data_final/percent_protected_boundaries.csv") %>% 
  left_join(., eez_land, by = "UNION")

##### Calculate Area #####
beginCluster(n = cores) 
n_pas <- raster::extract(pas, eez, fun = sum, na.rm = TRUE, df = TRUE)
endCluster() # this ends the cluster use of the cpu

##### Joining Data #####
# Joy Kumagai 
# Date: March 2021
# Calculating the Area and Protected Area for each EEZ
# Marine Habitat Protection Indicator

##### Load Packages ######
library(tidyverse)
library(sf)
library(raster)

##### Load Data ######
eez <- read_sf("Data_original/eez/eez_v11.shp") %>% 
  mutate(ID = 1:length(.$MRGID)) %>% 
  st_transform(crs = behrmann.crs) 

eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp") %>% # necessary to join data
  dplyr::select(UNION, MRGID_EEZ) %>% 
  st_drop_geometry()

pas <- raster("Data_processed/All_mpas.tif")
r <- raster("Data_processed/ocean_grid.tif")

# Load other processed datasets 
highseas <- read.csv("Data_final/percent_protected_highseas.csv")
world <- read.csv("Data_final/percent_protected_world.csv")
habitat_data <- read.csv("Data_final/percent_protected_boundaries.csv") %>% 
  left_join(., eez_land, by = "UNION")

##### Calculate Area #####
# beginCluster(n = cores) 
# n_pas <- raster::extract(pas, eez, fun = sum, na.rm = TRUE, df = TRUE)
# colnames(n_pas) <- c("ID", "Protected_area")
# endCluster() # this ends the cluster use of the cpu
# write.csv(n_pas, "Data_processed/protected_area_per_eez.csv", row.names = F)
n_pas <- read.csv("Data_processed/protected_area_per_eez.csv")

##### Joining Data #####
# Prepare EEZ Area 
eez_area <- eez %>% 
  left_join(., n_pas, by = "ID") %>% # Join EEZs and extracted counts of protected areas 
  dplyr::select(MRGID, AREA_KM2, Protected_area) %>% 
  rename(MRGID_EEZ = MRGID,
         EEZ_km2 = AREA_KM2) %>% 
  st_drop_geometry()

# Prepare high seas habitat data 
dat <- read.csv("Data_processed/high_seas_eez_area_and_pa.csv")
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
         MRGID_EEZ = NA, 
         EEZ_km2 = dat$EEZ_km2, 
         Protected_area = dat$Protected_area)

# Prepare world Habitat Data 
total_areas <- world %>% # Prepare total area dataset
  dplyr::filter(!grepl('with', Name)) %>% 
  dplyr::select(Name, area_km2) %>% 
  pivot_wider(values_from = area_km2, names_from = Name)

# Prepare habitat specific datasets 
coldcorals <- habitat_data %>% 
  left_join(eez_area, by = "MRGID_EEZ") %>%  # Join EEZ area onto data
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, EEZ_km2, habitat, total, all_mpas, Protected_area) %>% 
  rbind(highseas) %>% 
  filter(habitat == "coldcorals") %>% # Filter by habitat 
  add_column(world_area = total_areas$ColdCorals_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

coralreefs <- habitat_data %>% 
  left_join(eez_area, by = "MRGID_EEZ") %>%  # Join EEZ area onto data
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, EEZ_km2, habitat, total, all_mpas, Protected_area) %>% 
  rbind(highseas) %>%
  filter(habitat == "coralreefs") %>% # Filter by habitat 
  add_column(world_area = total_areas$CoralReefs_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

knolls_seamounts <- habitat_data %>% 
  left_join(eez_area, by = "MRGID_EEZ") %>%  # Join EEZ area onto data
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, EEZ_km2, habitat, total, all_mpas, Protected_area) %>% 
  rbind(highseas) %>%
  filter(habitat == "knolls_seamounts") %>% # Filter by habitat 
  add_column(world_area = total_areas$KnollsSeamounts_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

mangroves <- habitat_data %>% 
  left_join(eez_area, by = "MRGID_EEZ") %>%  # Join EEZ area onto data
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, EEZ_km2, habitat, total, all_mpas, Protected_area) %>%
  rbind(highseas) %>%
  filter(habitat == "mangroves") %>% # Filter by habitat 
  add_column(world_area = total_areas$Mangroves_v2_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

saltmarshes <- habitat_data %>% 
  left_join(eez_area, by = "MRGID_EEZ") %>%  # Join EEZ area onto data
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, EEZ_km2, habitat, total, all_mpas, Protected_area) %>% 
  rbind(highseas) %>%
  filter(habitat == "saltmarshes") %>% # Filter by habitat 
  add_column(world_area = total_areas$Saltmarshes_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

seagrasses <- habitat_data %>% 
  left_join(eez_area, by = "MRGID_EEZ") %>%  # Join EEZ area onto data
  dplyr::select(UNION, ISO_TER1, MRGID_EEZ, EEZ_km2, habitat, total, all_mpas, Protected_area) %>% 
  rbind(highseas) %>%
  filter(habitat == "seagrasses") %>% # Filter by habitat 
  add_column(world_area = total_areas$Seagrasses_habitat) %>% # Add total world area for that habitat
  mutate(global_fraction = total/sum(total)) # calculate global fraction each jurisdiction has 

##### Export ######
write.csv(coldcorals, "Data_final/habitat/coldcorals.csv", row.names = F)
write.csv(coralreefs, "Data_final/habitat/coralreefs.csv", row.names = F)
write.csv(knolls_seamounts, "Data_final/habitat/knolls_seamounts.csv", row.names = F)
write.csv(mangroves, "Data_final/habitat/mangroves.csv", row.names = F)
write.csv(saltmarshes, "Data_final/habitat/saltmarshes.csv", row.names = F)
write.csv(seagrasses, "Data_final/habitat/seagrasses.csv", row.names = F)

