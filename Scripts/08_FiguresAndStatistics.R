# Joy Kumagai 
# Date: Narch 2021
# Figures 
# Marine Habitat Protection Indicator

##### Load Packages #####
library(sf) # for handling spatial vector data
library(rnaturalearth) # for country boundaries
library(graticule) # to create the lat/long lines and labels 
library(tidyverse) # Easily Install and Load the 'Tidyverse'

##### Load Data ####
data <- read.csv("Data_final/percent_protected_boundaries.csv")
data_world <- read.csv("Data_final/percent_protected_world.csv")
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")

land <- ne_countries(scale = 110, returnclass = "sf")

##### Formating Data #####
data <- data %>% 
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

data2 <- data_world %>% 
  dplyr::select(Name, percent_protected) %>% 
  filter(grepl("All", Name)) %>% 
  mutate(type = "All")%>% 
  mutate(habitat = habitats)

##### Figure 1 ######
# Two maps with average percent protection by country for A) no-take B) all MPAs

# Create graticules 
# Creates latitude and longitude labels and graticules
lat <- c(-90, -60, -30, 0, 30, 60, 90)
long <- c(-180, -120, -60, 0, 60, 120, 180)
labs <- graticule::graticule_labels(lons = long, lats = lat, xline = -180, yline = 90, proj = robin) # labels for the graticules 
lines <- graticule::graticule(lons = long, lats = lat, proj = robin) # graticules 

# plotting 

png("figure1A.png", width = 8, height = 10, units = "in", res = 300)

# plot 1
par(mar = c(1,1,1,1))
plot(lines, lty = 5, col = "grey40") # plots graticules 
text(subset(labs, labs$islon), lab = parse(text = labs$lab[labs$islon]), pos = 3, xpd = NA) # plots longitude labels
text(subset(labs, !labs$islon), lab = parse(text = labs$lab[!labs$islon]), pos = 2, xpd = NA) # plots latitude labels
raster::plot(eez_land["pp_mean_all"], border = "grey", add = TRUE)
raster::plot(land[,1], col = "white", border = "grey", add = TRUE)
legend(legend = )


##### Figure 2 #####
# Stacked bar graph of protection for each habitat included 

plot2 <- ggplot(data2, aes(x = reorder(habitat, -percent_protected), y = percent_protected)) +
  geom_bar(stat="identity", fill = "#0F52BA") +
  geom_hline(yintercept = 30, linetype = "dashed", col = "black") +
  theme_minimal() +
  labs(x = "Habtiat", y = "Protection Globally (%)") 

plot2

ggsave("figure2.png", plot2, device = "png", width = 7, height = 5, units = "in", dpi = 600)
