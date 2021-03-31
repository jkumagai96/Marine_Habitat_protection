# Joy Kumagai  
# Date: March 2021
# Converting PAs from points to polygons 
# Marine Habitat Protection Indicator

##### Load Packages #####
library(tidyverse)
library(sf)

##### Data Processing #####

# Create Place to hold Files 
dir.create(path = "Data_original/mpas/PointsToPolygons", showWarnings = FALSE)

# Goal: Create a vector of files that are all PA polygons to be cleaned

mpa_files # Files we will go through
mpa_poly_files <- c() # vector of files that are all PAs to be cleaned in the next script
n <- 0 # For writing the files 

originalcrs <- crs(st_read(mpa_files[1]))

for (i in 1:length(mpa_files)) {
  # read data 
  dat <- st_read(mpa_files[i])
  
  # If polygon data, then immediately put file path in variable
  if (unique(st_geometry_type(dat)) == "POLYGON" | unique(st_geometry_type(dat)) == "MULTIPOLYGON") {
    mpa_poly_files <- c(mpa_poly_files, mpa_files[i])
  } else if (unique(st_geometry_type(dat)) == "POINT" | unique(st_geometry_type(dat)) == "MULTIPOINT") {
    # If point data with area, buffer the point so it is a polygon
    
    dat <- dat %>% 
      filter(REP_AREA > 0) %>% # Filter out Protected Areas with no area 
      st_transform(crs = behrmann) %>% # Project 
      mutate(radius = sqrt(REP_AREA/pi)/.001 ) # calculate radius for buffer
    
    dat_poly <- st_buffer(dat, dist = dat$radius) %>% # Buffer points 
      dplyr::select(-WDPAID) # too large of numbers to save, so removed 
    
    dat_poly <- st_transform(dat_poly, crs = originalcrs)
    
    filepath <- paste0("Data_original/mpas/PointsToPolygons/polypoints_", n, ".shp") 
    st_write(dat_poly, filepath, overwrite = TRUE, append = FALSE, driver = 'ESRI Shapefile',  layer_options = "ENCODING=UTF-8") # write new poly data
    n <- n+1
    
    mpa_poly_files <- c(mpa_poly_files, filepath) # save path to be cleaned in next script 
    rm(filepath)
    
  } else {
    print("ERROR geometry is not polygon, multipolygon, point, or multipoint")
  }
}
