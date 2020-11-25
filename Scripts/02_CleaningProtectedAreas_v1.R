# Joy Kumagai
# Date: Nov 2020
# Cleaning Protected Areas - version 1
# Marine Habitat Protection Indicator


##### Load Packages #####
library(tidyverse)
library(raster)
library(sf)
library(fasterize)

#### Declare Functions ####
clean <- function (x, crs = paste("+proj=cea +lon_0=0 +lat_ts=30 +x_0=0", 
                                  "+y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs"), snap_tolerance = 1, 
                   simplify_tolerance = 0, geometry_precision = 1500, erase_overlaps = TRUE, 
                   verbose = interactive()) 
{
  assertthat::assert_that(inherits(x, "sf"), nrow(x) > 0, 
                          all(assertthat::has_name(x, c("ISO3", "STATUS", "DESIG_ENG", 
                                                        "REP_AREA", "MARINE"))), assertthat::is.string(crs) || 
                            assertthat::is.count(crs), assertthat::is.number(snap_tolerance), 
                          isTRUE(snap_tolerance >= 0), assertthat::is.number(simplify_tolerance), 
                          isTRUE(simplify_tolerance >= 0), assertthat::is.count(geometry_precision), 
                          assertthat::is.flag(erase_overlaps), assertthat::is.flag(verbose))
  assertthat::assert_that(sf::st_crs(x) == sf::st_crs(4326), 
                          msg = "argument to x is not longitude/latitude (i.e. EPSG:4326)")
  if (verbose) 
    message("removing areas that are not implemented: ", 
            cli::symbol$continue, "\r", appendLF = FALSE)
  x <- x[x$STATUS %in% c("Designated", "Inscribed", "Established"), 
  ]
  if (verbose) {
    utils::flush.console()
    message("removing areas that are not implemented: ", 
            cli::symbol$tick)
  }
  if (verbose) 
    message("removing UNESCO reserves: ", cli::symbol$continue, 
            "\r", appendLF = FALSE)
  x <- x[x$DESIG_ENG != "UNESCO-MAB Biosphere Reserve", ]
  if (verbose) {
    utils::flush.console()
    message("removing UNESCO reserves: ", cli::symbol$tick)
  }
  return(x)
}

##### Load Data #####
ocean <- read_sf("data/data/ocean/ne_110m_ocean.shp")

#### Download Data #### 

# Need to do this automatically in the future 
# wdpa_latest_version() # states which version we are using -- not working anymore 
# Points were not included 
global_pas1 <- read_sf("data/data/mpas/WDPA_WDOECM_marine_shp0/WDPA_WDOECM_marine_shp-polygons.shp")
global_pas2 <- read_sf("data/data/mpas/WDPA_WDOECM_marine_shp1/WDPA_WDOECM_marine_shp-polygons.shp")
global_pas3 <- read_sf("data/data/mpas/WDPA_WDOECM_marine_shp2/WDPA_WDOECM_marine_shp-polygons.shp") 


#### Removing terrestrial areas, not implemented, and UNESCO reserves ####
# Remove not implemented and UNESCO reserves
mpas1 <- clean(global_pas1)
mpas2 <- clean(global_pas2)
mpas3 <- clean(global_pas3)

# Combine Data into one layer 
global_mpas <- rbind(mpas1, mpas2, mpas3)


#### Projecting Data ####
crs(global_mpas)
# Chosen projection: World Eckert Iv (equal area)
eckert <- "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m no_defs"
global_mpas <- st_transform(global_mpas, crs = eckert)
global_mpas$constant <- 1 # for rasterization later

ocean <- st_transform(ocean, crs = eckert)


#### Filter based on MPA Status ####
all_mpas <- global_mpas

# global_mpas %>% filter(NO_TAKE == "Part")
# what do we do with those that are partially no-take?????? # for now we are not going to include it 

no_take <- global_mpas %>% 
  filter(NO_TAKE == "All")

managed <- global_mpas %>% 
  filter(MANG_PLAN != "In process" &
           MANG_PLAN != "In progress" &
           MANG_PLAN !=  "Management plan not implemented and not available" &
           MANG_PLAN != "Management plan in preparation" &
           MANG_PLAN != "Management plan available but not implemented" &
           MANG_PLAN != "TBD" &
           MANG_PLAN != "Under review" &
           MANG_PLAN != "In development" &
           MANG_PLAN != "Draft" &
           MANG_PLAN != "http://" &
           MANG_PLAN != "In Development" &
           MANG_PLAN != "Currently being developed" &
           MANG_PLAN != "Not Available" &
           MANG_PLAN != "Management plan is available but not implemented" &
           MANG_PLAN != "Management Plan is ImplentedNot Available" &
           MANG_PLAN != "Management plan is not implented and not available" &
           MANG_PLAN != "Management plan is not implented but is available" &
           MANG_PLAN != "None" &
           MANG_PLAN != "Management plan is not implemented and not available" &
           MANG_PLAN !=  "In preparation" &
           MANG_PLAN != "Not Existing" &
           MANG_PLAN != "No" &
           MANG_PLAN != "Not Reported")


#### Rasterization ####
r <- raster(ocean, res = 1000)
all_mpasR <- fasterize(all_mpas, r, field = "constant")
no_takeR <- fasterize(no_take, r, field = "constant")
managedR <- fasterize(managed, r, field = "constant")


#### Export ####
writeRaster(no_takeR, "data/data/mpas/No_take_mpas.tif")
writeRaster(managedR, "data/data/mpas/Managed_mpas.tif")
writeRaster(all_mpasR, "data/data/mpas/All_mpas.tif")