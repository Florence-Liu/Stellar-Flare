setwd("/Users/florenceliu/Downloads/uoft/MSc/2025 winter/sta2453/stellar flare")
data_013 <- read.csv("0131799991.csv")
data_129 <- read.csv("129646813.csv")
data_031 <- read.csv("031381302.csv")
summary(data_013);summary(data_129);summary(data_031)
library(tidyverse)
data013_flux <- data_013 |> select(time, pdcsap_flux)
data129_flux <- data_129 |> select(time, pdcsap_flux)
data031_flux <- data_031 |> select(time, pdcsap_flux)
summary(data013_flux);summary(data129_flux);summary(data031_flux)

plot(data013_flux$time, data013_flux$pdcsap_flux, type = "l", col = "forestgreen",
     xlab = "Time", ylab = "Flux", main = "TIC 0131799991")
plot(data129_flux$time, data129_flux$pdcsap_flux, type = "l", col = "goldenrod1",
     xlab = "Time", ylab = "Flux", main = "TIC 129646813")
plot(data031_flux$time, data031_flux$pdcsap_flux, type = "l", col = "lightsteelblue2",
     xlab = "Time", ylab = "Flux", main = "TIC 031381302")
