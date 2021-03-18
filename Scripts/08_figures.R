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
data_boundaries <- read.csv("Data_final/percent_protected_boundaries.csv")
data_world <- read.csv("Data_final/percent_protected_world.csv")
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
## Add average per habitat per country to add to figure 2
data3 <- data_boundaries %>% 
        select(UNION, ISO_TER1, habitat, pp_all_mpas) %>% 
        group_by(habitat) %>% 
        summarise(percent_protected = mean(pp_all_mpas, na.rm = T)) %>% # mean per habitat for countries 
        mutate(habitat = habitats, 
               type = "countries") %>% 
        rbind(data2) %>% 
        filter(type != "No_take")

plot2 <- ggplot(data3, aes(x = reorder(habitat, percent_protected), y = percent_protected, fill = type)) +
        geom_bar(position="dodge", stat="identity") +
        scale_fill_manual(values = c("#174FB8","#69C6AF"), labels = c("Global", "Countries Average")) +
        theme_minimal() +
        labs(x = "Habtiat", y = "Percent Protection", fill = "") +
        ylim(c(0, 50)) +
        geom_hline(yintercept = 30, linetype = "dashed")
plot2

ggsave("figure2.png", plot2, device = "png", width = 7, height = 5, units = "in", dpi = 600)
