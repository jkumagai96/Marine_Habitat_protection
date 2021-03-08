# Joy Kumagai and Fabio Favorreto 
# Date: Feb 2021
# Final Workflow specifying inputs 
# Marine Habitat Protection Indicator

###### All packages used ##### 
library(tidyverse) # to easily load and use the "tidyverse"
library(sf) # For handling spatial vector data
library(raster) # For handling spatial raster data
library(fasterize) # For a faster function to rasterize the habitat data
library(tools) 
library(stringr) # to easily sort some datasets 
library(janitor) # to clean some datasetes

# packages for parallel processing
library(parallel)
library(snow)

#### Inputs to Workflow ####

# All processed data is added into a folder called Data_processed within the scripts
# Final CSV is added into a folder called Data_final within the scripts

### Habitats 
# For the habitats to process correctly in the second script (RaterizingPolygonHabitats) the habitat data needs to be in this file format: 
# "Data_Original/habitats/"
# Please add all habitats into that folder that you would like to use 

### Regions of interest (Union of EEZ and Land polygons from marineregions.org version 3)

behrmann.crs <- CRS('+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs')
poly <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp") %>%
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
source("Scripts/04_CombiningHabitatsandMPAs.R")

# Step 4: Summarizing habitat information per boundary 
# Be careful! This involves parallel processing
source("Scripts/05_SummaryStatistics.R")

# Step 5: Summarizing Final Outputs 
source("Scripts/06_PercentageProtectionWorld.R")

source("Scripts/07_PercentageProtectionBoundary.R") # Please adjust this step with the habitats you are using 
