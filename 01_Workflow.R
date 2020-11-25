# Joy Kumagai and Fabio Favorreto 
# Date: Nov 2020
# Final Workflow with Google Drive Download
# Marine Habitat Protection Indicator


library(googledrive)
library(sf)

#### File downloads ####
# Habitats 
temp <- tempfile(fileext = ".zip")
dl <- drive_download(as_id("1VnAK8ATBbXkFFb-UvwahNpBu1L_-_-cg"), 
                     path = temp, overwrite = TRUE)
out <- unzip(temp, exdir = "data/")
test <- list.files("data/", pattern = "*.shp", full.names = T) 


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

source("Scripts/08_PercentageProtectionBoundary.R")
