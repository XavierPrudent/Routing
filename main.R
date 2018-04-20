##
## Load general packages
source("~/Civilia/tech/general/load_R_pkg.R")
source("include.R")
##
## Read json
js <- "data/tour_smartBin_iti35-14mars2018-route-noCurb.json"
df <- fromJSON(js)
##
## Extract geometry
#trip <- as.data.frame(df$trips$geometry$coordinates[[1]])
trip <- as.data.frame(df$routes$geometry$coordinates[[1]])
##
## Convert to line
trip <- points_to_line(data = trip, long = "V1", lat = "V2")
##
## Extract marques
loc <- df$waypoints$location
loc <- do.call(rbind.data.frame, loc)
#loc$id <- df$waypoints$waypoint_index + 1
loc$id <- 1:nrow(loc)
colnames(loc) <- c("lon", "lat","id")
##
## Extract distances
dist <- df$trips$legs[[1]]$distance
##
## Load map
coord <- data.frame(lat=45.53974,lon=-73.50888)
map <- leaflet() %>%
  addTiles('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png') %>%
  setView(coord$lon, coord$lat, zoom = 13)
##
## Plot the trip
map1 <- map %>% addPolylines(data=trip,
                            # label=paste("Dist.",round(df$trips$distance),"m"),
                             color="red",
                             highlight = highlightOptions(color="orange"))
## 
## Plot the marques
map1 <- map1 %>% addCircles(data = loc,
                            lng = ~lon,
                            lat = ~lat,
                            opacity = 1,
                            color="forestgreen") %>%
  addLabelOnlyMarkers(data=loc,~lon, ~lat, label=~as.character(id),
                      labelOptions = labelOptions(noHide = T, direction = 'top', textOnly = T))



##
## Display the map
map1



