setwd('/home/rilquer/github/nyctanassa-violacea-modeling/')

ebd_nvio_california <- read_csv('data/ebd_nyc_vio/ebd_nvio_california.csv')

min(ebd_nvio_california$LATITUDE)
max(ebd_nvio_california$LATITUDE)
require(terra)
# Setting resolutions
# 0.05 = 5.5 km
# 0.1 = 11 km
# 0.2 = 22 km
# 0.3 = 33.33 km
# 0.4 = 44.45 km
# 0.5 (30 min) = 55 km
# 0.6 (30 min) = 66.72 km
# 0.7 (30 min) = 77.84 km
# 0.8 (30 min) = 88.96 km
# 0.9 (30 min) = 110.18 km
# 1 = 110 km
resolutions = c(0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)
r <- lapply(resolutions,function(x){
  r <- rast(
    xmin = -124, xmax = -108,  # Longitude boundaries
    ymin = 20,   ymax = 40,    # Latitude boundaries
    res = x,                # Resolution (can pass c(xres, yres) if non-square)
    crs = "EPSG:4326"          # Coordinate Reference System (WGS84)
)
  values(r) <- rnorm(ncell(r))
  return(r)
  })

lapply(r,function(x){
  return(cellFromXY(x, ebd_nvio_california %>% dplyr::select(LONGITUDE,LATITUDE) %>% as.matrix()) %>%
    unique() %>%
    length())
}) %>% unlist() %>% as_tibble() %>% add_column(resolutions) %>%
  ggplot(aes(x=resolutions,y=value))+
  geom_point()+geom_line()


