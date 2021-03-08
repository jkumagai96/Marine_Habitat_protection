## Clean MPA polygons function -----

clean <- function(x, crs = paste("+proj=cea +lon_0=0 +lat_ts=30 +x_0=0", 
                                 "+y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs"), snap_tolerance = 1, 
                  simplify_tolerance = 0, geometry_precision = 1500, erase_overlaps = TRUE, 
                  verbose = interactive()) 
{
        x <- st_read(x) 
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
                message("removing UNESCO-MAB Biosphere Reserve: ", cli::symbol$continue, 
                        "\r", appendLF = FALSE)
        x <- x[x$DESIG_ENG != "UNESCO-MAB Biosphere Reserve", ]
        if (verbose) {
                utils::flush.console()
                message("removing UNESCO reserves: ", cli::symbol$tick)
        }
        
        # Added reprojection
        
        behrmann <- '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs'
        x <- st_transform(x, crs = behrmann) %>% 
                mutate(constant = 1)
        return(x)
}


## filter & clean NTZ

clean_NTZ <- function(x, crs = paste("+proj=cea +lon_0=0 +lat_ts=30 +x_0=0", 
                                 "+y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs"), snap_tolerance = 1, 
                  simplify_tolerance = 0, geometry_precision = 1500, erase_overlaps = TRUE, 
                  verbose = interactive()) 
{
        x <- st_read(x) 
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
                message("removing UNESCO-MAB Biosphere Reserve: ", cli::symbol$continue, 
                        "\r", appendLF = FALSE)
        x <- x[x$DESIG_ENG != "UNESCO-MAB Biosphere Reserve", ]
        if (verbose) {
                utils::flush.console()
                message("removing UNESCO reserves: ", cli::symbol$tick)
        }
        
        # Added reprojection
        
        behrmann <- '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs'
        x <- st_transform(x, crs = behrmann) %>% 
                mutate(constant = 1) %>% 
                filter(NO_TAKE == "All")
        
        return(x)
}


## filter & clean and filter managed
clean_managed <- function(x, crs = paste("+proj=cea +lon_0=0 +lat_ts=30 +x_0=0", 
                                     "+y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs"), snap_tolerance = 1, 
                      simplify_tolerance = 0, geometry_precision = 1500, erase_overlaps = TRUE, 
                      verbose = interactive()) 
{
        x <- st_read(x) 
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
                message("removing UNESCO-MAB Biosphere Reserve: ", cli::symbol$continue, 
                        "\r", appendLF = FALSE)
        x <- x[x$DESIG_ENG != "UNESCO-MAB Biosphere Reserve", ]
        if (verbose) {
                utils::flush.console()
                message("removing UNESCO reserves: ", cli::symbol$tick)
        }
        
        # Added reprojection
        
        behrmann <- '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs'
        x <- st_transform(x, crs = behrmann) %>% 
                mutate(constant = 1) %>% 
                filter(!MANG_PLAN %in% c(
                        "In process",
                        "In progress",
                        "Management plan not implemented and not available",
                        "Management plan in preparation",
                        "Management plan available but not implemented",
                        "TBD",
                        "Under review",
                        "In development",
                        "Draft",
                        "http://",
                        "In Development",
                        "Currently being developed",
                        "Management plan is available but not implemented",
                        "Management Plan is ImplentedNot Available",
                        "Management plan is not implented and not available",
                        "Management plan is not implented but is available",
                        "None",
                        "Management plan is not implemented and not available",
                        "In preparation",
                        "Not Existing",
                        "No",
                        "Not Reported"
                )) 
        return(x)
}


