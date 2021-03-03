# Joy Kumagai 
# Date: Narch 2021
# Figures 
# Marine Habitat Protection Indicator

##### Load Packages #####
library(sf)
library(rnaturalearth)
library(graticule) 
library(tidyverse)

##### Load Data ####
data <- read.csv("Data_final/percent_protected_boundaries.csv")
data_world <- read.csv("Data_final/percent_protected_world.csv")
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")

land <- ne_countries(scale = 110, returnclass = "sf")

##### Formating Data #####

# Projecting data
robin <- "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
eez_land <- st_transform(eez_land, crs = robin)

# Join the indicator data onto the eez_land 
eez_land$UNION
eez_land$testdata <- sample(1:100, 323, replace = TRUE)
eez_land <- eez_land %>% 
  filter(UNION != "United States", 
         UNION != "China")


# World Data
habitats <- c("Cold Corals", "Coral Reefs", "Mangroves", "Saltmarsh", "Seagrasses")

no_take <- data_world %>% 
  dplyr::select(Name, percent_protected) %>% 
  filter(grepl("No_take",Name)) %>% 
  mutate(type = "No_take") %>% 
  mutate(habitat = habitats)

all <- data_world %>% 
  dplyr::select(Name, percent_protected) %>% 
  filter(grepl("All", Name)) %>% 
  mutate(type = "All")%>% 
  mutate(habitat = habitats)

data2 <- rbind(no_take, all) %>% 
  dplyr::select(habitat, percent_protected, type) %>% 
  pivot_wider(names_from = type, values_from = percent_protected) %>% 
  mutate(difference = All - No_take) %>% 
  dplyr::select(-All) %>% 
  pivot_longer(cols = c(No_take, difference), names_to = "type", values_to = "percent_protected") 
##### Figure 1 ######
# Two maps with average percent protection by country for A) no-take B) all MPAs

# Create graticules 
# Creates latitude and longitude labels and graticules
lat <- c(-90, -60, -30, 0, 30, 60, 90)
long <- c(-180, -120, -60, 0, 60, 120, 180)
labs <- graticule::graticule_labels(lons = long, lats = lat, xline = -180, yline = 90, proj = robin) # labels for the graticules 
lines <- graticule::graticule(lons = long, lats = lat, proj = robin) # graticules 

# plotting 
png("figure1.png", width = 8, height = 10.5, units = "in", res = 300)

par(mfcol = c(2,1))
# plot 1
plot(lines, lty = 5, col = "grey") # plots graticules 
text(subset(labs, labs$islon), lab = parse(text = labs$lab[labs$islon]), pos = 3, xpd = NA) # plots longitude labels
text(subset(labs, !labs$islon), lab = parse(text = labs$lab[!labs$islon]), pos = 2, xpd = NA) # plots latitude labels
raster::plot(eez_land[,32], border = "transparent", add = TRUE)
raster::plot(land[,1], col = "transparent", border = "black", add = TRUE)
title("A", adj = 0.1, line = -1, cex.main = 2)

# plot 2
plot(lines, lty = 5, col = "grey") # plots graticules 
text(subset(labs, labs$islon), lab = parse(text = labs$lab[labs$islon]), pos = 3, xpd = NA) # plots longitude labels
text(subset(labs, !labs$islon), lab = parse(text = labs$lab[!labs$islon]), pos = 2, xpd = NA) # plots latitude labels
raster::plot(eez_land[,6], col = "lightblue", border = "transparent", add = TRUE)
raster::plot(land[,1], col = "transparent", border = "black", add = TRUE)
title("B", adj = 0.1, line = -1, cex.main = 2)

dev.off()
##### Figure 2 #####
# Stacked bar graph of protection for each habitat included 

plot2 <- ggplot(data2, aes(x = habitat, y = percent_protected, fill = type)) +
  geom_bar(position="stack", stat="identity") +
  scale_fill_manual(values = c("#BADDF5","#174FB8"), labels = c("All", "No-take")) +
  theme_minimal() +
  labs(x = "Habtiat", y = "Percent Protection Globally", fill = "Type of Protected Areas") 

ggsave("figure2.png", plot2, device = "png", width = 7, height = 5, units = "in", dpi = 600)
