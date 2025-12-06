# Data_Viz_Urban_Growth
This project demonstrates Geospatial Analysis and Advanced Visualization using R. Instead of relying on standard plot functions, I implemented a custom rendering pipeline that generates individual map frames for each year and uses the Magick image processing engine to stitch them into a cohesive time-lapse animation.



Executive Summary of Findings

Summary of the key analytical insights and technical outcomes from this visualization project:

1. Temporal Evolution of Urban Centers (1950–2030)

Observation: The visualization tracks the location and size of urban agglomerations over an 80-year period.

Result: We observe a distinct "Eastward Shift" in global population density. While the 1950s show a concentration of large cities in the West (Europe/USA), the projected data for 2010–2030 reveals a massive explosion of high-density clusters in the Global South (specifically India, China, and Nigeria).

2. Technical Stability & Rendering Pipeline

Challenge: Standard animation libraries in R often fail when rendering high-resolution time-series data on specific architectures (macOS/ARM64).

Solution: We implemented a robust "Manual Device" pipeline. Instead of relying on automated wrappers, the script manually generates individual PNG frames for every year and stitches them using the magick engine.

Outcome: This ensured a crash-free, high-quality output where every year from 1950 to 2030 is accurately represented without frame dropping.

Visual Interpretation 🧠
The animation paints a clear picture of the "Megacity" phenomenon:

Acceleration of Growth: The dots do not just get bigger linearly; they grow exponentially in the final seconds of the animation (2000-2030), visually confirming the rapid acceleration of modern urbanization.

Emergence of New Hubs: The map highlights that future urbanization is not happening in established zones, but rather in emerging economies. The density of dots in Southeast Asia by the end of the simulation acts as a visual proxy for the region's rapid economic and population expansion.

Final Technical Takeaway
Successful Custom Implementation The primary achievement of this script is the creation of a hardware-agnostic rendering loop. By bypassing the default tmap_save functions and utilizing a raw png() device loop, the project demonstrates how to handle memory-intensive geospatial animations on constrained or complex systems (like Apple Silicon) where standard tools often fail.
