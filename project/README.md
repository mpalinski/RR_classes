# Automated Reports on the quotes of some of the biggest tech companies

This project aim is to provide an R Markdown report, where user can knit with parameters to tailor the analysis to his/her needs. The report shoud be able to provide for the user some insight into the time series data, regardless of whether he/she possesses any programming or technical knowledge.

The report is able to generate a series of graphs and descriptive statistics for a time series based on user's input choice of:
- company
- time span
- which price to take into consideration

## Data

The data for this project is gathered via an existing R package [quantmod](https://cran.r-project.org/web/packages/quantmod/quantmod.pdf) function called 'getSymbols', which downloads quotes from the internet. This means that this project does not possess or load any data locally. Instead it downloads quotes for user-specified time period and user-specified company while knitting.

## Structure

The report is structured as follows...

## Functionalities

Current automated functionalities enable the user to choose a tech company (from a predetermined list) which quotes will be analyzed. It also enables to specify the time span of said quotations, as well as determining which price would be displayed (Open/Close/High/Low/Adjusted - multiple choice).