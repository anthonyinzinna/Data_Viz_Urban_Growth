library(sf)
library(raster) 
library(dplyr)
library(spData)
library(tmap)
library(leaflet)
library(ggplot2)
library(magick) 


#  manually download the file to avoid package installation issues
if (!file.exists("nz_elev_temp.tif")) {
  message("Downloading nz_elev data...")
  u <- "https://github.com/Nowosad/spDataLarge/raw/master/inst/raster/nz_elev.tif"
  download.file(url = u, destfile = "nz_elev_temp.tif", mode = "wb")
}

# Load the data into R
nz_elev <- raster("nz_elev_temp.tif")
message("Data loaded successfully: nz_elev")

# Basic Shapes 
tm_shape(nz) + tm_fill() 
tm_shape(nz) + tm_borders() 
tm_shape(nz) + tm_fill() + tm_borders() 

map_nz = tm_shape(nz) + tm_polygons()

# Layer 1: Topography (Elevation)
map_nz1 = map_nz + 
  tm_shape(nz_elev) + 
  tm_raster(alpha = 0.7)

# Layer 2: Water Buffers
nz_water = st_union(nz) %>% st_buffer(22200) %>% 
  st_cast(to = "LINESTRING")

map_nz2 = map_nz1 +
  tm_shape(nz_water) + tm_lines()

# Layer 3: Region Box 
nz_region = st_bbox(c(xmin = 1340000, xmax = 1450000,
                      ymin = 5130000, ymax = 5210000),
                    crs = st_crs(nz)) %>% 
  st_as_sfc()

map_nz3 = map_nz1 + tm_shape(nz_region) + tm_borders(lwd = 3)

# side-by-side view
tmap_arrange(map_nz1, map_nz2, map_nz3)

# Define map_nza so style tests work
map_nza = map_nz1 

# Test different aesthetics
map_nza + tm_style("bw")
map_nza + tm_style("classic")
map_nza + tm_style("cobalt")
map_nza + tm_style("white") 

# Static Comparison
urb_1970_2030 = urban_agglomerations %>% 
  filter(year %in% c(1970, 1990, 2010, 2030))

tm_shape(world) +
  tm_polygons() +
  tm_shape(urb_1970_2030) +
  tm_symbols(col = "black", border.col = "white", size = "population_millions") +
  tm_facets(by = "year", nrow = 2, free.coords = FALSE)

#Animation
message("Starting Animation Process...")

# Setup
years <- sort(unique(urban_agglomerations$year))

# We create a specific folder in your project to hold the frames
# This allows us to see if they are actually being created
dir.create("frames_debug", showWarnings = FALSE)

file_paths <- character(length(years))

# Loop to generate frames using standard PNG device 
for (i in seq_along(years)) {
  y <- years[i]
  
  # 1. Define the map object
  map <- tm_shape(world) + 
    tm_polygons(col = "#e5e5e5", border.col = "#d9d9d9") + 
    tm_shape(urban_agglomerations %>% filter(year == y)) + 
    tm_dots(size = "population_millions", col = "#00441b", alpha = 0.6) + 
    tm_layout(
      title = paste("Year:", y), 
      title.position = c("left", "bottom"), 
      frame = FALSE
    )
  
  # 2. Define filename
  fname <- file.path("frames_debug", paste0("frame_", sprintf("%03d", i), ".png"))
  file_paths[i] <- fname
  
  # 3. Open Device, Print Map, Close Device
  png(filename = fname, width = 1000, height = 600, res = 100)
  print(map)
  dev.off()
  
  if(i %% 5 == 0) message(paste("Rendered year:", y))
}

# Check if the first file exists to prevent errors
if (file.exists(file_paths[1])) {
  img_anim <- file_paths %>% 
    image_read() %>% 
    image_join() %>% 
    image_animate(fps = 4) # 4 frames per second
  
  # Save Final Output
  image_write(img_anim, "urban_growth_final.gif")
  
  # Delete the debug folder
  unlink("frames_debug", recursive = TRUE)
  
  message("DONE! Check your folder for 'urban_growth_final.gif'")
} else {
  message("ERROR: Frames were not created. Please check permissions.")
}