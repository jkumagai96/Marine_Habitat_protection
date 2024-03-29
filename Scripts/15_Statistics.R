# Joy Kumagai 
# Date: April 2021
# Descriptive Statistics
# Habitat Protection Index Project

##### Load Packages #####
library(tidyverse) # Easily Install and Load the 'Tidyverse'

##### Descriptive Statistics #####
data <- read.csv("Data_final/habitat_protection_indexes_average.csv", encoding = "UTF-8")

## Global Habitat Protection Index (top jurisdictions)
top_5 <- data %>% 
  slice_max(order_by = G_Hs_P_I, n = 5) %>% 
  print()

sum(top_5$G_Hs_P_I)

## Counts for L_Hs_P_I (Local Habitat Protection Index)
n <- data %>% 
  drop_na(L_Hs_P_I) %>% 
  count() %>% 
  print()

n_zero <- data %>% 
  filter(L_Hs_P_I == 0) %>% 
  count() %>% 
  print()

n_hundred <- data %>% 
  filter(L_Hs_P_I == 1) %>% 
  count() %>% 
  print()

data %>% 
  filter(L_Hs_P_I < .27) %>% 
  count()

data %>% 
  filter(L_Hs_P_I > .50) %>% 
  count()

data %>% 
  slice_max(order_by = L_Hs_P_I, n = 20)

## Histograms 
# Global Habitat Protection Index 
hist(data$G_Hs_P_I)
hist(log(data$G_Hs_P_I))

# Local Habitat Protection Index 
hist(data$L_Hs_P_I)
quantile(data$L_Hs_P_I, na.rm = TRUE)


## Targeted Global Habitat Protection Index
data %>% 
  slice_max(order_by = T_Hs_I, n = 10) # Top 10 

hist(data$T_Hs_I)

data %>% 
  filter(T_Hs_I > 0) %>% 
  count()

data %>% 
  filter(T_Hs_I < 0) %>% 
  count()

## Habitat Specific Counts of Jurisdictions
data2 <- read.csv("Data_final/habitat_protection_indexes.csv", encoding = "UTF-8")
data2 %>% 
  filter(habitat == "coldcorals") %>% 
  drop_na(T_H_I) %>%
  #filter(T_H_I > 0) %>% 
  count()

data2 %>% 
  filter(habitat == "coralreefs") %>% 
  drop_na(T_H_I) %>% 
  #filter(T_H_I > 0) %>% 
  count()

data2 %>% 
  filter(habitat == "knolls_seamounts") %>% 
  drop_na(T_H_I) %>% 
  #filter(T_H_I > 0) %>% 
  count()

data2 %>% 
  filter(habitat == "mangroves") %>% 
  drop_na(T_H_I) %>% 
  #filter(T_H_I > 0) %>% 
  count()

data2 %>% 
  filter(habitat == "saltmarshes") %>% 
  drop_na(T_H_I) %>% 
  #filter(T_H_I > 0) %>% 
  count()

data2 %>% 
  filter(habitat == "seagrasses") %>% 
  drop_na(T_H_I) %>% 
  #filter(T_H_I > 0) %>% 
  count()

