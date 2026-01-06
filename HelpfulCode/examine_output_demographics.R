library(tidyverse)
library(reshape2)

# Get model simulations ---------------------------------------------------

mrun <- as.character(168) #select the model run you want

model_dbh_vals <- getDatabaseTables(paste0("C:/Users/kible/Documents/Research/iLand/Model_Runs/run_", mrun,"/output/iland_output.sqlite"), tableName = "tree") %>% 
  filter(rid > 0, rid < 16, species == "abla") %>% 
  filter(ru %% 10 == 0) #get only the first replicate 

plot_summ <- model_dbh_vals %>% 
  group_by(rid, year) %>% 
  summarise(dbh50 = median(dbh), 
            dbh025 = quantile(dbh, 0.025), 
            dbh975 = quantile(dbh, 0.975),
            height50 = median(height),
            height025 = quantile(height, 0.025),
            height975 = quantile(height, 0.975),
            age50 = median(age),
            age025 = quantile(age, 0.025),
            age975 = quantile(age, 0.975))

ggplot(plot_summ, aes(x = year, y = age50, group = factor(rid))) +
  geom_line(linewidth = 1) +
  geom_linerange(aes(ymin = age025, ymax = age975)) +
  facet_wrap(. ~ rid, ncol = 5) +
  theme_bw() +
  labs(y = "Median Age", title = paste("Model Run", mrun))

ggplot(plot_summ, aes(x = year, y = dbh50, group = factor(rid))) +
  geom_line(linewidth = 1) +
  geom_linerange(aes(ymin = dbh025, ymax = dbh975)) +
  facet_wrap(. ~ rid, ncol = 5) +
  theme_bw() +
  labs(y = "Median DBH", title = paste("Model Run", mrun))

ggplot(plot_summ, aes(x = year, y = height50, group = factor(rid))) +
  geom_line(linewidth = 1) +
  geom_linerange(aes(ymin = height025, ymax = height975)) +
  facet_wrap(. ~ rid, ncol = 5) +
  theme_bw() +
  labs(y = "Height", title = paste("Model Run", mrun))

stand_count_vals <- getDatabaseTables(paste0("C:/Users/kible/Documents/Research/iLand/Model_Runs/run_", mrun, "/output/iland_output.sqlite"), tableName = "stand") %>% 
  filter(rid > 0, rid < 16, species == "abla") %>% #rid < 12
  filter(ru %% 10 == 0) %>% #get only the first replicate 
  mutate(type = "model")

ggplot(stand_count_vals, aes(x = year, y = count_ha, group = factor(rid))) +
  geom_line(linewidth = 1) +
  facet_wrap(. ~ rid, ncol = 5) +
  theme_bw() +
  labs(y = "Stem Count", title = paste("Model Run", mrun))

ggplot(stand_count_vals, aes(x = year, y = cohort_count_ha, group = factor(rid))) +
  geom_line(linewidth = 1) +
  facet_wrap(. ~ rid, ncol = 5) +
  theme_bw() +
  labs(y = "Regeneration Cohort Count", title = paste("Model Run", mrun))

ggplot(stand_count_vals, aes(x = year, y = basal_area_m2, group = factor(rid))) +
  geom_line(linewidth = 1) +
  facet_wrap(. ~ rid, ncol = 5) +
  theme_bw() +
  labs(y = "Basal Area", title = paste("Model Run", mrun))

# Weather in each plot ----------------------------------------------------

weather_vals <- getDatabaseTables(paste0("C:/Users/kible/Documents/Research/iLand/Model_Runs/run_", mrun, "/output/iland_output.sqlite"), 
                                  tableName = "water") %>% 
  filter(rid > 0, rid < 16) %>% #rid < 12
  filter(ru %% 10 == 0) #get only the first replicate

ggplot(weather_vals, aes(x = year, y = mean_swc_gs_mm, group = factor(rid))) +
  geom_line(linewidth = 1) +
  facet_wrap(. ~ rid, ncol = 5) +
  theme_bw() +
  labs(title = paste("Model Run", mrun), y = "Mean Growing Season SWC (mm)")