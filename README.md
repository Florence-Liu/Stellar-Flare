# Stellar Flare Detection: Comparing Different Unsupervised Learning Methods and Time Series Models

## Overview

Stellar flares are sudden, intense bursts of radiation caused by magnetic reconnection events in the stellar atmosphere. Detecting these transient events using light curve data is crucial for understanding stellar activity. In this project, we analyze the light curve of **TIC 129646813**, a star observed by the TESS mission, and develop a pipeline for flare detection using:

- **ARIMA** models for residual-based detection  
- **DBSCAN** for density-based outlier clustering  
- **Isolation Forest** for tree-based anomaly scoring

The methods are evaluated on both real and simulated data to assess their sensitivity and robustness in identifying flare-like anomalies.


## File Structure

The repo is structured as:

-   `Inputs` contains all original datasets and relevant documents.
    - `Data` contains raw lightcurve data from TESS.
    - `Document` contains data description, project introduction and literatures.
-   `Scripts` contains R and Jupyter notebook scripts used to clean the data and fit models.
-   `Outputs` contains all outputs including final model, paper, and cleaned data.
    -   `Assignment` contains files and figures used to generate proposal, EDA, progress report, and final report.
    -   `Data` contains cleaned data after handling missing values and used to fit models.
    -   `Model` contains models for different methods.
