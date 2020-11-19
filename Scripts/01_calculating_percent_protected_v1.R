# Joy Kumagai
# Date: Oct 2020
# Calculate habitat within proposed protected areas - general (versoin 1)
# Marine Protection Indicator

##### Load Packages #####
library(tidyverse)
library(raster)
library(sf)
library(wdpar)

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
}

##### Load Data #####
eez_land <- read_sf("Data/eez_land/EEZ_Land_v3_202030.shp")
habitat_poly <- read_sf("Data/segrasses/version7/014_001_WCMC013-014_SeagrassPtPy2020_v7/01_Data/WCMC013014-Seagrasses-Py-v7.shp")

# Global Protected Areas Download and cleaning


# wdpa_latest_version() # states which version we are using -- not working anymore 
# Points were not included 
global_pas1 <- read_sf("Data/mpas/WDPA_WDOECM_marine_shp0/WDPA_WDOECM_marine_shp-polygons.shp")
global_pas2 <- read_sf("Data/mpas/WDPA_WDOECM_marine_shp1/WDPA_WDOECM_marine_shp-polygons.shp")
global_pas3 <- read_sf("Data/mpas/WDPA_WDOECM_marine_shp2/WDPA_WDOECM_marine_shp-polygons.shp") 

global_pas1_clean <- wdpa_clean(global_pas1, erase_overlaps = F)
crs(global_pas1)
test <- clean(global_pas1)

# remove terrestrial areas 
mpas_global <- global_pas_clean %>% 
  filter(MARINE == "partial" | MARINE == "marine")

### Rasterize mpas layer 

# create base raster layer 
r_extent <- read_sf("Data_Original/ocean/ne_110m_ocean.shp")
r_extent <- st_transform(r_extent, crs(mpas_global))
r <- raster(r_extent, res = 10000)

# rasterize mpas layer 
mpas_global$one <- 1
mpas_global_r <- rasterize(mpas_global, r, progress = "text", field = "one") 

##### Clean Data #####
eez <- st_transform(eez, crs(proposed_mpas))
habitat_poly <- st_transform(habitat_poly, crs(proposed_mpas))

##### Analysis ####
# Calculate the current percent protection (Raster)

#r <- raster(eez, res = 100000)  # 100,000 meters
habitat_poly$one <- 1
habitat_r <- rasterize(habitat_poly, r, progress = "text", field = "one") 

habitat_n <- cellStats(habitat_r, stat = "sum") 
p_habitat <- habitat_r*mpas_global_r
p_habitat_n <- cellStats(p_habitat, stat = "sum")
pp <- (p_habitat_n/habitat_n)*100 
