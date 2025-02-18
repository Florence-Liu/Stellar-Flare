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
library(kableExtra)
library(knitr)

#### Download data ####
data_013 <- read.csv("./Output/Data/013179991_flux_only.csv")
data_013 <- data_013 %>% arrange(time)

#### Data summary ####
print(str(data_013))
print(summary(data_013))
print(colSums(is.na(data_013))) 
print(data_013[8343:8351, ])
kable(as.data.frame(data_013[8343:8351, ]))

#### Heatmap of  missing data ####
missing_df <- data_013 %>% mutate_all(~ifelse(is.na(.), 1, 0)) %>% 
  pivot_longer(everything())
ggplot(missing_df, aes(x = name, y = as.numeric(row.names(missing_df)),
                       fill = value)) +
  geom_tile() +
  labs(title=paste("Missing Data Heatmap -", "TIC 0131799991"),
       x="Variables", y="Rows") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

#### Time series analysis ####
### Plot time series ###
ggplot(data_013, aes(x = time, y = pdcsap_flux)) +
  geom_line() +
  labs(title=paste("Time Series Plot -", "TIC 0131799991"),
       x="Time", y="PDCSAP Flux") +
  theme_minimal()

data_013_drop_missing <- data_013 %>% drop_na(pdcsap_flux) %>% drop_na(time)

ggplot(data_013_drop_missing, aes(x = time, y = pdcsap_flux)) +
  geom_line() +
  labs(title=paste("Time Series Plot -", "TIC 0131799991"),
       x="Time", y="PDCSAP Flux") +
  theme_minimal()


### ACF and PACF ###
data_013_ts <- ts(data_013$pdcsap_flux, frequency = 150) 
data_013_ts_drop_missing <- ts(data_013_drop_missing$pdcsap_flux, frequency = 150) 
acf(data_013_ts_drop_missing, lag.max = 500, main = 
                  "Autocorrelation - TIC 0131799991")
acf(data_013_ts_drop_missing, lag.max = 50, main = 
                  "Autocorrelation - TIC 0131799991")
ts_first_diff <- ts(diff(data_013_ts_drop_missing))
acf(ts_first_diff, main = "Autocorrelation First Difference")
ts.plot(ts_first_diff, main = "Time Series Plot First Difference")
acf(data_013_ts_drop_missing, lag.max = 30, type = "partial", 
                 main = "Partial Autocorrelation - TIC 0131799991")

### Time Series Decomposition ###
# decomposed <- decompose(ts_data, type="multiplicative")
# decomposed_plot <- autoplot(decomposed)
# print(decomposed_plot)
decomposed_stl <- stl(data_013_ts_drop_missing, s.window="periodic")
decomposed_stl_plot <- autoplot(decomposed_stl)
print(decomposed_stl_plot)

### Handling missing data ###
## Simulate missing time ##
simulated_time <- seq(1529.069, 1535.000, length.out = 5930)
df_simulated <- data.frame(time = simulated_time)
data_013_sim <- merge(data_013, df_simulated, by = "time", all = TRUE)
data_013_sim <- data_013_sim %>% arrange(time)
data_013_sim_ts <- ts(data_013_sim$pdcsap_flux, frequency = 150)

## using imputeTS package ##
# ARIMA #
data_013_sim$pdcsap_flux_arma <- na_seasplit(data_013_sim_ts, algorithm="interpolation")
ggplot(data_013_sim, aes(x = time)) +
  geom_line(aes(y = pdcsap_flux_arma, color="ARIMA")) +
  geom_line(aes(y = pdcsap_flux, color="Original"), alpha=0.5) +
  labs(x = "Time", y = "PDCSAP Flux") +
  theme_minimal() +
  scale_color_manual(values=c("goldenrod", "black"))

# auto.arima #
data_013_sim$pdcsap_flux_kalman <- na_kalman(data_013_sim_ts, model = "auto.arima")
ggplot(data_013_sim, aes(x = time)) +
  geom_line(aes(y = pdcsap_flux_kalman, color="ARIMA")) +
  geom_line(aes(y = pdcsap_flux, color="Original"), alpha=0.5) +
  labs(x = "Time", y = "PDCSAP Flux") +
  theme_minimal() +
  scale_color_manual(values=c("darkgreen", "black"))

# Rolling window mean #
data_013_sim$pdcsap_flux_rollmean <- rollapply(data_013_sim_ts, width=5, FUN=mean,
                                           fill=NA, align="right")
ggplot(data_013_sim, aes(x = time)) +
  geom_line(aes(y = pdcsap_flux_rollmean, color="RWM")) +
  geom_line(aes(y = pdcsap_flux, color="Original"), alpha=0.5) +
  labs(x = "Time", y = "PDCSAP Flux") +
  theme_minimal() +
  scale_color_manual(values=c("darkred", "black"))

## Exponential weighted moving average ##
data_013_sim$pdcsap_flux_ma <- na_ma(data_013_sim_ts, k=5, weighting="exponential")
ggplot(data_013_sim, aes(x = time)) +
  geom_line(aes(y = pdcsap_flux_ma, color="EWMA")) +
  geom_line(aes(y = pdcsap_flux, color="Original"), alpha=0.5) +
  labs(x = "Time", y = "PDCSAP Flux") +
  theme_minimal() +
  scale_color_manual(values=c("darkblue", "black"))

## Forecast based on pre-gap data ##
train_data <- data_013_sim$pdcsap_flux[1:8345] %>% na.omit()
ts_model <- Arima(train_data, order = c(5, 1, 2), seasonal = c(1, 0, 0))
n_forecast <- 5930
forecast_values <- forecast(ts_model, h = n_forecast)
data_013_sim$pdcsap_flux[8346:14275] <- forecast_values$mean
observed_indices <- 1:8345
forecasted_indices <- 8346:14275
data_013_sim$category <- ifelse(1:nrow(data_013_sim) %in% forecasted_indices, 
                               "forecasted", "observed")
data_013_sim$category <- as.factor(data_013_sim$category)

ggplot(data_013_sim, aes(x = time, y =as.numeric(pdcsap_flux), color = category)) +
  geom_line(alpha = 0.5) +
  ggtitle("Forecasted Values for Missing Period") +
  labs(x = "Time", y = "PDCSAP Flux") +
  scale_color_manual(values = c("observed" = "black", "forecasted" = "red")) +
  theme_minimal()

