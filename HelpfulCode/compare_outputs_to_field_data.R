library(tidyverse)
library(reshape2)

#This code extracts the outputs from multiple runs simultaneously and then plots the outputs against the field measurements.
#There are parallel workflows for DBH (tree output) and basal area (stand output).
#This assumes that the model run folders are stored in the same directory with the "run_XXX" naming convention.

# Create Function ---------------------------------------------------------

getDatabaseTables <- function(dbname="YOURSQLITEFILE", tableName=NULL){
  library("RSQLite")
  library("purrr")
  con <- dbConnect(drv=RSQLite::SQLite(), dbname=dbname) # connect to db
  on.exit(dbDisconnect(con))
  tables <- dbListTables(con) # list all table names
  
  if (is.null(tableName)){
    # get all tables
    lDataFrames <- map(tables, ~{ dbGetQuery(conn=con, statement=paste("SELECT * FROM '", .x, "'", sep="")) })
    # name tables
    names(lDataFrames) <- tables
    return (lDataFrames)
  }
  else{
    # get specific table
    return(dbGetQuery(conn=con, statement=paste("SELECT * FROM '", tableName, "'", sep="")))
  }
}

# Load Field Measurements and Reorganize Data -----------------------------

plot_data <- read.csv("C:/Users/kible/Documents/Research/iLand/SEKI_data/resekidemographicdata/allplotarchiveout03252022.csv")

elevation <- data.frame(plot = c("ROCRPICO", "EMRIDGE", "EMSLOPE", "EMSALIX", "HOMEPICO", "PGABMA", "POFLABMA", "WTABMA", "SFTRABMA", "BBBPIPO", "YOHOPIPO", "CCRPIPO", "SUABCO", "SUPILA", "SURIP", "LOTHAR", "UPTHAR", "LOGPIJE", "UPLOG"),
                        elevation = c(3369, 3100, 2958, 2837, 2617, 2573, 2540, 2522, 2469, 1617, 1497, 1618, 2033, 2055, 2035, 2136, 2185, 2404, 2212)) %>% 
  arrange(elevation) %>% 
  mutate(rid =  1:19)

most_recent_measurement <- plot_data %>% 
  select(PLOT, YEAR0 = YearFirstRecorded, YEAR1, YEAR2, YEAR3, YEAR4, YEAR5, YEAR6, YEAR7, YEAR8) %>% 
  melt(id.vars = "PLOT") %>% 
  mutate(id = as.numeric(str_sub(variable, -1, -1))) %>% 
  drop_na() %>% 
  group_by(PLOT) %>% 
  summarise(max_id = max(id)) %>% 
  mutate(column = paste0("DBH", max_id))

plot_species_list <- list()

for (s in unique(most_recent_measurement$PLOT)){
  
  column = most_recent_measurement[most_recent_measurement$PLOT == s,]$column
  
  p <- plot_data %>% 
    filter(PLOT == s) %>% 
    select(PLOT, TAGNUMBER, SppCode, one_of(column)) %>% 
    mutate(source = column) %>% 
    drop_na()
  
  names(p) <- c("Plot", "Tag", "Species", "DBH", "Source")
  
  plot_species_list[[s]] <- p
  
}

#Summarize plot DBH measurements
plot_dbh <- do.call(rbind, plot_species_list) %>% 
  mutate(plot = Plot, species = tolower(Species), dbh = DBH) %>% 
  select(-Plot, -Species, -DBH) %>% 
  #filter(species %in% species_combo[[target]]) %>% 
  #group_by(plot, species) %>% 
  filter(dbh > 0) %>%
  group_by(plot, species) %>% 
  summarise(p0_dbh = min(dbh),
            p5_dbh = quantile(dbh, 0.05),
            p25_dbh = quantile(dbh, 0.25),
            p50_dbh = quantile(dbh, 0.5),
            mean_dbh = mean(dbh),
            p75_dbh = quantile(dbh, 0.75),
            p95_dbh = quantile(dbh, 0.95),
            p100_dbh = max(dbh)) %>% 
  ungroup() %>% 
  mutate(run = "field") %>% 
  left_join(., elevation, by = "plot") %>% 
  select(-elevation, -plot) %>% 
  drop_na() %>% 
  #mutate(species = target) %>% 
  mutate(category = case_when(
    species %in% c("abla", "abma", "abco") ~ "fir",
    species %in% c("pico", "pimo") ~ "high_elevation_pine",
    species == "pipo" ~ "low_elevation_pine",
    TRUE ~ species
  ))

#Summarize plot basal area measurements
plot_ba <- do.call(rbind, plot_species_list) %>% 
  mutate(plot = Plot, species = tolower(Species), dbh = DBH) %>% 
  select(-Plot, -Species, -DBH) %>% 
  filter(dbh > 0) %>% 
  #mutate(basal_area_m2 = 0.00007854 * (dbh**2)) %>% 
  mutate(basal_area_m2 = pi * (dbh**2)/40000) %>% 
  group_by(plot, species) %>% 
  summarise(mean_ba = sum(basal_area_m2)) %>% 
  ungroup() %>% 
  left_join(., elevation, by = "plot") %>% 
  drop_na() %>% 
  mutate(run = "field", min_ba = NA, max_ba = NA) %>% 
  select(-elevation, -plot) %>% 
  mutate(category = case_when(
    species %in% c("abla", "abma", "abco") ~ "fir",
    species %in% c("pico", "pimo") ~ "high_elevation_pine",
    species == "pipo" ~ "low_elevation_pine",
    TRUE ~ species
  ))

# DBH Range ---------------------------------------------------------------

