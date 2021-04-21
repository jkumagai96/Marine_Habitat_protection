# Joy Kumagai and Fabio Favoretto
# Date: April 2021
# Figures - Targeted GHPI Figure of jurisdictions
# Habitat Protection Index Project

##### Load Packages ##### 
library(tidyverse)
library(sf)
library(rnaturalearth)
library(ggthemes)
library(patchwork)
library(ggpubr)

##### Load Data ####

data <- read.csv("Data_final/habitat_protection_indexes_average.csv")
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")
land <- ne_countries(scale = 110, returnclass = "sf")

eez_land_global <- left_join(x = eez_land, y = data, by = "UNION") %>%  # Join the indicator data onto the eez_land 
        arrange(G_Hs_P_I)



# Bar plot for the top and bottom 10 
data1 <- data %>% 
        slice_max(order_by = T_Hs_I, n = 10) 

data2 <- data %>% 
        slice_min(order_by = T_Hs_I, n = 10)

data <- rbind(data1, data2)

data$ISO_TER1 <- replace_na(data$ISO_TER1, "High Seas")

data %>% 
        ggplot(aes(x = reorder(ISO_TER1, T_Hs_I), y = T_Hs_I)) +
        geom_bar(stat = 'identity', aes(fill = T_Hs_I > 0), position = 'dodge', col = 'transparent') +
        theme_bw() +
        scale_fill_manual(guide = 'none',
                          values = c("red3", "#0868ac")) +
        labs(x = "Jurisdictions", y = "Targeted Global Habitat Protection Index") +
        ylim(-max(abs(data$T_Hs_I)), max(abs(data$T_Hs_I))) +
        theme(axis.text.x = element_text(angle = 90, vjust = .5))


ggsave(last_plot(), filename = "Figures/figure4.png", dpi = 600, height = 6, width = 8)


