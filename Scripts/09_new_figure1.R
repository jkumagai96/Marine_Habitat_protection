# Joy Kumagai 
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
data <- read.csv("Data_final/percent_protected_boundaries.csv")
data_world <- read.csv("Data_final/percent_protected_world.csv")
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")

land <- ne_countries(scale = 110, returnclass = "sf")

##### Formating Data #####

data <- data %>% 
        dplyr::select(UNION, total, all_mpas, pp_mean_all, pp_mean_notake) %>% 
        unique()


## Projecting data
robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
eez_land <- st_transform(eez_land, crs = robin)


## Join the indicator data onto the eez_land 
eez_land <- left_join(x = eez_land, y = data, by = "UNION") %>% 
        arrange(pp_mean_all)

## World Data
habitats <- c("Cold Corals", "Coral Reefs", "Mangroves", "Saltmarsh", "Seagrasses")

no_take <- data_world %>% 
        dplyr::select(Name, percent_protected) %>% 
        filter(grepl("No_take",Name)) %>% 
        mutate(type = "No_take") %>% 
        mutate(habitat = habitats)

all <- data_world %>% 
        dplyr::select(Name, percent_protected) %>% 
        filter(grepl("All", Name)) %>% 
        mutate(type = "All") %>% 
        mutate(habitat = habitats)

data2 <- rbind(no_take, all) %>% 
        dplyr::select(habitat, percent_protected, type) %>% 
        pivot_wider(names_from = type, values_from = percent_protected) %>% 
        mutate(difference = All - No_take) %>% 
        dplyr::select(-All) %>% 
        pivot_longer(cols = c(No_take, difference), names_to = "type", values_to = "percent_protected") 

grid <- st_graticule(lat = seq(-90, 90, by = 30),
                     lon = seq(-180, 180, by = 60)) %>% 
        st_transform("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m") %>% 
        st_geometry 

(p1 <- ggplot(eez_land) +
        geom_sf(aes(fill = pp_mean_all, colour = " ")) +
        geom_sf(data = grid,
                colour = "gray80", 
                linetype = "dashed") +
        geom_sf(data = land, 
                col = NA,
                fill = "gray90") +
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
                low = "#f0f9e8",
                mid = "#7bccc4",
                high = "#0868ac",
                midpoint = 50,
                space = "Lab",
                na.value = "black",
                aesthetics = "fill",
                n.breaks = 5, 
               guide = guide_colorbar(title.position = "top",
                                           title.hjust = .5,
                                      barwidth = 10, 
                                      barheight = 0.5
                                      )) +
        scale_colour_manual(values = NA) +              
        guides(colour = guide_legend("No data", override.aes = list(colour = "black", fill = "black"))) + 
        
        labs(fill = "Avg. % of protected habitats") +
        theme(panel.background = element_blank(), 
              axis.text.x = element_text(size = 12),
              axis.title = element_blank(),
              legend.position = "bottom"))


coords <- eez_land %>% 
        st_coordinates() %>% 
        as.data.frame()

eez_land$L3 <- 1:nrow(eez_land)


lat_long_graph <- merge(eez_land, coords, by = "L3")
beepr::beep(1)


lat_graph <- lat_long_graph %>% 
        as.data.frame() %>% 
        select(-geometry) %>% 
        group_by(Y) %>% 
        summarise(mpa_area = mean(all_mpas, na.rm = T), pp = mean(pp_mean_all, na.rm = T), h_area = mean(total, na.rm = T))

long_graph <- lat_long_graph %>% 
        as.data.frame() %>% 
        select(-geometry) %>% 
        group_by(X) %>% 
        summarise(mpa_area = mean(all_mpas, na.rm = T), pp = mean(pp_mean_all, na.rm = T), h_area = mean(total, na.rm = T))


colors <- c("Protected area" = "blue", "Total area" = "red")



(p2 <- lat_graph %>% 
        mutate(degree = round(Y/100000, 0)) %>% 
        group_by(degree) %>% 
        summarise(pp = mean(mpa_area, na.rm = T), h_area = mean(h_area, na.rm = T)) %>% 
        ggplot(aes(x = degree)) +
        geom_area(aes(y = pp, fill = "Protected area"), alpha = .3) +
        geom_area(aes(y = h_area, fill = "Total area"), alpha = .3) +
        labs(y = expression(Area ~ km^2), fill = " ") +
        scale_x_continuous(breaks = c(-90, -60, -30, 0, 30, 60, 90)) +
        scale_y_continuous(position = "right") +
        scale_fill_manual(values = colors) + 
        guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
        coord_flip() +
                theme(panel.background = element_rect(fill = "transparent"),
                      plot.background = element_rect(fill = NA, color = NA),
                      axis.text.y = element_blank(),
                      axis.text.x = element_text(size = 6),
                      axis.title.x = element_text(size = 6),
                      axis.ticks.y = element_blank(),
                      axis.title.y = element_blank(),
                      legend.position = "top",
                      legend.background = element_rect(fill = "transparent", colour = NA)))

(p3 <- long_graph %>% 
                mutate(degree = round(X/100000, 0)) %>% 
                group_by(degree) %>% 
                summarise(pp = mean(mpa_area, na.rm = T), h_area = mean(h_area, na.rm = T)) %>% 
                ggplot(aes(x = degree)) +
                geom_area(aes(y = pp), fill = "blue", alpha = .3) +
                geom_area(aes(y = h_area), fill = "red", alpha = .3) +
                labs(y = expression(Area ~ km^2)) +
                scale_x_continuous(breaks = c(-90, -60, -30, 0, 30, 60, 90)) +
                scale_y_continuous(position = "right") +
                theme(panel.background = element_rect(fill = "transparent"),
                      axis.text.x = element_blank(),
                      axis.text.y = element_text(size = 6),
                      axis.title.y = element_text(size = 6),
                      axis.ticks.x = element_blank(),
                      axis.title.x = element_blank()))



ggplot() +
        coord_equal(xlim = c(0, 2.0),
                    ylim = c(0, 1.5),
                    expand = FALSE) +
        annotation_custom(
                grob = ggplotGrob(p3),
                xmin = 0.08,
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
                ymin = 0.24,
                ymax = 1.3
        ) +
        theme_void()

ggsave('figure1b.png', dpi = 600, height = 5, width = 8)

