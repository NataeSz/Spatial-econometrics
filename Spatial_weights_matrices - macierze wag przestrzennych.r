setwd("C:/Users/Natalia/Documents/Git/Spatial-econometrics")

# clear the workspace, plots and console
rm(list = ls())

library(rgdal)
library(sp)
library(spdep)
library(spatialreg)
library(geosphere)

source('Cmn_vars.r')


# High-tech patents in Germany map
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
