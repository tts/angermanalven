library(sf)
library(dplyr)
library(stars)
library(ggplot2)
library(rayshader)
library(rnaturalearth)
library(MetBrewer) 
library(colorspace) 

# After https://github.com/Pecners/rayshader_portraits/tree/main/R/portraits/seine

# https://data.humdata.org/dataset/kontur-population-sweden
# Sweden: Population Density for 400m H3 Hexagons

data <- st_read("kontur_population_SE_20220630.gpkg")

rivers <- ne_download(scale = 10, type = 'rivers_lake_centerlines', 
                      category = 'physical', returnclass = "sf")
anger <- rivers %>% 
  filter(name == "Ångermanälven") 

anger_buff <- st_transform(anger, crs = st_crs(data)) %>%  
  st_buffer(25000)

int <- st_intersects(anger_buff, data)

st_d <- data[int[[1]],]

bb <- st_bbox(st_d)

yind <- st_distance(st_point(c(bb[["xmin"]], bb[["ymin"]])), 
                    st_point(c(bb[["xmin"]], bb[["ymax"]])))
xind <- st_distance(st_point(c(bb[["xmin"]], bb[["ymin"]])), 
                    st_point(c(bb[["xmax"]], bb[["ymin"]])))

if (yind > xind) {
  y_rat <- 1
  x_rat <- xind / yind
} else {
  x_rat <- 1
  y_rat <- yind / xind
}

rm(data)
rm(rivers)
gc()

size <- 6000 # 1000 to test
rast <- st_rasterize(st_d %>% 
                       select(population, geom),
                     nx = floor(size * x_rat), ny = floor(size * y_rat))

mat <- matrix(rast$population, nrow = floor(size * x_rat), ncol = floor(size * y_rat))

rgl::close3d()

colors <- met.brewer("Hokusai2", n = 10, direction = -1)
swatchplot(colors)
texture <- grDevices::colorRampPalette(colors, bias = 4)(256)
swatchplot(texture)

mat %>% 
  height_shade(texture = texture) %>% 
  plot_3d(heightmap = mat, 
          solid = FALSE,
          soliddepth = 0,
          z = 0.25, # 0.25 * 6 at first
          shadowdepth = 0,
          windowsize = c(800,800),
          phi = 45, 
          zoom = 1, 
          theta = 0)

render_camera(
  theta = 0, 
  phi = 30,
  zoom= 0.60
)

outfile <- 'anger_plot.png'

{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), "\n")
  if (!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  
  render_highquality(
    preview = FALSE, 
    filename = outfile,
    interactive = FALSE, 
    lightdirection = rev(c(220, 220, 230, 230)),
    lightcolor = c(colors[1], "white", colors[10], "white"),
    lightintensity = c(750, 100, 1000, 100),
    lightaltitude = c(10, 80, 10, 80),
    samples = 450, # 300 to test
    width = 6000, # 1000 to test
    height = 6000 # 1000 to test
  )
  
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), "\n")
}

# 2023-04-28 08:25:58.817023 
# 2.3486176194085 
#
# anger_plot.png size 63.9 MB