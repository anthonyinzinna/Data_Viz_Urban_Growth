library(sf)
library(dplyr)
library(spData)
library(tmap)
library(magick)

# Message indicating start of Global Visualization Project
message("Initializing Global Urbanization Visualization Project...")

# Filter data for key historical and projected milestones
urb_1970_2030 = urban_agglomerations %>%
  filter(year %in% c(1970, 1990, 2010, 2030))

# Create faceted static map to visualize the density shift
tm_shape(world) +
  tm_polygons() +
  tm_shape(urb_1970_2030) +
  tm_symbols(col = "black", border.col = "white", size = "population_millions") +
  tm_facets(by = "year", nrow = 2, free.coords = FALSE)

# Implement a manual PNG device loop to stitch frames via Magick.

message("Starting Custom Animation Rendering Pipeline...")

# Setup: Define temporal range and output directory
years <- sort(unique(urban_agglomerations$year))
dir.create("frames_temp", showWarnings = FALSE)
file_paths <- character(length(years))

# Execute Rendering Loop
for (i in seq_along(years)) {
  y <- years[i]
  
  # Build the Map Frame
  map <- tm_shape(world) +
    tm_polygons(col = "#e5e5e5", border.col = "#d9d9d9") +
    tm_shape(urban_agglomerations %>% filter(year == y)) +
    # Green color scheme to symbolize growth
    tm_dots(size = "population_millions", col = "#00441b", alpha = 0.6) +
    tm_layout(
      title = paste("Year:", y),
      title.position = c("left", "bottom"),
      frame = FALSE
    )
  
  # Define Output Path
  fname <- file.path("frames_temp", paste0("frame_", sprintf("%03d", i), ".png"))
  file_paths[i] <- fname
  
  # Manual Device Control (Prevents Memory Leaks)
  png(filename = fname, width = 1000, height = 600, res = 100)
  print(map)
  dev.off()
  
  if(i %% 5 == 0) message(paste("Rendered frame for year:", y))
}

# Frame Stitching (Magick Engine)
if (file.exists(file_paths[1])) {
  img_anim <- file_paths %>%
    image_read() %>%
    image_join() %>%
    image_animate(fps = 4) # Set playback speed
  
  # Save Final Artifact
  image_write(img_anim, "Global_Urbanization_Shift.gif")
  
  # Remove temporary frames to keep directory clean
  unlink("frames_temp", recursive = TRUE)
  
  message("SUCCESS: Animation saved as 'Global_Urbanization_Shift.gif'")
} else {
  message("ERROR: Rendering failed.")
}
