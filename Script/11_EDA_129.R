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
data_129 <- read.csv("./Output/Data/129646813_flux_only.csv")
data_129 <- data_129 %>% arrange(time)

#### Data summary ####
print(str(data_129))
print(summary(data_129))
print(colSums(is.na(data_129))) 
print(data_129[9410:9415, ])

#### Heatmap of missing data ####
missing_df <- data_129 %>% mutate_all(~ifelse(is.na(.), 1, 0)) %>% 
  pivot_longer(everything())
ggplot(missing_df, aes(x = name, y = as.numeric(row.names(missing_df)),
                       fill = value)) +
  geom_tile() +
  labs(title=paste("Missing Data Heatmap -", "TIC 129646813"),
       x="Variables", y="Rows") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

#### Time series analysis ####
### Plot time series ###
ggplot(data_129, aes(x = time, y = pdcsap_flux)) +
  geom_line() +
  labs(title=paste("Time Series Plot -", "TIC 129646813"),
       x="Time", y="PDCSAP Flux") +
  theme_minimal()

data_129_drop_missing <- data_129 %>% drop_na(pdcsap_flux) %>% drop_na(time)

ggplot(data_129_drop_missing, aes(x = time, y = pdcsap_flux)) +
  geom_line() +
  labs(title=paste("Time Series Plot -", "TIC 129646813"),
       x="Time", y="PDCSAP Flux") +
  theme_minimal()


### ACF and PACF ###
data_129_ts <- ts(data_129$pdcsap_flux, frequency = 1000) 
data_129_ts_drop_missing <- ts(data_129_drop_missing$pdcsap_flux, frequency = 1000) 
acf(data_129_ts_drop_missing, lag.max = 500, main = 
      "Autocorrelation - TIC 129646813")
acf(data_129_ts_drop_missing, lag.max = 50, main = 
      "Autocorrelation - TIC 129646813")
ts_first_diff <- ts(diff(data_129_ts_drop_missing))
acf(ts_first_diff, main = "Autocorrelation First Difference")
ts.plot(ts_first_diff, main = "Time Series Plot First Difference")
acf(data_129_ts_drop_missing, lag.max = 30, type = "partial", 
    main = "Partial Autocorrelation - TIC 129646813")
acf(ts_first_diff, type = "partial", main = "Autocorrelation First Difference")


### Time Series Decomposition ###
# decomposed <- decompose(ts_data, type="multiplicative")
# decomposed_plot <- autoplot(decomposed)
# print(decomposed_plot)
decomposed_stl <- stl(data_129_ts_drop_missing, s.window="periodic")
decomposed_stl_plot <- autoplot(decomposed_stl)
print(decomposed_stl_plot)

### Handling missing data ###
## Simulate missing time ##
simulated_time <- seq(1338.527, 1339.660, by=0.001)
df_simulated <- data.frame(time = simulated_time)
data_129_sim <- merge(data_129, df_simulated, by = "time", all = TRUE)
data_129_sim <- data_129_sim %>% arrange(time)
data_129_sim_ts <- ts(data_129_sim$pdcsap_flux, frequency = 1000)

## using imputeTS package ##
# ARIMA #
data_129_sim$pdcsap_flux_arma <- na_seasplit(data_129_sim_ts, algorithm="interpolation")
ggplot(data_129_sim, aes(x = time)) +
  geom_line(aes(y = pdcsap_flux_arma, color="ARIMA")) +
  geom_line(aes(y = pdcsap_flux, color="Original"), alpha=0.5) +
  labs(x = "Time", y = "PDCSAP Flux") +
  theme_minimal() +
  scale_color_manual(values=c("goldenrod", "black"))

#### Save cleaned data #### 
# write.csv(data_129_sim, "./Output/Data/129646813_flux_sim.csv", row.names = F)
