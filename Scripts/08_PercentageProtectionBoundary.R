# Joy Kumagai 
# Date: March 2021
# Calculating Per Boundary (EEZ/Land) Percentage Protection 
# Habitat Protection Index Project

#### Load Packages ####
library(tidyverse)
library(sf)
library(janitor)

#### Load and clean data ####
data <- read.csv("Data_processed/habitat_area.csv")
poly 

area <- poly %>% 
  as.data.frame() %>% 
  dplyr::select(UNION, ISO_TER1, ISO_SOV1) %>% 
  mutate(ID = 1:length(poly$UNION))

column_names <- c("ID", "all_mpas", "managed", "no_take", "total", "habitat")

coldcorals <- data %>% 
  dplyr::select(ID, starts_with("ColdCorals")) %>% 
  mutate(hab = "coldcorals")
colnames(coldcorals) <- column_names 

coralreefs <- data %>% 
  dplyr::select(ID, starts_with("CoralReef")) %>% 
  mutate(hab = "coralreefs")
colnames(coralreefs) <- column_names 

mangroves <- data %>% 
  dplyr::select(ID, starts_with("Mangroves")) %>% 
  mutate(hab = "mangroves")
colnames(mangroves) <- column_names 

saltmarshes <- data %>% 
  dplyr::select(ID, starts_with("Saltmarshes")) %>% 
  mutate(hab = "saltmarshes")
colnames(saltmarshes) <- column_names 

seagrasses <- data %>% 
  dplyr::select(ID, starts_with("Seagrasses")) %>% 
  mutate(hab = "seagrasses")
colnames(seagrasses) <- column_names 

knolls_seamounts <- data %>% 
  dplyr::select(ID, starts_with("Knolls")) %>% 
  mutate(hab = "knolls_seamounts")
colnames(knolls_seamounts) <- column_names 



df <- rbind(coldcorals, coralreefs, mangroves, saltmarshes, seagrasses, knolls_seamounts) %>% 
  dplyr::select(habitat, total, all_mpas, managed, no_take, ID)
df <- full_join(area, df, by = "ID")

# landlocked countries
landlocked <- read.csv('Data_original/landlocked.csv') %>% 
  clean_names()

###### Calculate Percent protected  #####
df <- df %>% mutate(pp_all_mpas = (all_mpas/total)*100, 
                    pp_managed = (managed/total)*100, 
                    pp_no_take = (no_take/total)*100) 
df <- df %>% 
  group_by(UNION) %>% 
  mutate(pp_mean_all = mean(pp_all_mpas, na.rm = TRUE), # average over all habitats considered
         pp_mean_notake = mean(pp_no_take, na.rm = TRUE)) # average over all habitats considered within no-take MPAs

##### Filtering countries #####
landlocked <- landlocked$country # creates a vector of countries to eliminate that are landlocked

# filtering out landlocked countries
df <- df %>% 
  filter(!UNION %in% landlocked)

df <- df %>% 
  filter(!grepl("Joint regime", UNION)) %>% # filtering out joint regime countries
  filter(!grepl("Overlapping claim", UNION)) # filtering out overlapping claims 

#### Export ####
write.csv(df, "Data_final/percent_protected_boundaries.csv", row.names = F)


#### END OF SCRIPT ####