# Joy Kumagai and Fabio Favorreto 
# Date: Nov 2020
# Final Workflow specifying inputs 
# Marine Habitat Protection Indicator

library(sf)
library(raster)

#### Inputs to Workflow ####

# All processed data is added into a folder called Data_processed within the scripts
# Final CSV is added into a folder called Data_final within the scripts

### Habitats 
# For the habitats to process correctly in the second script (RaterizingPolygonHabitats) the habitat data needs to be in this file format: 
# "Data_Original/habitats/"
# Please add all habitats into that folder that you would like to use 

### Regions of interest (Union of EEZ and Land polygons from marineregions.org version 3)

behrmann.crs <- CRS('+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs')
poly <- read_sf("data/data/EEZ_Land/EEZ_Land_v3_202030.shp") %>% 
  st_transform(., crs = behrmann.crs) 

### ocean is the file we create the reference grid from (Ocean 110m from marineregions.org)
ocean <- read_sf("Data_original/ocean/ne_110m_ocean.shp") #  version 4.1.0

### MPAS February 2021 Protected Planet Public Download
global_pas1 <- read_sf("Data_original/mpas/WDPA_Feb2021_Public_shp_0/WDPA_Feb2021_Public_shp-polygons.shp") # Points were not included 
global_pas2 <- read_sf("Data_original/mpas/WDPA_Feb2021_Public_shp_1/WDPA_Feb2021_Public_shp-polygons.shp") # Points were not included 
global_pas3 <- read_sf("Data_original/mpas/WDPA_Feb2021_Public_shp_2/WDPA_Feb2021_Public_shp-polygons.shp") # Points were not included 


#### Workflow ####
# Step 1: Cleaning the protected areas and seperating into three levels, all, managed, and no-take
source("Scripts/02_CleaningProtectedAreas_v1.R")

# Step 2: Rasterizing Polygon Habitats 
source("Scripts/03_RasterizingPolygonHabitats.R")

# Step 3: Raster intersections with protected areas
source("Scripts/05_CombiningHabitatsandMPAs.R")

# Step 4: Summarizing habitat information per boundary 
# Be careful! This involves parallel processing
source("Scripts/06_SummaryStatistics.R")

# Step 5: Summarizing Final Outputs 
source("Scripts/07_PercentageProtectionWorld.R")

source("Scripts/08_PercentageProtectionBoundary.R") # Please adjust this step with the habitats you are using 
