# Prepare workspace -------------------------------------------------------

library(terra)
library(tidyverse)

# Load soil data ----------------------------------------------------------

#Source: https://casoilresource.lawr.ucdavis.edu/soil-properties/download.php

sand <- rast("sand.tif")
silt <- rast("silt.tif")
clay <- rast("clay.tif")
#depth <- rast("depth.tif")
depth <- rast("resdept.tif")
soils <- rast(list(sand, silt, clay))

# Load plot data ----------------------------------------------------------

plots <- read.csv("../FieldData/KingsCanyon_PlotData.csv") %>% 
  select(Plot, Longitude, Latitude) %>% 
  drop_na()

elevation <- data.frame(plot = c("ROCRPICO", "EMRIDGE", "EMSLOPE", "EMSALIX", "HOMEPICO", "PGABMA", "POFLABMA", "WTABMA", "SFTRABMA", "BBBPIPO", "YOHOPIPO", "CCRPIPO", "SUABCO", "SUPILA", "SURIP", "LOTHAR", "UPTHAR", "LOGPIJE", "UPLOG"),
                        elevation = c(3369, 3100, 2958, 2837, 2617, 2573, 2540, 2522, 2469, 1617, 1497, 1618, 2033, 2055, 2035, 2136, 2185, 2404, 2212)) %>% 
  arrange(elevation)

plot_vect <- vect(x = as.matrix(plots[,2:3]), crs = "EPSG:4326") %>% 
  project(., crs(soils))

values(plot_vect) <- plots$Plot

# Extract soil values from plot locations ---------------------------------

plot_soils <- terra::extract(x = soils, y = plot_vect) %>% 
  select(ID, sand, silt, clay)
plot_soils$plot <- plots$Plot

plot_depth <- terra::extract(x = depth, y = plot_vect) %>% 
  select(ID, depth = resdept)
plot_depth$plot <- plots$Plot
plot_depth$depth <- round(plot_depth$depth, 0)

plot_subsurface <- inner_join(plot_soils, plot_depth, by = "plot") %>% 
  inner_join(., elevation, by = "plot") %>% 
  select(plot, sand, silt, clay, depth, elevation) %>% 
  arrange(elevation) %>%
  mutate(depth = replace_na(depth, 50)) %>% #change missing depth values to desired replacement
  mutate(environment = paste(1:19, plot, "45", depth, round(sand, 1), round(silt, 1), round(clay, 1), sep = " "))

write.csv(plot_subsurface, "plot_soil_data.csv")
