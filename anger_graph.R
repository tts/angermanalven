library(dplyr)
library(magick)
library(glue)
library(ggplot2)
library(colorspace) 
library(MetBrewer) 

# After https://github.com/Pecners/rayshader_portraits/tree/main/R/portraits/seine

colors <- met.brewer("Hokusai2", n = 10, direction = -1)
text_color <- colors[1]

img <- image_read("anger_plot.png")

img %>% 
  image_crop(geometry = "7500x4000+0+500", gravity = "center") %>% 
  image_annotate(text = "Den stora älgvandringen filmas här uppe",
                 gravity = "north",
                 location = "-1050+600", font = "Trebuchet",
                 color = alpha(text_color, .75),
                 size = 100) %>%
  image_annotate(text = "Ångermanälven",
               gravity = "south",
               location = "-1200+1350", font = "Trebuchet",
               color = alpha(text_color, .85),
               size = 400, weight = 700) %>%
  image_annotate(text = "Bottenhavet",
                 gravity = "southeast",
                 location = "+600+500", font = "Trebuchet",
                 kerning = 30,
                 color = alpha(text_color, .45),
                 size = 100) %>%
  image_annotate(text = "befolkningstäthet inom 25 km avstånd", 
                 gravity = "south",
                 location = "-1640+1150", font = "Trebuchet",
                 color = alpha(text_color, .85),
                 size = 120) %>% 
  image_annotate(text = glue("Tuija Sonkkila (@tts) after the River Seine code by Spencer Schien (@MrPecners) | ",
                             "Kontur Population Data 400m H3 hexagons (June 30, 2022)"),
                 gravity = "south",
                 location = "+0+100", font = "Trebuchet",
                 color = alpha(text_color, .5),
                 size = 60, weight = 700) %>%  
  image_write("anger_pop_ann.png")

image_read("anger_pop_ann.png") %>% 
 image_scale(geometry = "37%x") %>% 
 image_write("anger_pop_ann_small.png")

