# Joy Kumagai and Fabio 
# Date: March 2021
# Figures 
# Marine Habitat Protection Indicator

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
        dplyr::select(UNION, pp_mean_all, pp_mean_notake) %>% 
        unique()


## Projecting data
robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
eez_land <- st_transform(eez_land, crs = robin)


## Join the indicator data onto the eez_land 
eez_land <- left_join(x = eez_land, y = data, by = "UNION") %>% 
        arrange(pp_mean_all)


(p1 <- ggplot(eez_land) +
                geom_sf(aes(fill = pp_mean_all), 
                        col = NA) +
                geom_sf(data = land, 
                        col = "gray60",
                        fill = "gray90") +
                coord_sf() +
                annotate("text", x = -18000000, y = 0, label = "0°") +
                annotate("text", x = -18000000, y = 2300000, label = "20° N") +
                annotate("text", x = -17000000, y = 4500000, label = "40° N") +
                annotate("text", x = -15500000, y = 6500000, label = "60° N") +
                annotate("text", x = -13500000, y = 8500000, label = "80° N") +
                annotate("text", x = -18000000, y = -2300000, label = "20° S") +
                annotate("text", x = -17000000, y = -4500000, label = "40° S") +
                annotate("text", x = -15500000, y = -6500000, label = "60° S") +
                annotate("text", x = 0, y = 9500000, label = "0°") +
                annotate("text", x = -3000000, y = 9500000, label = "50°W") +
                annotate("text", x = 3000000, y = 9500000, label = "50°E") +
                annotate("text", x = -8000000, y = 9500000, label = "150°W") +
                annotate("text", x = 8000000, y = 9500000, label = "150°E") +
                scale_fill_gradient2(
                        low = "#f0f9e8",
                        mid = "#7bccc4",
                        high = "#0868ac",
                        midpoint = 50,
                        space = "Lab",
                        na.value = "grey50",
                        guide = "colourbar",
                        aesthetics = "fill",
                        n.breaks = 5
                ) +
                labs(fill = "% of EEZ") +
                theme(panel.background = element_blank(), 
                      panel.grid.major = element_line(colour = "gray90", linetype = "dashed"), 
                      axis.text.x = element_text(size = 12),
                      axis.title = element_blank()))



(p2 <- ggplot(eez_land) +
                geom_sf(aes(fill = pp_mean_notake), 
                        col = NA) +
                geom_sf(data = land, 
                        col = "gray60",
                        fill = "gray90") +
                coord_sf() +
                annotate("text", x = -18000000, y = 0, label = "0°") +
                annotate("text", x = -18000000, y = 2300000, label = "20° N") +
                annotate("text", x = -17000000, y = 4500000, label = "40° N") +
                annotate("text", x = -15500000, y = 6500000, label = "60° N") +
                annotate("text", x = -13500000, y = 8500000, label = "80° N") +
                annotate("text", x = -18000000, y = -2300000, label = "20° S") +
                annotate("text", x = -17000000, y = -4500000, label = "40° S") +
                annotate("text", x = -15500000, y = -6500000, label = "60° S") +
                annotate("text", x = 0, y = 9500000, label = "0°") +
                annotate("text", x = -3000000, y = 9500000, label = "50°W") +
                annotate("text", x = 3000000, y = 9500000, label = "50°E") +
                annotate("text", x = -8000000, y = 9500000, label = "150°W") +
                annotate("text", x = 8000000, y = 9500000, label = "150°E") +
                scale_fill_gradient2(
                        low = "#f0f9e8",
                        mid = "#7bccc4",
                        high = "#0868ac",
                        midpoint = 50,
                        space = "Lab",
                        na.value = "grey50",
                        guide = "colourbar",
                        aesthetics = "fill"
                ) +
                labs(fill = "% of EEZ") +
                theme(panel.background = element_blank(), 
                      panel.grid.major = element_line(colour = "gray90", linetype = "dashed"), 
                      axis.text.x = element_text(size = 12),
                      axis.title = element_blank()))

p1/p2+
        plot_layout(guides = "collect")+
        plot_annotation(tag_levels = 'A')
ggsave('figure1_with_notake.png', dpi = 600, height = 8, width = 8)


##### Figure 2 #######
## World Data
habitats <- c("Cold Corals", "Coral Reefs", "Knolls & Seamounts", "Mangroves", "Saltmarsh", "Seagrasses")


df1 <- data_world %>% 
        dplyr::select(Name, pixel_counts,) %>% 
        filter(grepl("with_All_mpas", Name) | !grepl("with", Name)) %>% 
        mutate(habitat = rep(habitats, each = 2),
               type = rep(c("All_mpas", "world_total"), length.out = 12)) %>% 
        dplyr::select(-Name) %>% 
        pivot_wider(values_from = pixel_counts, names_from = type)

df2 <- data_boundaries %>% 
        dplyr::select(UNION, habitat, all_mpas) %>% 
        group_by(habitat) %>% 
        summarise(eez_pa_area = sum(all_mpas)) %>% 
        mutate(habitat = habitats)

df3 <- data_highseas %>% 
        dplyr::select(Name, pixel_counts) %>% 
        filter(grepl("with_All_mpas", Name)) %>% 
        mutate(habitat = habitats) %>% 
        dplyr::select(-Name) %>% 
        rename(highseas_pa_area = pixel_counts)

df4 <- left_join(df1, df2, by = "habitat")
df5 <- left_join(df4, df3, by = "habitat") %>% 
        dplyr::select(-All_mpas) %>% 
        pivot_longer(cols = ends_with("area"), names_to = "key", values_to = "pixel_counts") %>% 
        mutate(percent_protected = pixel_counts/world_total)

plot2 <- df5 %>% 
        ggplot(aes(x = reorder(habitat, percent_protected), y = percent_protected, fill = key)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = c("#69C6AF", "#174FB8"), labels = c("National Jurisdiction", "High Seas")) +
        scale_y_continuous(labels = scales::percent_format()) +
        labs(x = "Habitat", y = "Global Protected Area Coverage") +
        theme_bw() +
        theme(legend.title = element_blank()) +
        geom_hline(yintercept = .3, linetype = "dashed")
plot2

ggsave("figure2.png", plot2, device = "png", width = 8, height = 5, units = "in", dpi = 600)
