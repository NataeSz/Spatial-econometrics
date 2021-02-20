rm(list = ls())
setwd("C:/Users/Natalia/Documents/Git/Spatial-econometrics")

library(rgdal)
library(sp)
library(spdep)
library(spatialEco)


source("Cmn_vars.r")

coordinates(dane) <- ~lon + lat
proj4string(dane) <- mapa@proj4string
# proj4string(dane) <- getCRS(mapa) ###############
dane$reg <- over(dane, mapa)$NUTS_ID_char # Assigning informafion about the region to each university

# Number of universities in each region
df <- merge(df, as.data.frame(table(dane@data$reg)), by.x= 'geo', by.y='Var1')
rm(dane)
df$uni_pc <- df$Freq / df$Population *1000000 # Number of universities per 100 000 inhabitants

spatial_data <- merge(y = df, x = mapa, by.y = "geo", by.x = "NUTS_ID")
rm(df)

#Visualise the number of universities in each region
blue_area <- rgb(0, 123, 255, 90, names = NULL, maxColorValue = 255)
pal <- colorRampPalette(c("white", blue_area), bias = 1)
spplot(spatial_data, zcol = "Freq", colorkey = TRUE, col.regions = pal(100), cuts = 99, cex = 0.5,
       par.settings = list(axis.line = list(col =  'transparent')),
       main = "Number of universities in each region")

#Visualise the number of universities in each region per 100 000 inhabitants
spplot(spatial_data, zcol = "uni_pc", colorkey = TRUE, col.regions = pal(100), cuts = 99, cex = 0.5,
       par.settings = list(axis.line = list(col =  'transparent')),
       main = "Number of universities\nper 100 000 inhabitants")

attach(spatial_data@data)
cont <- poly2nb(spatial_data, queen = T)
W_list <- nb2listw(cont, style = "W")

model1 <- lm(values ~ Population + GDP + emp + Freq)
summary(model1)
lm.morantest(model1, listw = W_list)
lm.LMtests(model1, listw = W_list, test = "all")


spatial_data@data$residuals = predict(model1, spatial_data@data[,c('Population','GDP', 'emp', 'Freq')])
spplot(spatial_data, zcol = "residuals", colorkey = TRUE, col.regions = pal(100), cuts = 99, cex = 0.5,
       par.settings = list(axis.line = list(col =  'transparent')),
       main = "Residuals of the linear model")

#SAR: Spatial Lag - ML and TSLS
model2a <- lagsarlm(values ~ Population + GDP + emp + Freq, listw = W_list, tol.solve = 1e-16)
summary(model2a)
res2a <- model2a$residuals
moran.test(res2a, listw = W_list)
#Tests for rho (LR and Wald) can be computed individually:
LR1.sarlm(model2a)
Wald1.sarlm(model2a)

spatial_data@data$residuals = res2a
spplot(spatial_data, zcol = "residuals", colorkey = TRUE, col.regions = pal(100), cuts = 99, cex = 0.5,
       par.settings = list(axis.line = list(col =  'transparent')),
       main = "Residuals of the SAR model")

  # cor(as.matrix(spatial_data@data[,c('Population', 'GDP', 'emp','Freq', 'uni_pc')]))

model2b <- stsls(values ~ Population + GDP + emp + Freq, listw = W_list)
summary(model2b)
res2b <- model2b$residuals
moran.test(res2b, listw = W_list)
lm.LMtests(res2b, listw = W_list, test = "LMerr")


#SEM: Spatial Error - ML and GLS
model3a <- errorsarlm(values ~ Population + GDP + emp + Freq, listw = W_list, tol.solve = 1e-16)
summary(model3a)
res3a <- model3a$residuals
moran.test(res3a, listw = W_list)

model3b <- GMerrorsar(values ~ Population + GDP + emp + Freq, listw = W_list)
summary(model3b)

spatial_data@data$residuals = res3a
spplot(spatial_data, zcol = "residuals", colorkey = TRUE, col.regions = pal(100), cuts = 99, cex = 0.5,
       par.settings = list(axis.line = list(col =  'transparent')),
       main = "Residuals of the SEM model")


#SLX
W <- listw2mat(W_list)
X <- cbind(Population, GDP, emp, Freq)
WX <- W %*% X
lag.Population <- WX [, 1]
lag.GDP <- WX [, 2]
lag.emp <- WX [, 3]
lag.Freq <- WX [, 4]

model4a <- lm(values ~ Population + GDP + emp + Freq + lag.Population + lag.GDP + lag.emp + lag.Freq)
summary(model4a)
lm.morantest(model4a, listw = W_list)
lm.LMtests(model4a, listw = W_list, test = "all")


spatial_data@data$residuals = predict(model4a, data.frame(cbind(Population, GDP, emp, Freq, lag.Population, lag.GDP, lag.emp, lag.Freq)))
spplot(spatial_data, zcol = "residuals", colorkey = TRUE, col.regions = pal(100), cuts = 99, cex = 0.5,
       par.settings = list(axis.line = list(col =  'transparent')),
       main = "Residuals of the SLX model")

model4b <- lmSLX(values ~ Population + GDP + emp + Freq, listw = W_list)
summary(model4b)
lm.morantest(model4b, listw = W_list)
lm.LMtests(model4b, listw = W_list, test = "all")

save.image(file = "pd5.RData")
