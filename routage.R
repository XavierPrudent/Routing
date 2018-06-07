
library(data.table)
library(sp)
library(maptools)
library(leaflet)
source("include.R")

CSV <- "data/smartBin/2018-04-18_Sites.csv"
CSV <- fread(CSV)

##
## Create random sets of bins
for( i in 1:10){
  print(i)
  set.seed(i)
  JSON <- paste("out/randomRoutes/routage/routage_",i,".json",sep="")
  MAP <- paste("out/randomRoutes/maps/map_",i,sep="")
  n <- 40
  BINS <- CSV %>% sample_n(n) %>% unique()
  routingCivilia(BINS, JSON, MAP)
}

##
## Full routing function
routingCivilia <- function(BINS, JSON, MAP){
  unlink(JSON)
  unlink(paste(MAP,".html",sep=""))
  COORD <- ""
  CURB <- ""
  for( i in 1:nrow(BINS)){
    if( i < nrow(BINS) ){
      COORD <- paste(COORD,BINS$V2[i],",",BINS$V1[i],";",sep="")
      CURB <- paste(CURB,"curb;",sep="")
    }
    else{
      COORD <- paste(COORD,BINS$V2[i],",",BINS$V1[i],sep="")
      CURB <- paste(CURB,"curb",sep="")
    }
  }
  
  ##
  ## Trip (tour) or route (direct)
  ## All navi details
  SVC <- "trip"
  STEPS <- "false"
  
  ##
  ## Build the query api
  LINK <- "http://routing.civilia.ca/"
  OPT1 <- "/v1/driving/"
  OPT2 <- paste("?steps=",STEPS,"&geometries=geojson&overview=full&source=first&destination=last&approaches=",sep="")
  CMD <- paste(LINK, SVC, OPT1, COORD, OPT2, CURB, sep="")
  CMD <- paste('curl "', CMD, '" > ', JSON,sep='')
  system(CMD)
  
  ##
  ## Read json
  df <- fromJSON(JSON)
  
  ##
  ## Total distance
  cat(paste("Total distance:", round(df$trips$distance/1000), "km\n"))
  cat(paste("Total time:", round(df$trips$duration/3600,digits = 2), "h"))
  
  ##
  ## Extract geometry
  trip <- as.data.frame(df$trips$geometry$coordinates[[1]])
  
  ##
  ## Convert points to line
  trip <- points_to_line(data = trip, long = "V1", lat = "V2")
  
  ##
  ## Extract marques
  loc <- df$waypoints$location
  loc <- do.call(rbind.data.frame, loc)
  loc$id <- df$waypoints$waypoint_index
  colnames(loc) <- c("lon", "lat","id")
  
  ##
  ## Extract distances
  dist <- df$trips$legs[[1]]$distance
  
  ##
  ## Load map
  coord.Longueuil <- data.frame(lon=-73.50888,lat=45.53974)
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
  map1 <- map1 %>% addCircles(data = BINS,
                              lng = ~V2,
                              lat = ~V1,
                              opacity = 1,
                              color="forestgreen") 
  
  ##
  ## Save the map
  name <- paste(MAP,".html",sep="")
  name <- paste(getwd(),name,sep="/")
  saveWidget(map1, file=name,selfcontained = TRUE)
  name <- paste(MAP,"_files",sep="")
  name <- paste(getwd(),name,sep="/")
  unlink(name, recursive = TRUE)
}

