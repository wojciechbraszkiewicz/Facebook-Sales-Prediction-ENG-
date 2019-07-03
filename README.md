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


Lets start with using `auto.arima()` function:

```r
auto.arima(deseasonal_cnt, seasonal=FALSE)

fit<-auto.arima(deseasonal_cnt, seasonal=FALSE)

tsdisplay(residuals(fit), lag.max=2, main='Arima (0,2,1)')

```

This will produce the following outcome:
```
Series: deseasonal_cnt 
ARIMA(0,2,1) 

Coefficients:
         ma1
      -0.695
s.e.   0.146

sigma^2 estimated as 0.2544:  log likelihood=-13.04
AIC=30.07   AICc=30.87   BIC=31.85
```

And the following graph:

![alt text](https://i.imgur.com/ogxXSDV.png "Auto Arima").

What we can deduce from these? Well:
* `auto.arima()` suggest that the best parameters for our models are (P = 0, D = 2, D = 1). Also, it shows a coefficients vector containing two values.
* From the graph we can see that our current model has one lag, that is nearly below significance level. Keep that in mind for the following steps.

### Forecasting with auto.arima()

Following lines of code will allow us to predict revenue on ads in the next 4 quareters:

```r
fcast <- forecast(fit, h=4)
fcast
```

And the outcome is:


| Q    | Point Forecast | Lo 80    | Hi 80    | Lo 95    | Hi 95    |
| ---- | -------------- | -------- | -------- | -------- | -------- |
| 6 Q1 | 13.06914       | 12.42276 | 13.71552 |	12.08059 | 14.05769 |
| 6 Q2 | 14.14557       | 13.08288 | 15.20827 |	12.52032 | 15.77082 |
| 6 Q3 | 15.22201       | 13.73464 | 16.70938 |	12.94727 | 17.49674 |
| 6 Q4 | 16.29844       | 14.36340 | 18.23348 |	13.33905 | 19.25783 |

This table is telling us the Point forecast, which is exact forecasting value, but also:
* Columns `Lo 80` and `Hi 80` means that forecasting value is between given values with 80% confidence level.
* Columns `Lo 95` and `Hi 95` means that forecasting value is between given values with 95% confidence level.

Graph below presents on chart the predicted values:

![alt text](https://i.imgur.com/GpIIIUk.png "ARIMA forecast 1")


### Adjusting ARIMA

Remember when we talked about lags? After first differentiating we got a stationary model, which was ready be our base on predicting FB revenue.\
Back then I showed you a graph that visualizes lags in our auto.arima() model. \
There was one lag that was just below significance level and I decided that we should get rid of it as well, just to be sure.

Lets re-do the steps and see what we get:

```r
fit2 = arima(deseasonal_cnt, order=c(1,2,1))
fit2
tsdisplay(residuals(fit2), lag.max=2, main='Seasonal Model Residuals')
```

Bear in mind that I did another differentiating there by adding "1" in `order=c(1,2,1)`. Previously our model had parameters (0, 2, 1).
This function provided us with the following graph:

![alt text](https://i.imgur.com/G9gjl8p.jpg "Reczna arima")

We can clearly see that now there are no lags close to significance level.

Lets forecast again:

```r
fcast2 <- forecast(fit2, h=4)
fcast2
plot(fcast, ylab="Sales", xlab = "Date", main='(1,2,1) Model Residuals')
```

And the outcome is:

| Q    | Point Forecast | Lo 80    | Hi 80    | Lo 95    | Hi 95    |
| ---- | -------------- | -------- | -------- | -------- | -------- |
| 6 Q1 | 12.89789       | 12.30412 | 13.49166 | 11.98979 | 13.80598 |
| 6 Q2 | 14.12807       | 13.26048 | 14.99566 | 12.80120 | 15.45494 |
| 6 Q3 | 15.23125       | 13.98960 | 16.47290 | 13.33231 | 17.13020 |
| 6 Q4 | 16.38406       | 14.75202 | 18.01610 | 13.88807 | 18.88005 |

![alt text](https://i.imgur.com/cdiq94Y.jpg "Arima2").

How can we decide which model is better? For that, lets use accurac() function.

```r
accuracy(fit1)

##                    ME      RMSE       MAE      MPE     MAPE      MASE      ACF1
##Training set 0.1593972 0.4650064 0.3247317 1.957979 8.219882 0.1576559 -0.389877


accuracy(fit2)

##                    ME      RMSE       MAE      MPE     MAPE      MASE       ACF1
##Training set 0.1600803 0.4395462 0.3192569 2.028751 8.184771 0.5267339 -0.1660251
```

At this point I won't explain each of these columns. We are looking at RMSE (root-mean-square error) and MAPE (Mean absolute percentage error). \
As we can see, second model has lower both of these values, meaning it has better accuracy and therefore we should predict using this one. \
We can say it was worth it to not trust auto.arima() function and remove the "almost-significant" lag on our own as it improved the model.


## Triple exponential smoothing
### 

For the sake of keeping this article relatively short, I won't explain every step of Holt-Winters smoothing in details. You can read about it online.
This time we will read data from a .txt file. It is the same data as in previous model, its just a different technique of importing data:

```r
zarobki <- scan("analizazarobkow.txt")
## Read 20 items
```

Now lets divide our data into quarters:

```r
zarobkits <- ts(zarobki, frequency = 4, start=2013)
zarobkits

##       Qtr1   Qtr2   Qtr3   Qtr4
##2013  1.245  1.599  1.798  2.344
##2014  2.265  2.676  2.957  3.594
##2015  3.317  3.827  4.299  5.637
##2016  5.201  6.239  6.816  8.629
##2017  7.857  9.164 10.142 12.779
```

![alt text](https://i.imgur.com/upCgq67.png "Holt1")


### Parameters of Holt-Winters smoothing

```r
zarobkiforecast <- HoltWinters(zarobkits)
zarobkiforecast
```

Which produces:

```
Holt-Winters exponential smoothing with trend and additive seasonal component.

Call:
HoltWinters(x = zarobkits)

Smoothing parameters:
 alpha: 0.4271286
 beta : 0.6780755
 gamma: 1

Coefficients:
         [,1]
a  11.1354415
b   1.1192333
s1 -0.4031896
s2  0.1524734
s3  0.2656060
s4  1.6435585

```

This function beautifully shows us alfa, better and gamma of our model. 

### Model values
Lets use our model from above and calculate model values between 2013 and 2017.

```r
zarobkiforecast$fitted

##             xhat    level     trend      season
##2014 Q1  1.728712 1.583687 0.2807750 -0.13575000
##2014 Q2  2.503749 2.093526 0.4360975 -0.02587500
##2014 Q3  3.028058 2.603197 0.4859858 -0.06112500
##2014 Q4  3.746988 3.058832 0.4654056  0.22275000
##2015 Q1  4.051463 3.458892 0.4210965  0.17147379
##2015 Q2  3.847459 3.566279 0.2083775  0.07280284
##2015 Q3  3.866537 3.765918 0.2024520 -0.10183210
##2015 Q4  4.615898 4.153087 0.3277041  0.13510769
##2016 Q1  5.291095 4.916932 0.6234411 -0.24927885
##2016 Q2  6.160321 5.501891 0.5973474  0.06108238
##2016 Q3  6.898893 6.132845 0.6201347  0.14591331
##2016 Q4  8.033768 6.717574 0.5961269  0.72006757
##2017 Q1  8.035571 7.567941 0.7685212 -0.30089150
##2017 Q2  9.083147 8.260190 0.7168025  0.10615519
##2017 Q3  9.850173 9.011527 0.7402195  0.09842636
##2017 Q4 11.762193 9.876394 0.8247402  1.06105894
```

Let's compare real values (black line) and model values (red line):

``` {r}
plot(zarobkiforecast)
```

![alt text](https://i.imgur.com/ZGPtFuo.png "Holt2")


### Forecasting year 2018:

```r 
zarobkifckolejnykwartal <- forecast(zarobkiforecast, h=4)
zarobkifckolejnykwartal
```

| Q       | Point Forecast | Lo 80    | Hi 80    | Lo 95    | Hi 95    |
| ------- | -------------- | -------- | -------- | -------- | -------- |
| 2018 Q1 | 11.85149       | 11.26659 | 12.43638 | 10.95697 | 12.74600 |
| 2018 Q2 | 13.52638       | 12.80677 | 14.24600 | 12.42583 | 14.62694 |
| 2018 Q3 | 14.75875       | 13.82906 | 15.68844 | 13.33691 | 16.18058 |
| 2018 Q4 | 17.25593       | 16.05638 | 18.45548 | 15.42138 | 19.09048 |

And let's put it on a chart:

![alt text](https://i.imgur.com/ts6WST9.png "Holt").

The last step is calculate errors:

```r
accuracy(zarobkiforecast$fitted, zarobkits)

##        ME      RMSE       MAE      MPE     MAPE      ACF1 Theil's U
## Test set 0.1809359 0.4775078 0.3472516 2.725354 7.045097 0.1345076 0.5448054
```



# Choosing optimal forecast model, results

We have been forecasting FB revenue on ads using both ARIMA and Holt-Winters smoothing. \
Let's compare errors from both of them:

| Model         | ME        | RMSE      | MAE       | MPE      | MAPE      |
| ------------- | --------- | --------- | --------- | -------- | --------- |
| ARIMA (1,2,1) | 0.1600803 | 0.4395462 | 0.3192569 | 2.028751 | 0.5267339 |
| Holt-Winters. | 0.180935  | 0.4775078 | 0.3472516 | 2.725354 | 7.045097  |


Comparing the results we can realize that both models forecast with very similar errors. \
What that mean is we have confirmation that both models are correct. RMSE errors are small, meaning both models predicted correctly revenue on ads in 2018.



# Summary
This project was supposed to present two methods of forecsating values in time series. I've chosen ARIMA and Holt-Winters as they both properly fit to our case - FB Revenue on adds had growing trend and significant seasionality. 

Both model provided us with similar values, meaning they are comparable. We can not pickup a better model without a doubt. 

This project agenda's was to prove that we should never rely on only one model when it comes to forecasting. We should forecast by using different tools, and only if the results are similar, comparable then we can post a thesis.

Should you have any questions, feel free to contact me by email or on private message here on github. 
Thanks for your attention.
