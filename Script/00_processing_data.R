#### Preamble ####
# Purpose: Downloading TESS datasets for three stars (TIC 0131799991, TIC 0311381302,
# and TIC 129646813); Processing data.


#### Workspace setup ####
library(tidyverse)


#### Download data ####
data_013 <- read.csv("./Input/Data/0131799991.csv")
data_129 <- read.csv("./Input/Data/129646813.csv")
data_031 <- read.csv("./Input/Data/031381302.csv")
summary(data_013);summary(data_129);summary(data_031)


#### Process data ####
# Select variable of interest
data013_flux <- data_013 |> select(time, pdcsap_flux)
data129_flux <- data_129 |> select(time, pdcsap_flux)
data031_flux <- data_031 |> select(time, pdcsap_flux)
summary(data013_flux);summary(data129_flux);summary(data031_flux)


#### Save cleaned data #### 
# write.csv(data013_flux, "./Output/Data/013179991_flux_only.csv", row.names = F)
# write.csv(data129_flux, "./Output/Data/129646813_flux_only.csv", row.names = F)
# write.csv(data031_flux, "./Output/Data/031381302_flux_only.csv", row.names = F)
