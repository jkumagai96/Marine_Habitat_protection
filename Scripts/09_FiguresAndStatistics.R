# Joy Kumagai 
# Date: Narch 2021
# Figures 
# Marine Habitat Protection Indicator

##### Load Packages #####
library(sf)
library(rnaturalearth)
library(graticule) 

##### Load Data ####
data <- read.csv("Data_final/percent_protected_boundaries.csv")
data_world <- read.csv("Data_final/percent_protected_world.csv")
eez_land <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp")

land <- ne_countries(scale = 110, returnclass = "sf")

##### Formating Data #####

# Projecting data
robin <- "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m"
land <- st_transform(land, crs = robin)
land_l <- st_cast(land,"POLYGON")
land_t <- st_cast(land_l, "LINESTRING")
eez_land <- st_transform(eez_land, crs = robin)

# Join the indicator data onto the eez_land 

##### Figure 1 ######
# Two maps with average percent protection by country for A) no-take B) all MPAs

# Create graticules 
# Creates latitude and longitude labels and graticules
lat <- c(-90, -60, -30, 0, 30, 60, 90)
long <- c(-180, -120, -60, 0, 60, 120, 180)
labs <- graticule::graticule_labels(lons = long, lats = lat, xline = -180, yline = 90, proj = robin) # labels for the graticules 
lines <- graticule::graticule(lons = long, lats = lat, proj = robin) # graticules 

# plotting 

png("figure1.png", units="in", width=8, height=10, res=600)

par(mfrow=c(2,1))
# plot 1
plot(lines, lty = 5, col = "grey") # plots graticules 
text(subset(labs, labs$islon), lab = parse(text = labs$lab[labs$islon]), pos = 3, xpd = NA) # plots longitude labels
text(subset(labs, !labs$islon), lab = parse(text = labs$lab[!labs$islon]), pos = 2, xpd = NA) # plots latitude labels
raster::plot(eez_land[,6], col = "grey", border = "transparent", add = TRUE)
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
