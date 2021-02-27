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

grids <- list.files("Data_processed/", pattern = "*habitat.tif$") #list files (in this case raster TIFFs)

# Then we call the polygon we want to use as zone
poly

poly <- as(poly, "Spatial") # we need this format to speed extract function
poly$ID <- 1:length(poly$UNION)
# poly <- poly[1:10,] Uncomment this if you want to subset the polygon shapefile to less features


## create a raster stack (the stack will be formed by all the files in the Temp folders sourced by list.files)
s <- stack(paste0("Data_processed/", grids))


# Zonal statistic ---------------------------------------------------------

## Now we will extract in parallel, uncomment below to activate the cluster parallelization
beginCluster(n=5) # Parallel processing!! BE CAREFUL, Select your cores carefully usually one less than the one you have available

ex <- raster::extract(s, poly, fun=sum, na.rm=TRUE, df=TRUE)

endCluster() # this ends the cluster use of the cpu



# Save output -------------------------------------------------------------

write.csv(ex, file = "Data_processed/habitat_area.csv")





#### END OF SCRIPT #####


#### END OF SCRIPT #####
