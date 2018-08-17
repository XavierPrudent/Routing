source("~/Civilia/tech/general/load_R_pkg.R")

## All sites
sites <- fread("data/smartBin/2018-04-18_Sites.csv")

## Longueuil map
#addTiles('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png') %>%
  map <- leaflet() %>%
  addProviderTiles('Esri.WorldImagery') %>%
  setView(coord.Longueuil$lon, coord.Longueuil$lat, zoom = 13) %>% 
    addProviderTiles("CartoDB.PositronOnlyLabels")
  
  
## Plot the sites
map1 <- map %>%  addCircles(data = sites,
                            lng = ~V2,
                            lat = ~V1,
                            opacity = 1,
                            color="red") 

##
## Display the map
map1

