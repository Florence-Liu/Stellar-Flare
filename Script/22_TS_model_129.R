#### Preamble ####
# Purpose: Conducting Time Series Analysis and ARIMA model on Light Curve data 
# for TIC 129646813.

#### Workspace setup ####
library(tidyverse)
library(ggplot2)


#### Download data ####
data_129 <- read.csv("./Output/Data/129646813_flux_only.csv")
data_129 <- data_129 %>% arrange(time)

data_129_sim <- read.csv("./Output/Data/129646813_flux_sim.csv")
data_129_sim <- data_129_sim %>% arrange(time)

data_129_sim_ts <- ts(data_129_sim$pdcsap_flux_arma)
plot(data_129_sim_ts)
acf(data_129_sim_ts)
plot(diff(data_129_sim_ts))
acf(diff(data_129_sim_ts), lag.max = 500)
decomposed_stl <- stl(data_129_sim_ts)
decomposed_stl_plot <- autoplot(decomposed_stl)
print(decomposed_stl_plot)