#### Preamble ####
# Purpose: Conducting Exploratory Data Analysis on Light Curve data for TIC 0131799991.

#### Workspace setup ####

library(tidyverse)
library(ggplot2)
library(knitr)
library(kableExtra)
library(dplyr)
library(tidyr)
library(lubridate)
library(forecast)
library(ggfortify)
library(imputeTS)
library(zoo)

#### Download data ####
data_013 <- read.csv("../Output/Data/013179991_flux_only.csv")


