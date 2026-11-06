setwd('github/nyctanassa-violacea-modeling/')
# Packages
pkgs <- c('tidyverse', # Data wrangling
          
          # Spatial
          'rnaturalerthdata','terra','sf',
          
          # eBird data
          'auk')

for (pkg in pkgs){
  if (!(requireNamespace(pkg,quietly = TRUE))){
    install.packages(pkg)
  }
}

require(tidyverse)
require(sf)
require(terra)
require(auk)
set.seed(1234)

# Importing####
# Listing files for observation and checklist separately
obs_files <- list.files('data/ebd_nyc_vio/',pattern = '2026.txt$',full.names = T)
smp_files <- list.files('data/ebd_nyc_vio/',pattern = '2026_sampling.txt$',full.names = T)

# Reading using `lapply` to go through all files
obs <- lapply(obs_files,auk::read_ebd)
smp <- lapply(smp_files,auk::read_sampling)

# Effort filtering####
obs_effort_filt <- lapply(obs,function(x){
  filt <- x %>%
    filter(all_species_reported, # Keeping only values that equal TRUE
           between(year(observation_date), 2000, 2025),
           observation_type %in% c("Stationary", "Traveling"),
           duration_minutes <= 360,
           effort_distance_km <= 10,
           number_observers <= 10)
}) %>% bind_rows() %>%
  mutate(last_edited_date = ymd_hms(last_edited_date),
         time_observations_started = hms::as_hms(time_observations_started),
         project_identifiers = as.numeric(project_identifiers))

smp_effort_filt <- lapply(smp,function(x){
  filt <- x %>%
    filter(all_species_reported, # Keeping only values that equal TRUE
           between(year(observation_date), 2000, 2025),
           observation_type %in% c("Stationary", "Traveling"),
           duration_minutes <= 360,
           effort_distance_km <= 10,
           number_observers <= 10)
}) %>% bind_rows() %>%
  mutate(last_edited_date = ymd_hms(last_edited_date),
         time_observations_started = hms::as_hms(time_observations_started),
         project_identifiers = as.numeric(project_identifiers)) %>% 
  # Adding the california checklist dataset that was previously filtered
  # following the same criteria
  bind_rows(read_delim('data/ebd_nyc_vio/ebd_CA_samp_filt.txt'))

# Mapping####
states <- rnaturalearthdata::states50 %>% filter(name=='California') %>% 
  # Immediately add Mexican states from file
  bind_rows(read_sf('data/spatial/mexican-states/mexican-states.shp') %>%
              # We first filter Mexican states to only Baja California and BC Sur
              filter(grepl('Baja',name)))

ggplot()+geom_sf(data=states)+
  geom_point(data=smp_effort_filt %>% slice_sample(prop = 0.1),
             aes(x=longitude,y=latitude),
             alpha=0.4,pch=21,size=0.5,color='grey',fill='brown')+
  geom_point(data=obs_effort_filt,
             aes(x=longitude,y=latitude),
             alpha=0.4,pch=21,size=2,fill='lightblue')+
  theme(panel.grid.major = element_line(color = gray(.9),linetype = "dashed", linewidth = 0),
        panel.background = element_rect(fill = "ghostwhite"),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = 'none')

# Background sub-sampling####
# Background
bkg <- st_as_sf(obs_effort_filt %>% slice_sample(prop=0.1), # Retrieving 10% of original points
                coords = c("longitude", "latitude"),
                crs = "EPSG:4326") %>%
  st_buffer(dist=200000) %>%  # Setting to a distance of 200k meters (i.e., 200 km)
  st_union()

# Masking background by state boundaries so we can get rid of open sea occurrences
bkg <- intersect(vect(bkg),vect(states)) %>% st_as_sf()

# Plotting background with points
ggplot()+geom_sf(data=states)+
  geom_sf(data=bkg,fill='lightpink',alpha=0.4)+
  geom_point(data=obs_effort_filt,
             aes(x=longitude,y=latitude),
             alpha=0.4,pch=21,size=2,fill='lightblue')+
  theme(panel.grid.major = element_line(color = gray(.9),linetype = "dashed", linewidth = 0),
        panel.background = element_rect(fill = "ghostwhite"),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = 'none')

# Empty raster and masking
r <- rast(
  xmin = st_bbox(bkg)[1]-1, xmax = st_bbox(bkg)[3]+1,  # Longitude boundaries
  ymin = st_bbox(bkg)[2]-1,   ymax = st_bbox(bkg)[4]+1,    # Latitude boundaries
  res = 0.1,                # Resolution (0.1 = 11.1 km)
  crs = "EPSG:4326"          # Coordinate Reference System (WGS84)
)
values(r) <- 1

#Masking raster by states:
r <- terra::mask(r,vect(bkg))

# Retrieving values and removing checklists outside of background polygon
smp_bkgfilt <- smp_effort_filt %>%
  mutate(within_bkg = extract(r,smp_effort_filt %>% select(longitude,latitude) %>%
                                as.matrix()) %>% unlist() %>% as.numeric(),
         cell = cellFromXY(r,smp_effort_filt %>% select(longitude,latitude) %>%
                             as.matrix())) %>% 
  filter(!(is.na(within_bkg)))

# Checking numbers
smp_bkgfilt %>% 
  summarize(total=n(),.by='state') %>%
  left_join(smp_bkgfilt %>%
              summarize(n=n(),.by=c('state','cell')) %>%
              summarize(median_per_cell=median(n),.by='state'),
            by='state')

# Plotting to visualize the difference
viz_data <- smp_effort_filt %>% slice_sample(prop=0.1) %>%
  select(longitude,latitude) %>% mutate(source='Before bkg filt') %>%
  bind_rows(smp_bkgfilt %>% slice_sample(prop=0.1) %>% select(longitude,latitude) %>%
              mutate(source='After bkg filt')) %>%
  mutate(source = factor(source,levels = c('Before bkg filt','After bkg filt')))
