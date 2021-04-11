# Joy Kumagai and Fabio Favoretto
# Date: April 2021
# Creating the Index Figures 
# Habitat Protection Index Project

##### Load Packages ##### 
library(tidyverse)
library(sf)
library(rnaturalearth)
library(ggthemes)
library(patchwork)
library(ggpubr)
library(countrycode)

##### Load Habitat Protection Indexes ####

df <- read.csv("Data_final/habitat_protection_indexes.csv")

##### Overal Index Figures ####
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")
land <- ne_countries(scale = 110, returnclass = "sf")


data <- df %>%
        group_by(UNION) %>% 
        summarise(G_Hs_P_I = mean(G_H_I, na.rm = T),
                  L_Hs_P_I = mean(F_H_P, na.rm = T),
                  T_Hs_I = mean(T_H_I, na.rm = T))

eez_land_global <- left_join(x = eez_land, y = data, by = "UNION") %>%  # Join the indicator data onto the eez_land 
        arrange(G_Hs_P_I)



# Bar plot for the top and bottom 10 
data1 <- data %>% 
        slice_max(order_by = T_Hs_I, n = 10) 

data2 <- data %>% 
        slice_min(order_by = T_Hs_I, n = 10)

data <- rbind(data1, data2)

country_iso <- countrycode(sourcevar = data$UNION,
                           origin = "country.name",
                           destination = "iso3c")

country_iso <- replace_na(country_iso, "High Seas")

data$ISO <- country_iso

data %>% 
        na.omit() %>% 
        ggplot(aes(x = reorder(ISO, T_Hs_I), y = T_Hs_I)) +
        geom_bar(stat = 'identity', aes(fill = T_Hs_I > 0), position = 'dodge', col = 'transparent') +
        theme_bw() +
        scale_fill_manual(guide = 'none',
                          values = c("red3", "#0868ac")) +
        labs(x = "Jurisdictions", y = "Targeted GHPI") +
        theme(axis.text.x = element_text(angle = 90, vjust = .5))


ggsave(last_plot(), filename = "Figures/figure4.png", dpi = 600, height = 6, width = 8)


