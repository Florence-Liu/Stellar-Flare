#### Preamble ####
# Purpose: Conducting Time Series Analysis and ARIMA model on Light Curve data 
# for TIC 129646813.

#### Workspace setup ####
library(tidyverse)
library(ggplot2)


#### Download data ####
data_129 <- read.csv("./Output/Data/129646813_flux_only.csv")
data_129 <- data_129 %>% arrange(time)