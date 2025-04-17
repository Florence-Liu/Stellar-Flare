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


## Methods Summary

- **ARIMA(4,1,1)** model is fitted to the light curve using `auto.arima` from the R `forecast` package. Anomalies are identified based on 3-sigma residual thresholds and clustered using a time proximity threshold.
- **DBSCAN** is applied using `sklearn.cluster` with tuned `eps` and `min_samples` parameters. Flux outliers above the median are clustered into flare events.
- **Isolation Forest** is implemented using `sklearn.ensemble` with contamination parameter selected via visualization.


##  Requirements

- Python ≥ 3.8  
  - `numpy`, `pandas`, `matplotlib`, `scikit-learn`
- R ≥ 4.0  
  - `forecast`, `ggplot2`, `tseries`

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/Florence-Liu/Stellar-Flare.git
   cd Stellar-Flare
   
2. For time series analysis:
   Run `Script/Arima_model.R` in RStudio

3. For ML-based detection:
   Open and execute `Scripts/DBSCAN.ipynb` and `Scripts/IF.ipynb`

4. Simulated studies:
   Open and execute `Script/Simulation.ipynb`

5. Final Report:
   Run `Output/Assignment/Final Report.Rmd`

## Acknowledgements
This project was completed as part of STA2453:  Data Science Methods, Collaboration, and Communication, Winter 2025 at the University of Toronto.
I would like to sincerely thank Professor Vianey Leos-Barajas for her invaluable guidance throughout the course, as well as my collaborator Arturo for his thoughtful feedback and support during the project.
