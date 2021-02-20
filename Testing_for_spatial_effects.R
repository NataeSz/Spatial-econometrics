#SET WORKING DIRECTORY
setwd("C:/Users/Natalia/Documents/Git/Spatial-econometrics")
rm(list = ls())

library(rgdal)
library(sp)
library(spdep)

source('Cmn_vars.r')


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
