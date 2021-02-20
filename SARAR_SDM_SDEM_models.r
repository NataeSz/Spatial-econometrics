rm(list = ls())

library(rgdal)
library(sp)
library(spdep)
# library(spatialEco)
# library(eurostat)

setwd("C:/Users/Natalia/Documents/Git/Spatial-econometrics")

load(file = "pd5.RData")
attach(spatial_data@data)

get_LR <- function(mod){
  lL0 <- logLik(model3a)
  lL1 <- logLik(mod)
  LRa <- 2 * (lL1 - lL0)
  return(pchisq(as.numeric(LRa), df = 2, lower.tail = FALSE)) 
}

#SARAR - ML and GS2SLS
model5a <- sacsarlm(values ~ Population + GDP + emp + Freq, listw = W_list)
summary(model5a)
res5a <- model5a$residuals
moran.test(res5a, listw = W_list)

model5b <- gstsls(values ~ Population + GDP + emp + Freq, listw = W_list)
summary(model5b)
res5b <- model5b$residuals
moran.test(res5b, listw = W_list)
LR.p.value5 <- get_LR(model5a)

#SDM
model6a <- lagsarlm(values ~ Population + GDP + emp + Freq, listw = W_list, type = "Durbin")
summary(model6a)
res6a <- model5a$residuals
moran.test(res6a, listw = W_list)

model6b <- lagsarlm(values ~ Population + GDP + emp + Freq + lag.Population + lag.GDP + lag.emp + lag.Freq, listw = W_list, tol.solve = 1e-17)
summary(model6b)
res6b <- model6b$residuals
moran.test(res6b, listw = W_list)
LR.p.value6 <- get_LR(model6b)

#SDEM
model7a <- errorsarlm(values ~ Population + GDP + emp + Freq + lag.Population + lag.GDP + lag.emp + lag.Freq, listw = W_list)
summary(model7a)
res7a <- model7a$residuals
moran.test(res7a, listw = W_list)

model7b <- errorsarlm(values ~ Population + GDP + emp + Freq, etype = "emixed", listw = W_list, tol.solve = 1e-17)
summary(model7b)
res7b <- model7b$residuals
moran.test(res7b, listw = W_list)
LR.p.value7 <- get_LR(model7b)

# TESTY LM
lm.LMtests(model1, listw = W_list, test = "all")

# AKAIKE AND LR TESTS
info <- matrix(c(AIC(model1), AIC(model2a), AIC(model3a),AIC(model4b), AIC(model5a), AIC(model6b),AIC(model7b),
                 NA,NA,NA, get_LR(model4b), NA, LR.p.value6,LR.p.value7)
                 ,ncol=7, nrow = 2,byrow=TRUE)
colnames(info) <- c("linear","SAR","SEM", "SLX","SARAR","SDM","SDEM") #  
rownames(info) <- c("AIC","LR_p")
as.table(info)

