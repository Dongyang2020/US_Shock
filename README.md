# US_Shock

This repository contains the core codes used by Wei et al. (2023).

## RandomForest.ipynb 
Python code for pre-processing the data (detrending and standardizing) and conducting the random forest analysis.

## Shock_Decomp.R

Function to decompose production shocks in time series

A decomposition method is used to measure the contribution of each component to the magnitude of production shocks. Decomposition follows the index decomposition analysis (IDA) to express the overall change in an aggregate quantity as a sum of contributions from each of its components. The production of each county i is the product of planted area (A), harvestable fraction (F), and yield (Y). This method converts the difference of national production between two consecutive years into the sum of contributions from each component, by calculating the logarithmic mean Divisia Index.
