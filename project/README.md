# Automated Reports on the time series from Yahoo Finance

This project aim is to provide an R Markdown report, where user can knit with parameters to tailor the analysis to his/her needs. The report shoud be able to provide for the user some insight into the time series data, regardless of whether he/she possesses any programming or technical knowledge. The **project.rmd** file should be knitted with parameters, otherwise default values will load and the automation aspect will be lost.

The report is able to generate a series of graphs, descriptive statistics and other features for a time series based on user's input choice of:
- company
- time span
- which prices to take into consideration
- forecast duration in days

## Data

The data for this project is gathered via an existing R package [quantmod](https://cran.r-project.org/web/packages/quantmod/quantmod.pdf) function called 'getSymbols', which downloads quotes from the Yahoo Finance website. This means that this project does not possess or load any data locally. Instead it downloads quotes for user-specified time period and user-specified company while knitting. 

The project enables user to choose from a pre-set list of companies, however should one want to submit different company to analysis, then a few simple additions to the **project.rmd** file will do the trick. Steps:
1. In the YAML go to params: Company: choices -> and simply add the name of the company you want to analyze (e.g. Microsoft Corporation)
2. Go to `dict` chunk and add abbreviated company name from Yahoo Finance (e.g. MSFT for Microsoft Corporation)
3. In the vector below add the same name you used in point 1. on the corresponding position where you put abbreviated name (e.g. added MSFT as second in *dict*, then add Microsoft Corporation *names(dict)* also in second place)

## Structure

First chapter is basic introduction to the project and its purpose. Next chapter shows a glimpse of the data downloaded based on the user input and displays chosen parameters for the user, should he/she have forgotten, misclicked or wanted to double check. Next on the report shows some descriptive statistics - both for the raw data, as well as some for the log returns; interactive plots (one for price/prices, another for volume if chosen) - basically the EDA part of the project. Then we can see the stationarity tests (ADF) including trend, drift or none, depending on what kind we are interested in. The project finds the order of integration through a loop, and tells us of which order the series is integrated. 

**Important note**: the stationarity test is performed for the **first** price specified in *Which prices should be included?*

Lastly a forecast is made for the user-specified number of days using ... 

## Functionalities

Current automated functionalities enable the user to choose a company (from a predetermined list) whose quotes will be analyzed. It also enables to specify the time span of said quotations, as well as determining which price would be displayed (Open/Close/High/Low/Adjusted - multiple choice). Volume could also be chosen during user input, however due to being (usually) on a much bigger scale than quotes, it will be either omitted in some chapters, or on the contrary, will have its own plot in order not to dominate the scale. Forecast is done for the user-specified number of days following the last day available in the dataset.