runs <- c(201, 212) #Load multiple runs at once for comparison

setwd("C:/Users/kible/Documents/Research/iLand/Model_Runs")

dbh_vals <- list()
stand_vals <- list()

for (d in runs){
  
  print(d)
  
  wd <- getwd()
  
  setwd(file.path(wd, paste0("run_",d), "output")) #Find the specific model run folder in the current directory
  
  #Summarize individual tree outputs (DBH)
  db_tree <- getDatabaseTables("iland_output.sqlite", tableName = "tree") %>% 
    filter(year == 1000) %>% #Only the final year of the model run
    select(ru, rid, species, dbh) %>%
    filter(rid > 0) %>% 
    group_by(rid, species) %>% #Group across replicates and species
    summarise(p0_dbh = min(dbh),
              p5_dbh = quantile(dbh, 0.05),
              p25_dbh = quantile(dbh, 0.25),
              p50_dbh = quantile(dbh, 0.5),
              mean_dbh = mean(dbh),
              p75_dbh = quantile(dbh, 0.75),
              p95_dbh = quantile(dbh, 0.95),
              p100_dbh = max(dbh)) %>% 
    mutate(run = d) %>% 
    as.data.frame()
  
  dbh_vals[[d]] <- db_tree
  
  #Summarize stand outputs (basal area)
  db_stand <- getDatabaseTables("iland_output.sqlite", tableName = "stand") %>% 
    filter(year == 1000) %>% 
    select(species, ru, rid, basal_area_m2) %>% 
    group_by(rid, species) %>% 
    summarise(mean_ba = median(basal_area_m2), 
              min_ba = min(basal_area_m2), 
              max_ba = max(basal_area_m2)) %>% 
    mutate(run = d) %>% 
    as.data.frame()
  
  stand_vals[[d]] <- db_stand
  
  setwd(wd)
  
}

#Merge all of the model run outputs for direct comparison
dbh_vals_df <- do.call(rbind, dbh_vals) %>% 
  mutate(category = case_when(
    species %in% c("abla", "abma", "abco") ~ "fir",
    species %in% c("pico", "pimo") ~ "high_elevation_pine",
    species == "pipo" ~ "low_elevation_pine",
    TRUE ~ species
  )) %>% 
  mutate(run = as.character(run)) %>% 
  relocate(run) %>% 
  arrange(run) %>% 
  rbind(., plot_dbh) %>% 
  drop_na() %>% 
  as.data.frame()

#Compute error bars
dbh_vals_df <- dbh_vals_df %>% 
  filter(category %in% unique(filter(dbh_vals_df, run != "field")$category)) %>% 
  select(run, rid, category, p25_dbh, p50_dbh, p75_dbh) %>% 
  complete(run, rid, category, fill = list(p25_dbh = 0, p50_dbh = 0, p75_dbh = 0)) %>% 
  group_by(run, rid, category) %>% 
  summarise(p25_dbh = min(p25_dbh), p50_dbh = mean(p50_dbh), p75_dbh = max(p75_dbh))

#Merge all of the model run outputs for direct comparison
stand_vals_df <- do.call(rbind, stand_vals) %>% 
  mutate(category = case_when(
    species %in% c("abla", "abma", "abco") ~ "fir",
    species %in% c("pico", "pimo") ~ "high_elevation_pine",
    species == "pipo" ~ "low_elevation_pine",
    TRUE ~ species
  )) %>% 
  mutate(run = as.character(run)) %>% 
  relocate(run) %>% 
  arrange(run) %>% 
  rbind(., plot_ba) %>% 
  as.data.frame()

stand_vals_df <- stand_vals_df %>% 
  filter(category %in% unique(filter(stand_vals_df, run != "field")$category)) %>% 
  complete(run, rid, category, fill = list(mean_ba = 0, min_ba = 0, max_ba = 0)) %>% 
  group_by(run, rid, category) %>% 
  summarise(mean_ba = sum(mean_ba), min_ba = min(min_ba), max_ba = max(max_ba))

tab10 <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b")

#Plot basal area
ggplot(stand_vals_df, aes(x = rid, y = mean_ba, fill = factor(run))) +
  geom_col(position = "dodge") +
  geom_linerange(aes(ymin = min_ba, ymax = max_ba), #error bars represent replicates for each field plot
                 linewidth = 0.5, 
                 position = position_dodge2(width = 0.9)) +
  facet_grid(category ~ .) +
  theme_bw() +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0), limits = c(0, max(stand_vals_df$mean_ba, na.rm = T) + 0.1 * max(stand_vals_df$mean_ba, na.rm = T))) +
  labs(x = "Plot ID (elevation -->)", y = "Median Basal Area (m2)") +
  scale_fill_manual(values = tab10[1:length(unique(stand_vals_df$run))], name = "Run ID")

#Plot DBH
ggplot(dbh_vals_df, aes(x = rid, y = p50_dbh, fill = factor(run))) +
  geom_col(position = 'dodge') +
  geom_linerange(aes(ymin = p25_dbh, ymax = p75_dbh), #error bars represent replicates for each field plot
                 linewidth = 0.5, 
                 position = position_dodge2(width = 0.9)) +
  facet_grid(category ~ .) +
  theme_bw() +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0), limits = c(0, max(dbh_vals_df$p75_dbh, na.rm = T) + 0.05 * max(dbh_vals_df$p75_dbh, na.rm = T))) + 
  labs(x = "Plot ID (elevation -->)", y = "Median DBH (cm)") +
  scale_fill_manual(values = tab10[1:length(unique(dbh_vals_df$run))], name = "Run ID")
