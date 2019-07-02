## Author
This project was made by Wojciech Brąszkiewicz. \
Feel free to contact me at wojciechbraszkiewicz96@gmail.com

# Analysis on Facebook revenue on ads.
## Goals
* Analysis of Facebook revenue on ads.
* Forecasting FB revenue in 2018.

## Technical background
This project was made in [R](https://www.r-project.org/) statistical programming langauge in [R Studio](https://www.rstudio.com/) enviroment. \
Should you desire to make changes, follow step by step or look closer to the code you will have to download both of these. Code is open source, so please feel free to use it in your projects.

## Facebook
- Facebook, as of time of writing, is the biggest social platform out there. 
- In Q1 of 2019 Facebook reported that it has over 2.38 billion active users. And it keeps on growing. (source: statistica.com)
- Facebook is not only providing entertainment but also business tools such as Business Facebook, a tool that manages company sites on Facebook.
- Main source of revenue are ads, which have provided $55b in 2018 (statistica.com).

![alt text](https://i.imgur.com/QJ6Wv4f.png "FB Users growth")
Source: statistica.com

## Dataset
Data was downloaded from [www.investor.fb.com](www. investor.fb.com).\
Data contains values of quarterly revenue on ads from Q1 2013 to Q4 2017.\
We will also use historical data from 2018 to compare our predictions.

| Date | Revenue [$b] |
| ---- | ------------ |
| 31.03.2013 |	1.245 |
| 30.06.2013 |	1.599 |
| 30.09.2013 |	1.798 |
| 31.12.2013 |	2.344 |
| .... |	.... |
| 31.03.2017 |	7.857 |
| 30.06.2017 |	9.164 |
| 30.09.2017 |	10.142 |
| 31.12.2017 |	12.779 |

# Coding
As always, lets start with installing/importing all of the libraries we are going to be using:\
```r
install.packages(ggplot2)
install.packages(forecast)
install.packages(tseries)
install.packages(readr)
install.packages(readx1)
install.packages(plotly)


library(ggplot2)
library(forecast)
library(tseries)
library(readr)
library(readxl)
library(plotly)
```

Let's start with importing our dataset to our project enviorment:

```r
fb <- read_excel("fb_dane.xlsx", col_types = c("date", "numeric"))
fb$Date = as.Date(fb$Date, format = "%d/%m/%Y") 
```
We should make sure that our variables are in fact in date and numeric format:

```r
str(fb)
## 2 variables:
## $ Date : Date, format: "2013-03-31" "2013-06-30" "2013-09-30" "2013-12-31" ...
## $ Sales: num  1.25 1.6 1.8 2.34 2.27 ...
```

Let's create a simple plot to help us understand what we are dealing with. I'm using `plotly` to create interactive graphs, however you can't upload them on Github yet. Below is a PNG version of this graph. Should you desire to see the full, interactive graph, click **[here](https://plot.ly/~wbraszkiewicz96/3/#plot)**.



![alt text](https://i.imgur.com/sfmXzrP.png "FB Reve 1")

What can we deduce from this graph?
* We can clearly see an upward trend.
* We can see seasonality.

While there's no doubt in first point, the second one might be unclear. To understand seasonality on Facebook we must realize that users are more likely to come back to Facebook to post pictures from holidays, vacation, travels. This is why we can see a big drop of activity in the first quarter of each year and then it grows right back when summer comes. Fall and winter comes with lots of family gathetring which are also a great opportunity to take and post pictures with your realtives.

## Forecasting methods used.
* **[ARIMA Model](https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average)**
* **[Triple exponential smoothing](https://en.wikipedia.org/wiki/Exponential_smoothing#Triple_exponential_smoothing)**

## ARIMA Model

### Step 1: Decomposition
The building blocks of a time series analysis are seasonality, trend, and cycle.\
Not every time series will have all 3 of them (or any). The process of extracting these components is referred to as **decomposition.**
ARIMA models can be fitted to both seasonal and non-seasonal data. Seasonal ARIMA requires a more complicated specification of the model structure, although the process of determining (P, D, Q) is similar to that of choosing non-seasonal order parameters. Therefore, we will explore how to de-seasonalize the series and use a "vanilla" non-seasonal ARIMA model.


For that, we will use `stl()` function:
```r
sales_ma = ts(na.omit(fb$Sales), frequency=4)
decomp = stl(sales_ma, s.window="periodic")
deseasonal_cnt <- seasadj(decomp)
plot(decomp)
```
Outcome of the above is a graph showing all three building blocks and, additionaly - reminder.
![alt text](https://i.imgur.com/Dl32bGd.png "Decomp 1")

### Step 2: Stationarity
Fitting an ARIMA model requires the series to be stationary. A series is said to be stationary when its mean, variance, and autocovariance are time invariant. 
To check if our time series is stationary we will use `adf.test()` function.

```r
adf.test(sales_ma, alternative = "stationary")

##p-value greater than printed p-value
##	Augmented Dickey-Fuller Test

##data:  sales_ma
##Dickey-Fuller = 0.58233, Lag order = 2, p-value = 0.99
##alternative hypothesis: stationary
```
Therefore, **our series IS NOT stationary**. We will deal with this problem in the next step.

### Step 3: Autocorrelations and Choosing Model Order
ACF plots display correlation between a series and its lags. In addition to suggesting the order of differencing, ACF plots can help in determining the order of the M A (q) model.
R plots 95% significance boundaries as blue dotted lines. There are significant autocorrelations in our series, as shown on graphs below:

![alt text](https://i.imgur.com/selRPY3.png "ACF1")

![alt text](https://i.imgur.com/kE90U09.png "PACF1")

As mentioned above, we can use ACF plot to tell us the order of differencing. Lets use this and start in d = 1:

```r
count_d1 = diff(deseasonal_cnt, differences = 1)
plot(count_d1)
```

![alt text](https://i.imgur.com/EhRGRxF.png "Plot d1")

As you can see on this plot, mean and variance seems to be stable in time. We can not be sure only by looking at the graph. Lets perform another ADF test:

```r
adf.test(count_d1, alternative = "stationary")

##p-value smaller than printed p-value
##	Augmented Dickey-Fuller Test
##data:  count_d1
##Dickey-Fuller = -4.5417, Lag order = 2, p-value = 0.01
## alternative hypothesis: stationary
```

Low p-value means that our time series needed only one differenciarting, as it is now **stationary**. 
Below are new ACF and PACF plots. We can compare them now and see on our own eyes results of differenciating.

![alt text](https://i.imgur.com/oJitDjT.png "ACF2")

![alt text](https://i.imgur.com/B66V3xD.png"PACF2")



### Step 4: Fitting an ARIMA model
The `forecast` package allows the user to explicitly specify the order of the model using the `arima()` function, or automatically generate a set of optimal (p, d, q) using `auto.arima()`. This function searches through combinations of order parameters and picks the set that optimizes model fit criteria.







