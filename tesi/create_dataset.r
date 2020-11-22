# loading packages
library(rstanarm)
library(ggplot2)
library(bayesplot)
library(tidyverse)
library(lme4)
library(arm)
library(loo)
library(kableExtra)

library(plyr)
library(dplyr)
library(data.table)

# daily data
regioni <- read.csv("https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv")
regioni[ ,c("lat","long","note","codice_regione","stato")] <- list(NULL) 
regioni$"denominazione_regione" <- mapvalues(regioni$"denominazione_regione", from=c("P.A. Bolzano"),to=c("P.A. Trento")) 
regioni=setDT(regioni)[, lapply(.SD, sum), by = .(denominazione_regione,data)] 
regioni$"denominazione_regione" <- mapvalues(regioni$"denominazione_regione", from=c("P.A. Trento"),to=c("Trentino")) 

head(regioni) 
temp <- tempfile()
download.file("https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip",temp)
movement_google <- read.csv(unz(temp, "2020_IT_Region_Mobility_Report.csv")) 
colnames(regioni)[which(names(regioni) == "denominazione_regione")] <-  "sub_region_1"
movement_google<-movement_google[ which(movement_google$"sub_region_2"==''),]
movement_google<-movement_google[ which(movement_google$"sub_region_1"!=''),]
colnames(movement_google)[which(names(movement_google) == "date")] <- "data" 
regioni$data=sub('.........{1}$', '', regioni$data)  
movement_google$"sub_region_1" <- mapvalues(movement_google$"sub_region_1", from=c("Aosta","Apulia","Lombardy","Tuscany","Piedmont","Sardinia","Sicily","Trentino-South Tyrol","Friuli-Venezia Giulia"), to=c("Valle d'Aosta","Puglia","Lombardia","Toscana","Piemonte","Sardegna","Sicilia","Trentino","Friuli Venezia Giulia"))
df <- merge(regioni,movement_google, by=c("data","sub_region_1"), all=TRUE)
df[ ,c("country_region_code","country_region","sub_region_2","metro_area","iso_3166_2_code", "census_fips_code")] <- list(NULL)

#Facebook Movement Range Maps
#Columns
#ds: Date stamp for movement range data row in YYYY-MM-DD form
#country: Three-character ISO-3166 country code
#polygon_source: Source of region polygon, either â€œFIPSâ€ for U.S. data or â€œGADMâ€ for global data
#polygon_id: Unique identifier for region polygon, either numeric string for U.S. FIPS codes or alphanumeric string for GADM regions
#polygon_name: Region name
#all_day_bing_tiles_visited_relative_change: Positive or negative change in movement relative to baseline
#all_day_ratio_single_tile_users: Positive proportion of users staying put within a single location
#baseline_name: When baseline movement was calculated pre-COVID-19
#baseline_type: How baseline movement was calculated pre-COVID-19
my_data <- read.delim("/home/f/Downloads/movement-range-data-2020-11-14/a.txt")
newdata <- my_data[ which(my_data$country=='ITA'),]
colnames(newdata)[which(names(newdata) == "polygon_name")] <-  "sub_region_1"
colnames(newdata)[which(names(newdata) == "ds")] <-  "data"
newdata$"sub_region_1" <- mapvalues(newdata$"sub_region_1", from=c("Sicily","Friuli-Venezia Giulia","Trentino-Alto Adige","Apulia" ), to=c("Sicilia","Friuli Venezia Giulia","Trentino","Puglia"))
df <- merge(df,newdata, by=c("data","sub_region_1"), all=TRUE)
df[ ,c("country","polygon_source","polygon_id","baseline_name","baseline_type")] <- list(NULL) 
colnames(df)[which(names(df) =="sub_region_1" )] <-  "denominazione_regione"
write.csv(df,'/home/f/tesi/df_it_reg.csv' )

