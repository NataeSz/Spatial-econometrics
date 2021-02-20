#SET WORKING DIRECTORY
setwd("C:/Users/Natalia/Documents/Git/Spatial-econometrics")
rm(list = ls())

library(rgdal)
library(sp)
library(spdep)
library(eurostat)


mapa <- readOGR("NUTS/.", "NUTS_RG_01M_2013")
mapa <- spTransform(mapa, "+proj=longlat")
blue_area <- rgb(0, 123, 255, 90, names = NULL, maxColorValue = 255)

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
# Unemployment rate by NUTS 2 regions - employed persons aged 15-64 as a percentage
df <- add_ind_var(df, 'tgs00007', 'emp', s=T)


##############
# Limit map to Germany
mapa@data$NUTS_ID_char <- as.character(mapa@data$NUTS_ID)
mapa@data$country <- substr(mapa@data$NUTS_ID_char, 1, 2) 
mapa <- mapa[mapa@data$country == "DE", ]
mapa <- mapa[mapa@data$NUTS_ID %in% unique(df$geo),]
# Merge the map and data
spatial_data <- merge(y = df, x = mapa, by.y = "geo", by.x = "NUTS_ID")
rm(mapa)


#LINEAR MODEL ESTIMATED VIA OLS
model <- lm(values ~ Population + GDP + emp, data = spatial_data)
summary(model)

#GRAPHICAL EVALUATION
spatial_data$res <- model$residuals
pal <- colorRampPalette(c("red", "white", blue_area), bias = 1.6)
#
spplot(spatial_data, zcol = "res", colorkey = TRUE, col.regions = pal(100), cuts = 99,
       par.settings = list(axis.line = list(col =  'transparent')),
       main = "High-tech patent applications")

#GLOBAL MORAN'S TEST FOR RESIDUALS
cont1 <- poly2nb(spatial_data, queen = T)
W1_list <- nb2listw(cont1, style = "W")
lm.morantest(model, W1_list, alternative = "greater")
res <- model$residuals
moran.plot(res, W1_list, ylab = "Spatial lag of residuals: W*e", xlab = "Residuals: e", pch = 20, main = "Moran's plot", col = blue_area)


#Local Moran's tests
localmoran(res, W1_list, p.adjust.method = "bonferroni")

#Geary's C test
geary.test(res, W1_list)

#Join count tests
joincount.test(as.factor(res > 0), listw = W1_list)

# Sensitivity analysis of join count test treshold
pvalue <- list()
pvalue2 <- list()
for (i in seq(min(res), max(res), 0.1)){
  pvalue <- c(pvalue, joincount.test(as.factor(res > i), listw = W1_list)[[1]]$p.value[[1]])
  pvalue2 <- c(pvalue2, joincount.test(as.factor(res > i), listw = W1_list)[[2]]$p.value[[1]])
}
plot(seq(min(res), max(res), 0.1), pvalue, type='l', lwd=2, 
     main = 'Sensitivity analysis for join count test treshold', xlab='Treshold', ylim=c(0,1))
lines(seq(min(res), max(res), 0.1), pvalue2, col='gray', lty = 2, lwd = 3)
lines(seq(min(res), max(res), 0.1), rep(0.1,length(seq(min(res), max(res), 0.1))), col='red', lty = 1)
legend(0.5*max(res),0.6,c("for FLASE","for TRUE"), lwd=c(2,3), col=c("black","gray"), lty=c(1,2), y.intersp=1.5)
