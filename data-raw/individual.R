## code to prepare `individual` dataset goes here
# load dplyr to use the pipe
library(dplyr)
source(here::here("R", "geolocate.R"))

# set up paths
raw_data_path <- here::here("data-raw", 
                            "wood-survey-data-master")
individual_path <- fs::path(raw_data_path, "individual")
individual_paths <- fs::dir_ls(individual_path)

# read in and combine all individual csvs
individual <- purrr::map_df(individual_paths,
                            ~readr::read_csv(.x, 
                                             col_types = readr::cols(.default = "c"))) %>%
  readr::type_convert()

# write out individual dataframe to a csv
individual %>%
  readr::write_csv(fs::path(raw_data_path, "vst_individual.csv"))

# ---- MERGE NEON DATA ----
# Read in mapping & perplot data
maptag <- readr::read_csv(fs::path(raw_data_path, 
                                   "vst_mappingandtagging.csv")) %>%
  select(-eventID)
perplot <- readr::read_csv(fs::path(raw_data_path, 
                                    "vst_perplotperyear.csv")) %>%
  select(-eventID)

# join maptag and perplot information onto individual data
individual %<>%
  left_join(maptag, by = "individualID",
            suffix = c("", "_map")) %>%
  left_join(perplot, by = "plotID",
            suffix = c("", "_ppl")) %>%
  assertr::assert(assertr::not_na, stemDistance, 
                  stemAzimuth, pointID, decimalLatitude, 
                  decimalLongitude)

# geolocate individual stems
individual <- individual %>%
  dplyr::mutate(stemLat = get_stem_location(decimalLongitude, 
                                            decimalLatitude,
                                            stemAzimuth, stemDistance)$lat,
                stemLon = get_stem_location(decimalLongitude, 
                                            decimalLatitude,
                                            stemAzimuth, stemDistance)$lon)

# save individual csv analytical file
individual %>%
  janitor::clean_names() %>%
  readr::write_csv(here::here("data", "individual.csv"))


