# Joy Kumagai and Fabio Favoretto 
# Date: April 2021
# Figures - GHPI Map with lat/long values
# Habitat Protection Index Project

##### Load Packages #####
library(sf) # for handling spatial vector data
library(rnaturalearth) # for country boundaries
library(graticule) # to create the lat/long lines and labels 
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(ggthemes)
library(patchwork)

##### Load Data ####
data <- read.csv("Data_final/habitat_protection_indexes_average.csv")
data_world <- read.csv("Data_final/percent_protected_world.csv")
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")

land <- ne_countries(scale = 110, returnclass = "sf")

## Projecting data
robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
eez_land <- st_transform(eez_land, crs = robin)


## Join the indicator data onto the eez_land 
eez_land <- left_join(x = eez_land, y = data, by = "UNION")

grid <- st_graticule(lat = seq(-90, 90, by = 30),
                     lon = seq(-180, 180, by = 60)) %>% 
        st_transform("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m") %>% 
        st_geometry 

(p1 <- ggplot(eez_land) +
        geom_sf(aes(fill = L_Hs_P_I, colour = " ")) +
        geom_sf(data = grid,
                colour = "grey60", 
                linetype = "dashed") +
        geom_sf(data = land, 
                col = NA,
                fill = "grey30") +
        annotate("text", x = -18000000, y = 0, label = "0°", size = 3) +
        annotate("text", x = -18000000, y = 3200000, label = "30° N", size = 3) +
        annotate("text", x = -15500000, y = 6200000, label = "60° N", size = 3) +
        annotate("text", x = -18000000, y = -3200000, label = "30° S", size = 3) +
        annotate("text", x = -15500000, y = -6200000, label = "60° S", size = 3) +
        annotate("text", x = 0, y = 9500000, label = "0°", size = 3) +
        annotate("text", x = -3000000, y = 9500000, label = "60°W", size = 3) +
        annotate("text", x = 3000000, y = 9500000, label = "60°E", size = 3) +
        annotate("text", x = -8000000, y = 9500000, label = "180°W", size = 3) +
        annotate("text", x = 8000000, y = 9500000, label = "180°E", size = 3) +
        scale_fill_gradient2(
                low = "#F0EC79",
                mid = "#19AFFF",
                high = "#1810C1",
                midpoint = 0.5,
                space = "Lab",
                na.value = "grey",
                aesthetics = "fill",
                n.breaks = 5, 
               guide = guide_colorbar(title.position = "top",
                                           title.hjust = .5,
                                      barwidth = 10, 
                                      barheight = 0.5
                                      )) +
        scale_colour_manual(values = NA) +              
        guides(colour = guide_legend("No data", override.aes = list(colour = "grey", fill = "grey"))) + 
        
        labs(fill = "Local Habitat Protection Index") +
        theme(panel.background = element_blank(), 
              axis.text.x = element_text(size = 12),
              axis.title = element_blank(),
              legend.position = "bottom"))

ggsave(plot = p1, filename = "Figures/figure3.png", dpi = 600, height = 5, width = 8)


coords <- eez_land %>% 
        st_coordinates() %>% 
        as.data.frame()

eez_land$L3 <- 1:nrow(eez_land)


lat_long_graph <- merge(eez_land, coords, by = "L3")
beepr::beep(1)


lat_graph <- lat_long_graph %>% 
        as.data.frame() %>% 
        dplyr::select(-geometry) %>% 
        mutate(degree = round(Y/100000, 0)) %>% 
        group_by(degree) %>% 
        summarise(index_mean = mean(L_Hs_P_I, na.rm = T))

long_graph <- lat_long_graph %>% 
        as.data.frame() %>% 
        dplyr::select(-geometry) %>% 
        mutate(degree = round(X/100000, 0)) %>% 
        group_by(degree) %>% 
        summarise(index_mean = mean(L_Hs_P_I, na.rm = T))


p2 <- lat_graph %>% 
        ggplot(aes(x = degree)) +
        geom_area(aes(y = index_mean, fill = "#59b300")) +
        labs(y = "Local Habitat Protection Index") +
        scale_x_continuous(breaks = c(-90, -60, -30, 0, 30, 60, 90)) +
        scale_y_continuous(position = "right") +
        scale_fill_manual(values = "#59b300") + 
        guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
        geom_vline(xintercept = 0, linetype = 2, col = "gray60") +
        geom_vline(xintercept = -90, linetype = 2, col = "gray60") +
        geom_vline(xintercept = -60, linetype = 2, col = "gray60") +
        geom_vline(xintercept = 60, linetype = 2, col = "gray60") +
        geom_vline(xintercept = 90, linetype = 2, col = "gray60") +
        coord_flip() +
                theme(panel.background = element_rect(fill = "transparent"),
                      plot.background = element_rect(fill = NA, color = NA),
                      axis.text.x = element_text(size = 6),
                      axis.title.x = element_text(size = 6),
                      axis.ticks.y = element_blank(),
                      axis.title.y = element_blank(),
                      legend.position = "none",
                      legend.background = element_rect(fill = "transparent", colour = NA))

p3 <- long_graph %>% 
                ggplot(aes(x = degree)) +
                geom_area(aes(y = index_mean, fill = "#59b300")) +
                labs(y = "Local Habitat Protection Index") +
                scale_x_continuous(breaks = c(-180, -60, 0, 60, 180)) +
                scale_y_continuous(position = "right") +
                scale_fill_manual(values = "#59b300") + 
                geom_vline(xintercept = 0, linetype = 2, col = "gray60") +
                geom_vline(xintercept = -180, linetype = 2, col = "gray60") +
                geom_vline(xintercept = -60, linetype = 2, col = "gray60") +
                geom_vline(xintercept = 60, linetype = 2, col = "gray60") +
                geom_vline(xintercept = 180, linetype = 2, col = "gray60") +
                theme(panel.background = element_rect(fill = "transparent"),
                      axis.text.y = element_text(size = 6),
                      axis.title.y = element_text(size = 6),
                      axis.ticks.x = element_blank(),
                      axis.title.x = element_blank(),
                      legend.position = "none")



ggplot() +
        coord_equal(xlim = c(0, 2.0),
                    ylim = c(0, 1.5),
                    expand = FALSE) +
        annotation_custom(
                grob = ggplotGrob(p3),
                xmin = 0.07,
                xmax = 1.55,
                ymin = 1,
                ymax = 1.5
        ) +
        annotation_custom(
                grob = ggplotGrob(p1),
                xmin = 0,
                xmax = 1.5,
                ymin = 0,
                ymax = 1
        ) +
        annotation_custom(
                grob = ggplotGrob(p2),
                xmin = 1.5,
                xmax = 2.0,
                ymin = 0.25,
                ymax = 1.05
        ) +
        theme_void()

ggsave('Figures/figure3_w_latlong.png', dpi = 600, height = 5, width = 8)
