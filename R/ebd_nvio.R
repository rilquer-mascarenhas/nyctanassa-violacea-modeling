# Code to check and install packages as needed:
require(tidyverse)
require(rnaturalearth)
require(terra)
require(auk)

## eBird data

# Read data for all three states using auk
# Merge data
# Filter to complete lists only
# Only after 2000
# Account for variation in effort - filtering to specific values
# Zero filling

# Exploration of final filtered data:
## Breeding information
## Individual age
## Temporal distribution of points over years (2000-2026)
## Temporal distribution of points throughout the year (to visualize yearly migration and breeding seasons)
## Mapping sampling effort based on number of observers, checklist, effort in km/h, etc.

## Environmental data

# Let's do an initial test with MODIS and some EarthEnv precipitation data
# Remember to subset points to years that match the range of the environmental data

# 3km buffer around points to retrieve environmental info
### MODIS
# Two metrics: percent landcover, a measure of composition, and edge density, a measure of configuration.

### Topographic variables
## https://www.nature.com/articles/sdata201840

## Modeling

# In the tutorial, the modeling is focus on species distribution models using random forest.
# We have to think if that is what we want for this project.
# As a simple first step, maybe we just want to do here a spatialtemporal subsampling of the data and evaluate
# some response variable (absolute count, encounter rate, relative abundance) across the area
# (maybe in comparison to a background area) and across time.
# Maybe we just want to observe that it has changed over time.
# Then we can plot environmental variables over that same time, to observe any correlations of
# environment and the response variables that is proxy of presence.
# And then we can just make a simple model with environmental predictors and the abundance/encounter rate over space
# For that, we need to have absence, or lower levels of encounter rates, abundances, to model.
# DEFINING HOW TO CALCULATE THIS METRIC OF PRESENCE IS THE THING HERE. WHAT METRIC SHOULD WE USE?
# ABSOLUTE COUNT? ENCOUNTER RATE? RELATIVE ABUNDANCE? The tutorial will have hints on how to calculate the latter two.
# Maybe we can simply use a GLM to model these values as functions of some environmental variation.
# This will allow to gain background on basic stats.

# As a later step, we can think about distribution models. Here, maybe we can think of modeling the species niche,
# and use that niche to predict for each time slice. Maybe we want to model the niche just with historical occurrences,
# or older occurrences, prior to warming. Or maybe we restrict to only areas where we know individuals are breeding
# and are established for a long time.

# Old code
# Nyctanassa violacea
ebd_nvio <- read_tsv('/home/rilquer/ebird_analyses/data/ycnher/ebd_ycnher_smp_relAug-2026.txt')

# Filtering geographically
ebd_nvio %>% filter(STATE %in% c('California','Baja California','Baja California Sur')) %>%
  write_csv('../../ebird_analyses/ebd_nvio_california.csv')




glimpse(ebd_nvio)
# How many of each locality type we have? Maybe we can filter to use just hotspots, to standardize?
# How many of each observation type? Could we maybe filter just to use Stationary? How does the map
# look for each observation type?
# How do we want to filter the data geographically? By state boundaries? Or a bounding box determined by
# coordinates? Or maybe habitat?
# What is the distribution of years in this dataset?
# What are the years of record for populations in California and Baja California?
# Some things to do: 1) plot only recent year 2000-2026; 2) Plot only for California and Baja California

ebd_nvio <- ebd_nvio %>%
  mutate(year = as.numeric(str_split_i(`OBSERVATION DATE`,'-',1)),
         month = as.numeric(str_split_i(`OBSERVATION DATE`,'-',2)),
         day = as.numeric(str_split_i(`OBSERVATION DATE`,'-',3)))

world <- rnaturalearthdata::countries50
ebd_nvio_filt <- ebd_nvio %>% filter(!is.na(LATITUDE)) %>% slice_sample(prop = 0.10)
ggplot(data = world) +
  geom_sf(fill= "grey", size = 0.1)+
  geom_point(data = ebd_nvio_filt,
             aes(x = LONGITUDE,y = LATITUDE,fill=year),
             size = 0.5,alpha=0.2,color='black',pch=21)+
  #fill='brown4')+
  scale_fill_gradient(
    low = "#edf8b1",      # Color for low values
    #mid = "#7fcdbb",     # Color for the middle value
    high = "#2c7fb8"      # Color for high values
    #midpoint = 6       # Value where the 'mid' color is centered
  )+
  coord_sf(xlim = c((min(ebd_nvio_filt$LONGITUDE)-1),
                    (max(ebd_nvio_filt$LONGITUDE)+1)),
           ylim = c((min(ebd_nvio_filt$LATITUDE)-1),
                    (max(ebd_nvio_filt$LATITUDE)+1)))+
  theme(panel.grid.major = element_line(color = gray(.9),linetype = "dashed", linewidth = 0),
        panel.background = element_rect(fill = "ghostwhite"))
