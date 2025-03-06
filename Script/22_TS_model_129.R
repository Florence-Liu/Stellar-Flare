#### Preamble ####
# Purpose: Conducting Time Series Analysis and ARIMA model on Light Curve data 
# for TIC 129646813.

#### Workspace setup ####
library(tidyverse)
library(ggplot2)
library(forecast)
library(tseries)
library(portes)

#### Download data ####
data_129 <- read.csv("./Output/Data/129646813_flux_sim.csv")
data_129 <- data_129 %>% arrange(time)

#### EDA ####
data_129_ts <- ts(data_129$pdcsap_flux_arma, frequency = 1000)
plot(data_129_ts)
acf(data_129_ts)
acf(data_129_ts, type = "partial")

### First order differentiation ###
ndiffs(data_129_ts)
data_129_ts_diff <- diff(data_129_ts)
plot(data_129_ts_diff)
acf(data_129_ts_diff)
acf(data_129_ts_diff, type = "partial")

### Decomposition ###
decomposed_stl <- stl(data_129_ts, s.window = "periodic")
decomposed_stl_plot <- autoplot(decomposed_stl)
print(decomposed_stl_plot)

decomposed_stl <- stl(data_129_ts_diff, s.window = "periodic")
decomposed_stl_plot <- autoplot(decomposed_stl)
print(decomposed_stl_plot)

### Check stationary ###
adf.test(data_129_ts)
adf.test(data_129_ts_diff)

#### ARIMA model ####
### Fit model ###
arima_model <- auto.arima(data_129_ts, seasonal = FALSE, stepwise = FALSE, 
                          approximation = FALSE)
summary(arima_model)

### Diagnostic ###
## Portmanteau test ##
arima_res <- residuals(arima_model)
Box.test(arima_res, lag = 1, type = "Ljung-Box")
Box.test(arima_res, lag = 20, type = "Ljung-Box")

## Residual ##
checkresiduals(arima_model)

## Detect anomalies with threshold (3 standard deviations) ##
res_mean <- mean(arima_res) 
res_sd <- sd(arima_res)
threshold_upper <- res_mean + 3 * res_sd
threshold_lower <- res_mean - 3 * res_sd
anomalies <- which(arima_res > threshold_upper | arima_res < threshold_lower)

# Change to original time scale due to differentiation
BJD_times <- data_129$time
bjd_times_residuals <- BJD_times[(length(BJD_times) - 
                                    length(arima_res) + 1):length(BJD_times)]
plot(bjd_times_residuals, arima_res, 
     main = "Detected Anomalies in ARIMA Residuals",
     ylab = "Residuals", xlab = "Time", type = "l")
points(bjd_times_residuals[anomalies], arima_res[anomalies], 
       col = "red", pch = 19, cex = 0.5)
abline(h = c(threshold_upper, threshold_lower), col = "blue", lty = 2)

#### Save model ####
# saveRDS(arima_model, "./Output/Model/ARIMA_model.rds")
