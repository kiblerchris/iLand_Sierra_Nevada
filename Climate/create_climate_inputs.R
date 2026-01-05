#This code gets run on CyVerse (not locally).
#Make sure to allocate enough memory in CyVerse.

install.packages("Rcpp")
install.packages("reshape2")
library(reshape2)
library(terra)
library(tidyverse)
library(RSQLite)

setwd("/home/rstudio/data-store/home/kiblerchris")

filepath <- "/home/rstudio/data-store/home/shared/WFFRC/climate_v2/daily/observed/"

plots <- read.csv("/home/rstudio/data-store/home/kiblerchris/KingsCanyon_PlotData.csv") %>% 
  select(Plot, Latitude, Longitude) %>% 
  vect(., geom = c("Longitude", "Latitude"), crs = "EPSG:4326")

#1980-2023
extract_pw_values <- function(filepath, var, plots, min_year = 2005, max_year = 2009){
  
  require(tidyverse)
  require(terra)
  
  #Create list of filepaths from 1980 to 2023
  all_files <- list.files(paste0(filepath, var), full.names = TRUE)
  var_files <- all_files[str_detect(all_files, str_c(as.character(min_year:max_year), collapse="|"))]
  
  print("got file names")
  
  #Create single raster from all data files
  var_rast <- rast(var_files)
  
  print("created raster")
  
  #Extract values at plot locaitons
  var_values <- terra::extract(var_rast, plots, method = "simple", ID = FALSE) %>%
    t() %>% 
    as.data.frame()
  
  print("extracted values")
  
  #Label plots and time
  colnames(var_values) <- plots$Plot
  var_values$time <- as.character(terra::time(var_rast, format = "days"))
  
  #Add year, month, and day columns
  time_cols <- str_split_fixed(var_values$time, pattern = "-", n = 3)
  var_values$year <- time_cols[,1]
  var_values$month <- time_cols[,2]
  var_values$day <- time_cols[,3]
  
  #Add variable label
  var_values$variable <- var
  
  var_values <- var_values %>% 
    relocate(variable, time, year, month, day)
  
  return(var_values)
}

#Need to allocate a lot of memory for this --> 128GB

tmin_values <- extract_pw_values(filepath = filepath, var = "tmin", plots = plots)
write.csv(tmin_values, "/home/rstudio/data-store/home/kiblerchris/tmin_seki.csv")

tmax_values <- extract_pw_values(filepath = filepath, var = "tmax", plots = plots)
write.csv(tmax_values, "/home/rstudio/data-store/home/kiblerchris/tmax_seki.csv")

prec_values <- extract_pw_values(filepath = filepath, var = "prec", plots = plots)
write.csv(prec_values, "/home/rstudio/data-store/home/kiblerchris/prec_seki.csv")

solar_values <- extract_pw_values(filepath = filepath, var = "solar", plots = plots)
write.csv(solar_values, "/home/rstudio/data-store/home/kiblerchris/solar_seki.csv")

vpd_values <- extract_pw_values(filepath = filepath, var = "vpd", plots = plots)
write.csv(vpd_values, "/home/rstudio/data-store/home/kiblerchris/vpd_seki.csv")

# Create climate data sets for each site ----------------------------------

#Load created values so they can be compiled by site
tmin_values <- read.csv("/home/rstudio/data-store/home/kiblerchris/tmin_seki.csv") %>% 
  select(-X)
tmax_values <- read.csv("/home/rstudio/data-store/home/kiblerchris/tmax_seki.csv") %>% 
  select(-X)
prec_values <- read.csv("/home/rstudio/data-store/home/kiblerchris/prec_seki.csv") %>% 
  select(-X)
solar_values <- read.csv("/home/rstudio/data-store/home/kiblerchris/solar_seki.csv") %>% 
  select(-X)
vpd_values <- read.csv("/home/rstudio/data-store/home/kiblerchris/vpd_seki.csv") %>% 
  select(-X)

climate_values <- rbind(
  tmin_values,
  tmax_values,
  prec_values,
  solar_values,
  vpd_values) %>% 
  melt(id.vars = c("variable", "time", "year", "month", "day"), variable.name = "plot")

# Export output as different SQLite files ---------------------------------

for(p in unique(climate_values$plot)){
  
  print(p)
  
  vals <- filter(climate_values, plot == p)
  
  db.conn <<- dbConnect(RSQLite::SQLite(), 
                        dbname=paste0("/home/rstudio/data-store/home/kiblerchris/", p, "_climate.sqlite"))
  dbWriteTable(db.conn, name = p, value = vals, row.names = F, overwrite = T)
  dbDisconnect(db.conn)
}

# Export output as one SQLite file ----------------------------------------

# Define database file path (single SQLite file)
db_path <- "/home/rstudio/data-store/home/kiblerchris/SEKI_climate_data.sqlite"

# Connect to the database (creates if it doesn't exist)
db.conn <- dbConnect(RSQLite::SQLite(), dbname = db_path)

# Loop through unique plots and store each as a separate table
for (p in unique(climate_values$plot)) {
  
  print(p)  # Print current plot
  
  vals <- filter(climate_values, plot == p) %>% 
    dcast(., formula = time + year + month + day ~ variable, value.var = "value") %>% 
    mutate(rad = solar * 0.0864, vpd = vpd/10) %>% 
    dplyr::select(year, month, day, min_temp = tmin, max_temp = tmax, prec, rad, vpd)
  
  #https://www.fao.org/4/x0490e/x0490e0i.htm
  
  # Write data as a separate table named after the plot
  dbWriteTable(db.conn, name = p, value = vals, row.names = FALSE, overwrite = TRUE)
}

# Disconnect from the database after all tables are written
dbDisconnect(db.conn)