#### Preamble ####
# This script analyzes TESS light curve data for star TIC 129646813 to detect potential
# stellar flares using ARIMA modeling. The process includes:
#
# 1. Exploratory Data Analysis (EDA) and visualization of missing values.
# 2. Time series construction, transformation (differencing), and decomposition.
# 3. Stationarity checks using ADF tests.
# 4. ARIMA model fitting and residual diagnostics.
# 5. Anomaly detection from residuals based on a 3-sigma rule.
# 6. Temporal clustering of nearby anomalies to identify likely flare events.
# 7. Visualization of detected flare candidates.
#

#### Workspace setup ####
library(tidyverse)
library(ggplot2)
library(forecast)
library(tseries)
library(portes)

#### Download data ####
data_129 <- read.csv("./Output/Data/129646813_flux_only.csv")
data_129 <- data_129 %>% arrange(time)

#### EDA ####
sum(is.na(data_129$pdcsap_flux))
print(data_129[9410:9415, ])
missing_df <- data_129 %>% mutate_all(~ifelse(is.na(.), 1, 0)) %>% 
  pivot_longer(everything())
ggplot(missing_df, aes(x = name, y = as.numeric(row.names(missing_df)),
                       fill = value)) +
  geom_tile() +
  labs(title=paste("Missing Data Heatmap -", "TIC 129646813"),
       x="Variables", y="Rows") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

data_129 <- drop_na(data_129) # drop missing values
data_129_ts <- ts(data_129$pdcsap_flux, frequency = 1000)
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
# STL decomposition to extract seasonal, trend, and remainder components
decomposed_stl <- stl(data_129_ts, s.window = "periodic")
decomposed_stl_plot <- autoplot(decomposed_stl)
print(decomposed_stl_plot)

# STL on differenced series
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

arima_model <- readRDS("./Output/Model/ARIMA_model.rds")

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
anomalies <- which(arima_res > threshold_upper)

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

### Cluster anomalies ###
# Define time threshold for clustering consecutive anomalies
time_threshold <- 0.02
anomaly_times <- bjd_times_residuals[anomalies]

# Initialize cluster
clustered_anomalies <- c()
current_cluster <- anomaly_times[1]

# Loop through anomalies to cluster nearby points
for (i in 2:length(anomaly_times)) {
  if (anomaly_times[i] - anomaly_times[i - 1] <= time_threshold) {
    current_cluster <- c(current_cluster, anomaly_times[i])
  } else {
    # Retain the anomaly with the maximum residual in the cluster
    cluster_indices <- which(bjd_times_residuals %in% current_cluster)
    max_res_index <- cluster_indices[which.max(arima_res[cluster_indices])]
    clustered_anomalies <- c(clustered_anomalies, bjd_times_residuals[max_res_index])
    current_cluster <- anomaly_times[i]
  }
}

# Add the last cluster if not empty
if (length(current_cluster) > 0) {
  cluster_indices <- which(bjd_times_residuals %in% current_cluster)
  max_res_index <- cluster_indices[which.max(arima_res[cluster_indices])]
  clustered_anomalies <- c(clustered_anomalies, bjd_times_residuals[max_res_index])
}

# Plot the final result
plot(bjd_times_residuals, arima_res,
     main = "Detected Anomalies in ARIMA Residuals",
     ylab = "Residuals", xlab = "Time", type = "l")
points(clustered_anomalies, arima_res[bjd_times_residuals %in% clustered_anomalies],
       col = "red", pch = 19, cex = 0.5)
abline(h = threshold_upper, col = "blue", lty = 2)

#### Save model ####
# saveRDS(arima_model, "./Output/Model/ARIMA_model.rds")
