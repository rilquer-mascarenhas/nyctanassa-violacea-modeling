# Packages needed:
# Tidyverse, rnaturalearth, sf

require(tidyverse)
require(rnaturalearth)

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