ggplot()+geom_sf(data=states)+
  geom_sf(data=bkg,fill='lightpink',alpha=0.4)+
  geom_point(data=viz_data,
             aes(x=longitude,y=latitude),
             alpha=0.4,pch=21,size=2,color='grey',fill='brown')+
  geom_point(data=obs_effort_filt,
             aes(x=longitude,y=latitude),
             alpha=0.4,pch=21,size=2,fill='lightblue')+
  facet_wrap(~source,nrow=1)+
  theme(panel.grid.major = element_line(color = gray(.9),linetype = "dashed", linewidth = 0),
        panel.background = element_rect(fill = "ghostwhite"),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = 'none')

# Getting the average value
avg <- smp_bkgfilt %>%
  summarize(n=n(),.by=c('state','cell')) %>% 
  summarize(median=median(n),.by='state') %>%
  filter(state != 'California') %>%
  summarize(avg = mean(median)) %>%
  unlist() %>% as.integer()

# Sampling the average value from each cell in California
CAsmp_spatsampled <- smp_bkgfilt %>% filter(state=='California') %>%
  slice_sample(n = avg, by = cell)

# Plotting old California data with subsampled California data
viz_data <- smp_bkgfilt %>% filter(state=='California') %>% slice_sample(prop=0.1) %>%
  select(longitude,latitude) %>% mutate(source='Before subsampling') %>%
  bind_rows(CAsmp_spatsampled %>% select(longitude,latitude) %>%
              mutate(source='After subsampling')) %>% 
  mutate(source = factor(source,levels=c('Before subsampling','After subsampling')))
ggplot()+geom_sf(data=states)+
  geom_sf(data=bkg,fill='lightpink',alpha=0.4)+
  geom_point(data=viz_data,
             aes(x=longitude,y=latitude),
             alpha=0.4,pch=21,size=2,color='grey',fill='brown')+
  geom_point(data=obs_effort_filt,
             aes(x=longitude,y=latitude),
             alpha=0.4,pch=21,size=2,fill='lightblue')+
  facet_wrap(~source,nrow=1)+
  theme(panel.grid.major = element_line(color = gray(.9),linetype = "dashed", linewidth = 0),
        panel.background = element_rect(fill = "ghostwhite"),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = 'none')

# Creating final checklist object by deleting original California checklists
# and adding filter chekclists
smp_final <- smp_bkgfilt %>% filter(state!='California') %>%
  bind_rows(CAsmp_spatsampled)

# Checking numbers
smp_final %>% 
  summarize(total=n(),.by='state') %>%
  left_join(smp_final %>%
              summarize(n=n(),.by=c('state','cell')) %>%
              summarize(median_per_cell=median(n),.by='state'),
            by='state')

# Observations sub-sampling####
# Simpler, since we don't need to make a background.
# We just need to subsample based on the raster cell

# Extracting cell values for observation
obs_effort_filt <- obs_effort_filt %>%
  mutate(cell = cellFromXY(r,obs_effort_filt %>% select(longitude,latitude) %>%
                             as.matrix()))

# Checking numbers
obs_effort_filt %>% 
  summarize(total=n(),.by='state') %>% 
  left_join(obs_effort_filt %>%
              summarize(n=n(),.by=c('state','cell')) %>%
              summarize(median_per_cell=median(n),.by='state'),
            by='state')

# On average, California has 16 lists per cell, while Mexican states have 3
# We gotta reduce from 16 to 3
# Analogous to spatial thinning

# Getting the average value
avg <- obs_effort_filt %>%
  summarize(n=n(),.by=c('state','cell')) %>% 
  summarize(median=median(n),.by='state') %>%
  filter(state != 'California') %>%
  summarize(avg = mean(median)) %>%
  unlist() %>% as.integer()
  
# Sampling the average value from each cell in California
CAobs_spatsampled <- obs_effort_filt %>% filter(state=='California') %>%
    slice_sample(n = avg, by = cell)

# Plotting old California obs data with subsampled California obs data
viz_data <- obs_effort_filt %>% filter(state=='California') %>%
  select(longitude,latitude) %>% mutate(source='Before subsampling') %>%
  bind_rows(CAobs_spatsampled %>% select(longitude,latitude) %>%
              mutate(source='After subsampling')) %>% 
  mutate(source = factor(source,levels=c('Before subsampling','After subsampling')))
ggplot()+geom_sf(data=states)+
  geom_sf(data=bkg,fill='lightpink',alpha=0.4)+
  geom_point(data=viz_data,
             aes(x=longitude,y=latitude),
             alpha=0.4,pch=21,size=2,fill='lightblue')+
  facet_wrap(~source,nrow=1)+
  theme(panel.grid.major = element_line(color = gray(.9),linetype = "dashed", linewidth = 0),
        panel.background = element_rect(fill = "ghostwhite"),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = 'none')

# Creating final checklist object by deleting original California checklists
# and adding filter chekclists
obs_final <- obs_effort_filt %>% filter(state!='California') %>%
  bind_rows(CAobs_spatsampled)

# Checking numbers
obs_final %>% 
  summarize(total=n(),.by='state') %>%
  left_join(obs_final %>%
              summarize(n=n(),.by=c('state','cell')) %>%
              summarize(median_per_cell=median(n),.by='state'),
            by='state')

# Exporting
write_csv(obs_final,'data/ebd_nyc_vio/obs_fullyfiltered.csv')
write_csv(smp_final,'data/ebd_nyc_vio/smp_fullyfiltered.csv')
