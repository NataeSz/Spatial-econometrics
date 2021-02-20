setwd("C:/Users/Natalia/Documents/Git/Spatial-econometrics")

# clear the workspace, plots and console
rm(list = ls())

library(rgdal)
library(sp)
library('eurostat')
library(spdep)
library('spatialreg')
library(geosphere)


mapa <- readOGR("NUTS/.", "NUTS_RG_01M_2013")
mapa <- spTransform(mapa, "+proj=longlat")

# Load data
df <- get_eurostat('tgs00041')
df <- df[((substr(df$geo, 1, 2)=='DE') & (substr(df$time,1,4)=='2012')),] # Select the country (Germany) and time (2012)


# add independent variables
add_ind_var <- function(df, data, name, s=F){
  var1 <- get_eurostat(data)
  names(var1)[names(var1) == 'values'] <- name
  if (s==F ){
    var1 <- var1[((substr(var1$geo, 1, 2)=='DE') & (substr(var1$time,1,4)=='2012')),]
  }else if(s==T){
    var1 <- var1[((substr(var1$geo, 1, 2)=='DE') & (substr(var1$time,1,4)=='2012') & (var1$sex=='T')),]
  }
  df <- merge(df, var1[c('geo',name)], by = "geo")
  return(df)
}

# Population
df <- add_ind_var(df, 'tgs00096', 'Population')

# GDP (PPS - Purchasing power standard) per inhabitant
df <- add_ind_var(df, 'tgs00005', 'GDP')

# Unemployment rate by NUTS 2 regions
# - employed persons aged 15-64 as a percentage of the population of the same age group
df <- add_ind_var(df, 'tgs00007', 'emp', s=T)



##############
# Limit map to Germany
mapa@data$NUTS_ID_char <- as.character(mapa@data$NUTS_ID)
mapa@data$country <- substr(mapa@data$NUTS_ID_char, 1, 2) 
mapa <- mapa[mapa@data$country == "DE", ]
mapa <- mapa[mapa@data$NUTS_ID %in% unique(df$geo),]
# Merge map and data
spatial_data <- merge(y = df, x = mapa, by.y = "geo", by.x = "NUTS_ID")
rm(mapa)


# colors
blue_area <- rgb(0, 123, 255, 90, names = NULL, maxColorValue = 255)
N <- nrow(spatial_data)
centroids <- coordinates(spatial_data)
plot(spatial_data)
points(centroids, pch = 16, col = blue_area)

##########
# Neighbourhood matrix
cont1 <- poly2nb(spatial_data, queen = T)
W1_list <- nb2listw(cont1, style = "B") 
W1 <- listw2mat(W1_list)
max_eigen <- max(eigen(W1)$values) # maks wart wlasna
W1 <- W1/max_eigen
plot.nb(mat2listw(W1, style="B")$neighbours, centroids, col = blue_area, pch = 16)


########
# Matrix of inverted distance
distance <- distm(coordinates(spatial_data), fun = distCosine) / 1000

rownames(distance) <- spatial_data@data$jpt_kod_je
colnames(distance) <- spatial_data@data$jpt_kod_je

limit <- 200
gamma <- 2

W2 <- 1 / (distance ^ gamma)
diag(W2) <- 0
W2[distance>200] <-0 # 0 where the limit value is exceeded

W2 <- W2 / as.matrix(rowSums(W2)) %*% matrix(1, nrow = 1, ncol = N)
W2_list <- mat2listw(W2, style="W")
plot.nb(W2_list$neighbours, centroids, col = blue_area, pch = 16)


########
# Euclidian distance
distance2 <- matrix(0, nrow = N, ncol = N)
for(ii in 1:N) {
  for(jj in 1:N) {
    distance2[ii, jj] <- sqrt(
      (spatial_data@data$Population[ii] - spatial_data@data$Population[jj])**2 # var1
      + (spatial_data@data$GDP[ii] - spatial_data@data$GDP[jj])**2 # var2
      + (spatial_data@data$emp[ii] - spatial_data@data$emp[jj])**2) # var3
  }
}
W3 <- distance2 
W3 <- W3 / (as.matrix(rowSums(W3)) %*% matrix(1, nrow = 1, ncol = N))
rm(ii, jj)
W3_list <- mat2listw(W3, style = "B")
plot.nb(W3_list$neighbours, centroids, col = blue_area, pch = 16)
