# Joy Kumagai 
# Date: March 2021
# Figures 
# Marine Habitat Protection Indicator

##### Load Packages #####
library(sf) # for handling spatial vector data
library(rnaturalearth) # for country boundaries
library(graticule) # to create the lat/long lines and labels 
library(tidyverse) # Easily Install and Load the 'Tidyverse'

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
robin <- "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
eez_land <- st_transform(eez_land, crs = robin)


## Join the indicator data onto the eez_land 
eez_land <- left_join(x = eez_land, y = data, by = "UNION") %>% 
  arrange(pp_mean_all)

## World Data
habitats <- c("Cold Corals", "Warm-water Corals", "Mangroves", "Saltmarsh", "Seagrasses")

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
  pivot_longer(cols = c(No_take, All), names_to = "type", values_to = "percent_protected") 

## Add average per habitat per country to add to figure 2
data3 <- data_boundaries %>% 
  select(UNION, ISO_TER1, habitat, pp_all_mpas) %>% 
  group_by(habitat) %>% 
  summarise(percent_protected = mean(pp_all_mpas, na.rm = T)) %>% # mean per habitat for countries 
  mutate(habitat = habitats, 
         type = "countries") %>% 
  rbind(data2) %>% 
  filter(type != "No_take")

##### Figure 1 ######
# Two maps with average percent protection by country for A) no-take B) all MPAs

# Create graticules 
# Creates latitude and longitude labels and graticules
lat <- c(-90, -60, -30, 0, 30, 60, 90)
long <- c(-180, -120, -60, 0, 60, 120, 180)
labs <- graticule::graticule_labels(lons = long, lats = lat, xline = -180, yline = 90, proj = robin) # labels for the graticules 
lines <- graticule::graticule(lons = long, lats = lat, proj = robin) # graticules 

# Create classes to show the data for all MPAs
classes <- c('0-10%','10-30%', '30-50%', '50-75%', '75-100%')
eez_land$pp_mean_groups <- NA
eez_land$pp_mean_groups[eez_land$pp_mean_all <= 10] <- 1
eez_land$pp_mean_groups[eez_land$pp_mean_all > 10 & eez_land$pp_mean_all <= 30] <- 2 
eez_land$pp_mean_groups[eez_land$pp_mean_all > 30 & eez_land$pp_mean_all <= 50] <- 3 
eez_land$pp_mean_groups[eez_land$pp_mean_all > 50 & eez_land$pp_mean_all <= 75] <- 4 
eez_land$pp_mean_groups[eez_land$pp_mean_all > 75 & eez_land$pp_mean_all <= 100] <- 5 

eez_land$cols <- c("#D1EAF0", "#92E1F7","#3AD0F9","#2195B6","#034B60")[eez_land$pp_mean_groups]

# Create classes to show the data for just no-take MPAs
classes2 <- c('0%','<2%', '2-5%', '5-10%', '>10%')
eez_land$pp_mean_notake_groups <- NA
eez_land$pp_mean_notake_groups[eez_land$pp_mean_notake == 0] <- 1
eez_land$pp_mean_notake_groups[eez_land$pp_mean_notake > 0 & eez_land$pp_mean_notake <= 2] <- 2 
eez_land$pp_mean_notake_groups[eez_land$pp_mean_notake > 2 & eez_land$pp_mean_notake <= 5] <- 3 
eez_land$pp_mean_notake_groups[eez_land$pp_mean_notake > 5 & eez_land$pp_mean_notake <= 10] <- 4 
eez_land$pp_mean_notake_groups[eez_land$pp_mean_notake > 10] <- 5 

# plotting 

png("figure1.png", width = 8, height = 10, units = "in", res = 300)
par(mfrow = c(2,1))

# plot 1
par(mar = c(1,1,1,1))
plot(lines, lty = 5, col = "grey") # plots graticules 
text(subset(labs, labs$islon), lab = parse(text = labs$lab[labs$islon]), pos = 3, xpd = NA) # plots longitude labels
text(subset(labs, !labs$islon), lab = parse(text = labs$lab[!labs$islon]), pos = 2, xpd = NA) # plots latitude labels
raster::plot(land[,1], col = "grey", border = "transparent", add = TRUE)
raster::plot(eez_land["pp_mean_groups"], col = eez_land$cols, border = "transparent", add = TRUE)
legend("bottom", classes, fill = unique(eez_land$cols), bty = 'n', ncol = 5)
raster::plot(land[,1], col = "transparent", border = "black", add = TRUE)
title("A", adj = 0.1, line = -1, cex.main = 2)

# plot 2
eez_land <- eez_land %>% arrange(pp_mean_notake)
eez_land$cols2 <- c("#D1EAF0", "#92E1F7","#3AD0F9","#2195B6","#034B60")[eez_land$pp_mean_notake_groups]

par(mar = c(1,1,1,1))
plot(lines, lty = 5, col = "grey") # plots graticules 
text(subset(labs, labs$islon), lab = parse(text = labs$lab[labs$islon]), pos = 3, xpd = NA) # plots longitude labels
text(subset(labs, !labs$islon), lab = parse(text = labs$lab[!labs$islon]), pos = 2, xpd = NA) # plots latitude labels
raster::plot(land[,1], col = "grey", border = "transparent", add = TRUE)
raster::plot(eez_land["pp_mean_notake_groups"], col = eez_land$cols2, border = "transparent", add = TRUE)
legend("bottom", classes2, fill = unique(eez_land$cols2), bty = 'n', ncol = 5)
raster::plot(land[,1], col = "transparent", border = "black", add = TRUE)
title("B", adj = 0.1, line = -1, cex.main = 2)

dev.off()
##### Figure 2 #####
# Stacked bar graph of protection for each habitat included 

plot2 <- ggplot(data3, aes(x = reorder(habitat, percent_protected), y = percent_protected, fill = type)) +
  geom_bar(position="dodge", stat="identity") +
  scale_fill_manual(values = c("#174FB8","#69C6AF"), labels = c("Global", "Countries Average")) +
  theme_minimal() +
  labs(x = "Habtiat", y = "Percent Protection", fill = "") +
  ylim(c(0, 50)) +
  geom_hline(yintercept = 30, linetype = "dashed")
plot2

ggsave("figure2.png", plot2, device = "png", width = 7, height = 5, units = "in", dpi = 600)
