setwd("C:/Users/Natalia/Documents/Git/Spatial-econometrics")

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
