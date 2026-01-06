library(tidyverse)

#This code replicates some of the hard-coded sensitivity curves in the iLand model.

# Soil Water Potential ----------------------------------------------------

vals <- data.frame(xval = seq(-5, 0, 0.1), lower = -3.38, upper = -0.3, abla = -1.91) %>% 
  melt(id.vars = "xval") %>% 
  mutate(f = (xval - value)/(-0.015 - value)) %>% 
  mutate(fm = pmax(pmin(f, 1), 0))

ggplot(vals, aes(x = xval, y = fm, color = variable)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "SWP", y = "f Multiplier")

# Temperature Response ----------------------------------------------------

vals <- data.frame(xval = seq(-20, 50)) %>% 
  mutate(tad = pmax(xval, -4)) %>% 
  mutate(f = pmin(tad/19, 1))

ggplot(vals, aes(x = xval, y = f)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "Temperature", y = "f Multiplier")

# Phenology Response ------------------------------------------------------

vals <- data.frame(xval = seq(-10, 10)) %>% 
  mutate(inside = (xval - -2)/(5 - -2)) %>% 
  mutate(one = pmin(inside, 1)) %>% 
  mutate(f = pmax(one, 0))

ggplot(vals, aes(x = xval, y = f)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "Temperature", y = "f Multiplier")

# Belowground Allocation --------------------------------------------------

vals <- data.frame(xval = seq(0, 1, 0.1)) %>% 
  mutate(f = 0.8/(1 + 2.5 * xval))

ggplot(vals, aes(x = xval, y = f)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "fN * uAPAR/APAR", y = "Root Allocation")

# Wood Allometry ----------------------------------------------------------

vals <- data.frame(xval = seq(0, 50, 0.1)) %>% 
  mutate(f = 0.04687 * xval**2.527)

ggplot(vals, aes(x = xval, y = f)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "DBH", y = "Wood Biomass")

# Foliage Allometry -------------------------------------------------------

vals <- data.frame(xval = seq(0, 50, 0.1)) %>% 
  mutate(f_abla = 0.3894 * xval**1.231) %>% 
  mutate(f_lower = 0.3894 * xval**1.231) %>% 
  mutate(f_upper = 0.3894 * xval**1.231)

ggplot(vals, aes(x = xval, y = f)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "DBH", y = "Foliage Biomass")

# Root Allometry ----------------------------------------------------------

vals <- data.frame(xval = seq(0, 50, 0.1)) %>% 
  mutate(f = 0.02327 * xval**2.313)

ggplot(vals, aes(x = xval, y = f)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "DBH", y = "Root Biomass")

# Branch Allometry --------------------------------------------------------

vals <- data.frame(xval = seq(0, 50, 0.1)) %>% 
  mutate(f = 0.1926 * xval**1.571)

ggplot(vals, aes(x = xval, y = f)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "DBH", y = "Branch Biomass")

# Aging -------------------------------------------------------------------

vals <- data.frame(xval = seq(0, 1, 0.01)) %>% 
  mutate(f = 1/(1 + (xval/0.75)**2.5))

ggplot(vals, aes(x = xval, y = f)) +
  geom_line(linewidth = 1.5) +
  theme_bw() +
  labs(x = "Age Index", y = "Aging Function")

