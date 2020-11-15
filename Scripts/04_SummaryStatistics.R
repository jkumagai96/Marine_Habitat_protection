# Fabio Favoretto
# Date: 15/11/2020
# Summary statistic of rasterized habitat polygons
# Marine Habitat Protection Indicator


# Load Packages -----------------------------------------------------------

library(parallel)
library(snow)
library(tidyverse)
library(raster)
library(sf)


# Loading data ------------------------------------------------------------

# once all rasters are created in the "Temp" folder, we can source all the file names

grids <- list.files("Data/Temp/", pattern = "*.tif$") #list files (in this case raster TIFFs)

# Then we read the polygon we want to use as zone

poly <- read_sf("Path/to/shape.shp") %>% 
  st_transform(., crs = "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m no_defs") 

poly <- as(poly, "Spatial") # we need this format to speed extract function
# poly <- poly[1:10,] Uncomment this if you want to subset the polygon shapefile to less features


## create a raster stack (the stack will be formed by all the files in the Temp folders sourced by list.files)
s <- stack(paste0("Data/Temp/", grids))



# Zonal statistic ---------------------------------------------------------


## Now we will extract in parallel, uncomment below to activate the cluster parallelization
## beginCluster(n=2) Parallel processing!! BE CAREFUL, Select your cores carefully usually one less than the one you have available

ex <- extract(s, poly, fun=sum, na.rm=TRUE, df=TRUE)

# endCluster() # this ends the cluster use of the cpu



# Save output -------------------------------------------------------------

write.csv(df, file = "Data/Temp/habitat_area.csv")





#### END OF SCRIPT #####

