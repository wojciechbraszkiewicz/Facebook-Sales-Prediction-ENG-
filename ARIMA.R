library('ggplot2')
library('forecast')
library('tseries')
library(readr)
library(readxl)


Facebook <- read_excel("fb_dane.xlsx", col_types = c("date", "numeric"))
View(Facebook)

#Zmamiana string na date
Facebook$Date = as.Date(Facebook$Date)

#Plot sales&date
ggplot(Facebook, aes(Date, Sales)) + geom_line() + scale_x_date('Date')  + ylab("FB Sales") +
  xlab("")

#Dekompozycja szeregu
sales_ma = ts(na.omit(Facebook$Sales), frequency=4)
decomp = stl(sales_ma, s.window="periodic")
deseasonal_cnt <- seasadj(decomp)
plot(decomp)

#Przeprowadzenie testu ADF
adf.test(sales_ma, alternative = "stationary")

#Autokorelacja
Acf(sales_ma, main='')
Pacf(sales_ma, main='')

count_d1 = diff(deseasonal_cnt, differences = 1)
plot(count_d1)
adf.test(count_d1, alternative = "stationary")

Acf(count_d1, main='ACF for Differenced Series')
Pacf(count_d1, main='PACF for Differenced Series')


#Auto_Arima
auto.arima(deseasonal_cnt, seasonal=FALSE)

fit<-auto.arima(deseasonal_cnt, seasonal=FALSE)
tsdisplay(residuals(fit), lag.max=2, main='(0,2,1) Model Residuals')

#Przewidywanie dla auto.arimy
fcast <- forecast(fit, h=4)
fcast
plot(fcast, ylab="Sales", xlab = "t")


#Reczna ARIMA
fit2 = arima(deseasonal_cnt, order=c(1,2,1))
fit2
tsdisplay(residuals(fit2), lag.max=2, main='Seasonal Model Residuals')

#Przewidywanie dla recznej arimy
fcast2 <- forecast(fit2, h=4)
fcast2
plot(fcast, ylab="Sales", xlab = "t", main='(1,2,1) Model Residuals')

accuracy(fit2)
