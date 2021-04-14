# Joy Kumagai and Fabio Favoretto 
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
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")

land <- ne_countries(scale = 110, returnclass = "sf")

##### Formating Data #####

data_boundaries <- data_boundaries %>% 
        dplyr::select(UNION, total, all_mpas, pp_mean_all, pp_mean_notake) %>% 
        unique()


## Projecting data
robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
eez_land <- st_transform(eez_land, crs = robin)


## Join the indicator data onto the eez_land 
eez_land <- left_join(x = eez_land, y = data_boundaries, by = "UNION") %>% 
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
        
        labs(fill = "Local Habitat Protection Index (Average)") +
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
        mutate(degree = round(Y/100000, 0)) %>% 
        group_by(degree) %>% 
        summarise(mpa_area = mean(all_mpas, na.rm = T), h_area = mean(total, na.rm = T))

long_graph <- lat_long_graph %>% 
        as.data.frame() %>% 
        select(-geometry) %>% 
        mutate(degree = round(X/100000, 0)) %>% 
        group_by(degree) %>% 
        summarise(mpa_area = mean(all_mpas, na.rm = T), h_area = mean(total, na.rm = T))


colors <- c("Protected area" = "blue", "Total area" = "red")



(p2 <- lat_graph %>% 
        ggplot(aes(x = degree)) +
        geom_area(aes(y = mpa_area, fill = "Protected area"), alpha = .3) +
        geom_area(aes(y = h_area, fill = "Total area"), alpha = .3) +
        labs(y = expression(paste("Average ", Area ~ km^2)), fill = " ") +
        scale_x_continuous(breaks = c(-90, -60, -30, 0, 30, 60, 90)) +
        scale_y_continuous(position = "right") +
        scale_fill_manual(values = colors) + 
        guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
        geom_vline(xintercept = 0, linetype = 2, col = "gray90") +
        geom_vline(xintercept = -90, linetype = 2, col = "gray90") +
        geom_vline(xintercept = -60, linetype = 2, col = "gray90") +
        geom_vline(xintercept = 60, linetype = 2, col = "gray90") +
        geom_vline(xintercept = 90, linetype = 2, col = "gray90") +
        coord_flip() +
                theme(panel.background = element_rect(fill = "transparent"),
                      plot.background = element_rect(fill = NA, color = NA),
                      axis.text.x = element_text(size = 6),
                      axis.title.x = element_text(size = 6),
                      axis.ticks.y = element_blank(),
                      axis.title.y = element_blank(),
                      legend.position = "top",
                      legend.background = element_rect(fill = "transparent", colour = NA)))

