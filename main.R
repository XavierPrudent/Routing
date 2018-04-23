#!/usr/bin/env Rscript
args = commandArgs(TRUE)

##########################################
## Build a map from a osrm json
##
## Use as a script with arguments:
## 1: input json file
## 2: 'trips' or 'routes'
## 3: input datapoints
## 4: output html map, relative path
##########################################

##
## Load general packages
source("~/Civilia/tech/general/load_R_pkg.R")
source("include.R")

##
## Inputs
jsonFile <- args[1]
tripRoute <- args[2]
bins <- args[3]
outMap <- args[4]

##
## Read json
df <- fromJSON(jsonFile)

##
## Total distance
cat(paste("Total distance:", round(df$trips$distance/1000), "km\n"))
cat(paste("Total time:", round(df$trips$duration/3600,digits = 2), "h"))

##
## Extract geometry
if (tripRoute == "trips" ) trip <- as.data.frame(df$trips$geometry$coordinates[[1]])
if (tripRoute == "routes" ) trip <- as.data.frame(df$routes$geometry$coordinates[[1]])

##
## Convert points to line
trip <- points_to_line(data = trip, long = "V1", lat = "V2")

##
## Extract marques
loc <- df$waypoints$location
loc <- do.call(rbind.data.frame, loc)
#loc$id <- 1:nrow(loc)
loc$id <- df$waypoints$waypoint_index
colnames(loc) <- c("lon", "lat","id")

##
## Extract distances
if (tripRoute == "trips" ) dist <- df$trips$legs[[1]]$distance

##
## Load map
map <- leaflet() %>%
  addTiles('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png') %>%
  setView(coord.Longueuil$lon, coord.Longueuil$lat, zoom = 13)

##
## Plot the trip
map1 <- map %>% addPolylines(data=trip,
                             color="red",
                             highlight = highlightOptions(color="orange"))

## 
## Plot the marques
map1 <- map1 %>% addCircles(data = loc,
                            lng = ~lon,
                            lat = ~lat,
                            opacity = 0,
                            color="forestgreen") %>%
  addLabelOnlyMarkers(data=loc,~lon, ~lat, label=~as.character(id),
                      labelOptions = labelOptions(noHide = T, direction = 'top', textOnly = T))

##
## Add the real positions
bins <- fread(bins)
map1 <- map1 %>% addCircles(data = bins,
                            lng = ~V2,
                            lat = ~V1,
                            opacity = 1,
                            color="forestgreen") 


##
## Display the map
map1

##
## Save the map
name <- paste(outMap,".html",sep="")
name <- paste(getwd(),name,sep="/")
print(name)
saveWidget(map1, file=name,selfcontained = TRUE)
name <- paste(outMap,"_files",sep="")
name <- paste(getwd(),name,sep="/")
unlink(name, recursive = TRUE)



