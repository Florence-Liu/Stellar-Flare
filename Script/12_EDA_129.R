#### Preamble ####
# Purpose: Conducting Exploratory Data Analysis on Light Curve data for TIC 129646813.

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
data_129 <- read.csv("../Output/Data/129646813_flux_only.csv")