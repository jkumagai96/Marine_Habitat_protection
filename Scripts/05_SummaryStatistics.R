# Fabio Favoretto and Joy Kumagai
# Date: Jan 2022
# Summary statistic of rasterized habitat polygons
# Habitat Protection Index Project

# Load Packages -----------------------------------------------------------
library(tidyverse)
library(raster)
library(sf)


# Loading data ------------------------------------------------------------

grids <- list.files("Data_processed/", pattern = "*habitat.tif$") #list files (in this case raster TIFFs)

poly <- read_sf("Data_original/eez_land/EEZ_Land_v3_202030.shp") %>%
  st_transform(., crs = behrmann.crs) 

poly <- as(poly, "Spatial") # we need this format to speed extract function

poly$ID <- 1:length(poly$UNION)

# poly <- poly[1:10,] #Uncomment this if you want to subset the polygon shapefile to less features

start.time <- Sys.time()
## create a raster stack (the stack will be formed by all the files in the Temp folders sourced by list.files)
dir.create(path = "Temp", showWarnings = FALSE)
tempwd <- "Temp/"
s <- raster::writeRaster(x = stack(paste0("Data_processed/", grids)), 
                         paste0(tempwd, "stacked"), 
                         overwrite = TRUE)

# create vector of column names 
habitats <- c("ColdCorals", "CoralReefs", "KnollsSeamounts", "Mangroves", "Saltmarsh", "Seagrass")
habitat_columns <- c(paste0(habitats, "_allmpashabitat"), paste0(habitats, "_habitat")) %>% sort()

# Zonal statistic ---------------------------------------------------------

ex <- exactextractr::exact_extract(s, poly, fun = "sum")
colnames(ex) # Check to make sure that the replacement of the column names is correct
colnames(ex) <- habitat_columns

# Save output -------------------------------------------------------------

write.csv(ex, file = "Data_processed/habitat_area.csv")

end.time <- Sys.time()
end.time - start.time


#### END OF SCRIPT #####

