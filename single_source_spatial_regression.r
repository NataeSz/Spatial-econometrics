rm(list = ls())

library(rgdal)
library(sp)
library(eurostat)

setwd("C:/Users/Natalia/Documents/Git/Spatial-econometrics")

# Unzipping files

# files <- paste(getwd(),'/data/', unique(unlist(strsplit(dir(getwd()), '.zip', fixed = 1))), sep='')
# for (i in 1:length(files)){ 
#   print(paste(files[i], '.zip',sep=''))
#   unzip(paste(files[i], '.zip', sep=''), exdir = files[i])
# }
# 
# # Creating SpatialPointsDataFrame for each NUTS 1 region
# mapa=list()
# for (k in 1:length(files)){
#   print(files[k])
#   setwd(files[k])
#   mapa[[k]] <- readOGR(".", "gis_osm_pois_a_free_1")
#   mapa[[k]] <- spTransform(mapa[[k]], "+proj=longlat")
#   mapa[[k]] <- mapa[[k]][mapa[[k]]@data$fclass == "university",]
#   mapa[[k]]@data$lon <- NA
#   mapa[[k]]@data$lat <- NA
#   for (ii in 1:nrow(mapa[[k]])) {
#     mapa[[k]]@data$lon[ii] <- mapa[[k]]@polygons[[ii]]@Polygons[[1]]@labpt[1]
#     mapa[[k]]@data$lat[ii] <- mapa[[k]]@polygons[[ii]]@Polygons[[1]]@labpt[2]
#   }
#   mapa[[k]] <- mapa[[k]]@data[,c("name","lon","lat")]
#   mapa[[k]]$name <- as.character(mapa[[k]]$name)
#   
#   coordinates(mapa[[k]]) <- c("lon", "lat")
#   # plot(mapa[[k]])
# }
# 
# #Creating university location data frame
# dane <- as.data.frame(list(mapa[[1]]@data, mapa[[1]]@coords))
# for (i in 2:length(files)){ # Appneding data frame
#   dane<- rbind(dane, as.data.frame(list(mapa[[i]]@data, mapa[[i]]@coords)))
# }
# rm(mapa)

#####
# write.csv(x= dane, file='dane_pd4_v2.csv', row.names = FALSE)
dane <- read.csv('sp_regression_data.csv')
#####

source('Cmn_vars.r')
coordinates(dane) <- ~lon + lat


#############
#Visualise with map background (map source: Stamen, ?get_map for alternatives); ggplot2 flavour
library(ggmap) 
gmap <- get_map(location = (bbox(dane)),
                source = "stamen", maptype = "toner", crop = TRUE)
gg <- ggmap(gmap)
gg <- gg + geom_point(data = as.data.frame(dane), 
                      aes(lon, lat),
                      size = 3, 
                      shape = 20, alpha = 0.5) +
  labs(x = "logitude", y = "latitude")
gg
############


proj4string(dane) <- mapa@proj4string

# Assigning informafion about the region to each university
dane$reg <- over(dane, mapa)$NUTS_ID_char


# Number of universities in each region

# t(as.matrix(table(dane@data$reg)))
df <- merge(df, as.data.frame(table(dane@data$reg)), by.x= 'geo', by.y='Var1')
df$uni_pc <- df$Freq / df$Population *1000000 # Number of universities per 100 000 inhabitants

# New variable plot

spatial_data <- merge(y = df, x = mapa, by.y = "geo", by.x = "NUTS_ID")

blue_area <- rgb(0, 123, 255, 90, names = NULL, maxColorValue = 255)
pal <- colorRampPalette(c("white", blue_area), bias = 1)
spplot(spatial_data, zcol = "uni_pc", colorkey = TRUE, col.regions = pal(100), cuts = 99,
       par.settings = list(axis.line = list(col =  'transparent')),
       # sp.layout = list(dane, col = 'navy', alpha = 0.2, pch = 16), # uncomment to show all universities in the map
       main = "Number of universities\nper 1 000 000 inhabitants")