(p3 <- long_graph %>% 
                ggplot(aes(x = degree)) +
                geom_area(aes(y = mpa_area), fill = "blue", alpha = .3) +
                geom_area(aes(y = h_area), fill = "red", alpha = .3) +
                labs(y = expression(paste("Average ", Area ~ km^2)), fill = " ") +
                scale_x_continuous(breaks = c(-180, -60, 0, 60, 180)) +
                scale_y_continuous(position = "right") +
                geom_vline(xintercept = 0, linetype = 2, col = "gray90") +
                geom_vline(xintercept = -180, linetype = 2, col = "gray90") +
                geom_vline(xintercept = -60, linetype = 2, col = "gray90") +
                geom_vline(xintercept = 60, linetype = 2, col = "gray90") +
                geom_vline(xintercept = 180, linetype = 2, col = "gray90") +
                theme(panel.background = element_rect(fill = "transparent"),
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
                xmin = 0.09,
                xmax = 1.58,
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
                ymax = 1.31
        ) +
        theme_void()

ggsave('Figures/figure3.png', dpi = 600, height = 5, width = 8)



### Statistics ####

lat_long_stats <- lat_long_graph %>% 
        as.data.frame() %>% 
        select(-geometry) %>% 
        mutate(x_degree = round(X/100000, 0), y_degree = round(Y/100000, 0)) %>% 
        group_by(x_degree, y_degree) %>% 
        summarise(mpa_area = mean(all_mpas, na.rm = T), h_area = mean(total, na.rm = T))

north <- lat_long_stats %>% 
        filter(y_degree > 0) %>% 
        mutate(perc = (mpa_area/h_area)*100) %>% 
        ungroup() %>% 
        summarise(mean_perc = mean(perc, na.rm = T), ste = sd(perc, na.rm = T)/sqrt(length(perc))) %>% 
        print()

south <- lat_long_stats %>% 
        filter(y_degree < 0) %>% 
        mutate(perc = (mpa_area/h_area)*100) %>% 
        ungroup() %>% 
        summarise(mean_perc = mean(perc, na.rm = T), ste = sd(perc, na.rm = T)/sqrt(length(perc))) %>% 
        print()

west <- lat_long_stats %>% 
        filter(x_degree < 0) %>% 
        mutate(perc = (mpa_area/h_area)*100) %>% 
        ungroup() %>% 
        summarise(mean_perc = mean(perc, na.rm = T), ste = sd(perc, na.rm = T)/sqrt(length(perc))) %>% 
        print()

east <- lat_long_stats %>% 
        filter(x_degree > 0) %>% 
        mutate(perc = (mpa_area/h_area)*100) %>% 
        ungroup() %>% 
        summarise(mean_perc = mean(perc, na.rm = T), ste = sd(perc, na.rm = T)/sqrt(length(perc))) %>% 
        print()

north_west <- lat_long_stats %>% 
        filter(x_degree < 0 & y_degree > 0) %>% 
        mutate(perc = (mpa_area/h_area)*100) %>% 
        ungroup() %>% 
        summarise(mean_perc = mean(perc, na.rm = T), ste = sd(perc, na.rm = T)/sqrt(length(perc))) %>% 
        print()

south_west <- lat_long_stats %>% 
        filter(x_degree < 0 & y_degree < 0) %>% 
        mutate(perc = (mpa_area/h_area)*100) %>% 
        ungroup() %>% 
        summarise(mean_perc = mean(perc, na.rm = T), ste = sd(perc, na.rm = T)/sqrt(length(perc))) %>% 
        print()

north_east <- lat_long_stats %>% 
        filter(x_degree > 0 & y_degree > 0) %>% 
        mutate(perc = (mpa_area/h_area)*100) %>% 
        ungroup() %>% 
        summarise(mean_perc = mean(perc, na.rm = T), ste = sd(perc, na.rm = T)/sqrt(length(perc))) %>% 
        print()

south_east <- lat_long_stats %>% 
        filter(x_degree > 0 & y_degree < 0) %>% 
        mutate(perc = (mpa_area/h_area)*100) %>% 
        ungroup() %>% 
        summarise(mean_perc = mean(perc, na.rm = T), ste = sd(perc, na.rm = T)/sqrt(length(perc))) %>% 
        print()


results <- data.frame(
        world = c("North", 
                  "South", 
                  "West", 
                  "East", 
                  "North west", 
                  "South west", 
                  "North east", 
                  "South east"),
        mean = c(north$mean_perc, 
                   south$mean_perc, 
                   west$mean_perc, 
                   east$mean_perc, 
                   north_west$mean_perc, 
                   south_west$mean_perc, 
                   north_east$mean_perc, 
                   south_east$mean_perc),
        ste = c(north$ste, 
                 south$ste, 
                 west$ste, 
                 east$ste, 
                 north_west$ste, 
                 south_west$ste, 
                 north_east$ste, 
                 south_east$ste)) %>% 
        mutate(ste = round(ste, 2))

(p1 <- results[1:4,] %>% 
        ggplot(aes(x = reorder(world, mean),  y = mean)) +
        geom_point() +
        geom_errorbar(aes(ymin = mean-ste, ymax = mean + ste)) +
        labs(x = "World section", y = "Average % protected") +
        ylim(0, 50) +
        theme_bw()
        )

(p2 <- results[5:8,] %>% 
                ggplot(aes(x = reorder(world, mean),  y = mean)) +
                geom_point() +
                geom_errorbar(aes(ymin = mean-ste, ymax = mean + ste)) +
                labs(x = "World section", y = "Average % protected") +
                ylim(0, 50) +
                theme_bw() +
                theme(axis.text.y = element_blank(), 
                      axis.title.y = element_blank())
)

p1 + p2 +
        plot_annotation(tag_levels = 'A')

ggsave("Figures/supplementary_world_section_protected.png", dpi = 300, height = 5, width = 7)
