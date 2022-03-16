# Joy Kumagai and Fabio Favoretto
# Date: March 2022
# Figures - Overview Figure of habitats 
# Habitat Protection Index Project

##### Load Packages #####
library(sf) # for handling spatial vector data
library(rnaturalearth) # for country boundaries
library(graticule) # to create the lat/long lines and labels 
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(ggthemes)
library(patchwork)

##### Load Data ####
data_boundaries <- read.csv("Data_final/percent_protected_boundaries.csv")
data_world <- read.csv("Data_final/percent_protected_world.csv")
data_highseas <- read.csv("Data_final/percent_protected_highseas.csv")
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")

land <- ne_countries(scale = 110, returnclass = "sf")

##### Formating Data #####

data <- data_boundaries %>% 
        dplyr::select(UNION, pp_mean_all) %>% 
        unique()


## Projecting data
robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
eez_land <- st_transform(eez_land, crs = robin)


## Join the indicator data onto the eez_land 
eez_land <- left_join(x = eez_land, y = data, by = "UNION") %>% 
        arrange(pp_mean_all)


##### Figure 1 #######

## World Data
habitats <- c("Cold-water Corals", "Warm-water Corals", "Knolls & Seamounts", "Mangroves", "Saltmarsh", "Seagrasses")


#df1 <- data_world %>% 
#        dplyr::select(Name, pixel_counts) %>% 
#        filter(grepl("with_All_mpas", Name) | !grepl("with", Name)) %>% 
#        mutate(habitat = rep(habitats, each = 2),
#               type = rep(c("All_mpas", "world_total"), length.out = 12)) %>% 
#        dplyr::select(-Name) %>% 
#        pivot_wider(values_from = pixel_counts, names_from = type)

df2 <- data_boundaries %>% 
        dplyr::select(UNION, habitat, all_mpas, total) %>% 
        group_by(habitat) %>% 
        summarise(eez_pa_area = sum(all_mpas),
                  eez_total_area = sum(total)) %>% 
        mutate(habitat = habitats)

df3 <- data_highseas %>% 
        dplyr::select(Name, pixel_counts) %>% 
        filter(grepl("with_All_mpas", Name)) %>% 
        mutate(habitat = habitats) %>% 
        dplyr::select(-Name) %>% 
        rename(highseas_pa_area = pixel_counts)

df3b <- data_highseas %>% 
        dplyr::select(Name, pixel_counts) %>% 
        filter(!grepl("with_", Name)) %>% 
        mutate(habitat = habitats) %>% 
        dplyr::select(-Name) %>% 
        rename(highseas_total_area = pixel_counts)
df3 <- left_join(df3, df3b, by = "habitat")

df4 <- df2
df5 <- left_join(df4, df3, by = "habitat") %>% 
        mutate(world_total = eez_total_area + highseas_total_area) %>% 
        pivot_longer(cols = ends_with("area"), names_to = "key", values_to = "pixel_counts") 

plot2 <- df5 %>% 
        filter(key == "eez_pa_area" | key == "highseas_pa_area") %>% 
        mutate(percent_protected = pixel_counts/world_total) %>% 
        ggplot(aes(x = reorder(habitat, percent_protected), y = percent_protected, fill = key)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = c("#69C6AF", "#174FB8"), labels = c("Jurisdictions", "ABNJ")) +
        scale_y_continuous(labels = scales::percent_format()) +
        labs(x = "Habitat", y = "Global PCAs coverage") +
        theme_bw() +
        theme(legend.title = element_blank(),
              legend.position="top",
              axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
        geom_hline(yintercept = 0.0792, lwd = 1) +   
        geom_hline(yintercept = .3, linetype = "dashed")

plot1 <- df5 %>% 
        filter(key == "eez_total_area" | key == "highseas_total_area") %>% 
        mutate(percent = pixel_counts/world_total) %>% 
        mutate(f = c(3,3,4,4,1,1,5,5,6,6,2,2)) %>% 
        ggplot(aes(x = reorder(habitat, f), y = percent, fill = key)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = c("#69C6AF", "#174FB8"), labels = c("Jurisdictions", "ABNJ")) +
        scale_y_continuous(labels = scales::percent_format()) +
        labs(x = "Habitat", y = "Proportion of global habitat") +
        theme_bw() +
        theme(legend.title = element_blank(),
              legend.position="top",
              axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) 

plot1 + plot2 +
        plot_annotation(tag_levels = 'a')

ggsave("Figures/figure1.png", device = "png", width = 10, height = 5, units = "in", dpi = 600)
ggsave("Figures/figure1.pdf", device = "pdf", width = 10, height = 5, units = "in")