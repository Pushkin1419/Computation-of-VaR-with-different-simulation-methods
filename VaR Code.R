library(curl)
library(quantmod)
library(PerformanceAnalytics)
library(RQuantLib)
library(plyr)
library(car)
library(zoo)

#Let's create our portfolio of assets
Symbol=c("JPM","GOOG","T","MSFT","GFI","FRO","FMS","JNJ","WMT","V")
Quantity=round(runif(10, min=100,max=2000))
Asset=rep("Stock", 10)
portfolio=data.frame(Asset,Symbol,Quantity)

stock_portfolio <- subset(portfolio, Asset=="Stock")
quantity <- as.vector(stock_portfolio$Quantity)
symbol <- as.vector(stock_portfolio$Symbol)


# We get the data for the stocks in our portfolio
getSymbols(symbol, from="2010-01-01", to="2017-09-01", src="yahoo") #needs quantmod
AdjClosePrices <- do.call(merge, lapply(symbol, function(x) Ad(get(x))))

# We calculate the value of our portfolio, based on the market price of the asset 
# and the quantity of each asset held 
Daily_Position_Notional_Value <- t(AdjClosePrices) * quantity
Daily_Position_Notional_Value<-t(Daily_Position_Notional_Value)
class(Daily_Position_Notional_Value)
Daily_Position_Notional_Value <- as.xts(Daily_Position_Notional_Value)
Daily_Portfolio_Notional_Value <- rowSums(Daily_Position_Notional_Value)
Total_Daily_Portfolio_Notional_Value <- cbind(Daily_Position_Notional_Value, Daily_Portfolio_Notional_Value)
colnames(Total_Daily_Portfolio_Notional_Value)[11] <- "Total_Notional"

class(Total_Daily_Portfolio_Notional_Value)
names(Total_Daily_Portfolio_Notional_Value)

# Calculating the return of our portfolio
portfolio_return <- CalculateReturns(Total_Daily_Portfolio_Notional_Value$Total_Notional, method="discrete")

portfolio_return = portfolio_return[-1,]
#plot(x=portfolio_return, screens = 1)


## This is our VAR Calculation
# Backtesting VaR
n.obs = nrow(portfolio_return)
w.e = 1000
w.t = n.obs - w.e
alpha = 0.99

# loop over testing sample, compute VaR and record hit rates
backTestVaR <- function(x, p = 0.99) {
  normal.VaR = as.numeric(VaR(x, p=p, method="gaussian"))
  historical.VaR = as.numeric(VaR(x, p=p, method="historical"))
  modified.VaR = as.numeric(VaR(x, p=p, method="modified"))
  ans = c(normal.VaR, historical.VaR, modified.VaR)
  names(ans) = c("Normal", "HS", "Modified")
  return(ans)
}

# rolling 1-step ahead estimates of VaR
VaR.results = rollapply(as.zoo(portfolio_return), width=w.e, 
                        FUN = backTestVaR, by.column = FALSE,
                        align = "right")
VaR.results = lag(VaR.results, k=-1)
chart.TimeSeries(merge(portfolio_return, VaR.results), legend.loc="topright")

# VaR.results holds the VaR value from the 1001st day to 1929th day, for the 
# Normal Distribution and Historical Simulation approach

# Now, we calculate on which dates the our portfolio value exceeded the value predicted 
# by VaR, as per the "Normal Distribution" approach
normalVaR.violations = as.zoo(portfolio_return[index(VaR.results), ]) < VaR.results[, "Normal"]
normal.violation.dates = index(normalVaR.violations[which(normalVaR.violations)])

# Next, we calculate on which dates the our portfolio value exceeded the value predicted 
# by VaR, as per the "Historical Simulation" approach
historicalVaR.violations= as.zoo(portfolio_return[index(VaR.results), ]) < VaR.results[, "HS"]
historical.violation.dates = index(historicalVaR.violations[which(historicalVaR.violations)])

# plot violations
plot(as.zoo(portfolio_return[index(VaR.results),]), col="blue", ylab="Return")
lines(VaR.results[, "Normal"], col="black", lwd=2)
lines(as.zoo(portfolio_return[violation.dates,]), type="p", pch=16, col="red", lwd=2)

portfolio_return[violation.dates,]

# Now, let's calculate Kupiec's Unconditional Log-Likelihood ratio for the
# exceptions observed with the Normal Distribution and Historical Simulation methods.
# This is done to check whether our VaR predictions (hence model) is sufficient, of
# whether we are under-predicting or over-predicting the VaR value

# 1) Normal Distribution approach
t=929
n= length(normal.violation.dates)
p=0.01

tStat= -2*log(((1-p)^(t-n)*(p^n))) + 2*log((1-(n/t))^(t-n)*((n/t)^n))
tStat
#1.331267


# 2) Historical Simulation approach
t=929
n= length(historical.violation.dates)
p=0.01

tStat= -2*log(((1-p)^(t-n)*(p^n))) + 2*log((1-(n/t))^(t-n)*((n/t)^n))
tStat
#0.3002292


## The Kupiec's Unconditional Log-Likelihood ratio test statistic follows a Chi-Square
## distribution with one degree of freedom. 
## Choosing a Significance Level = 0.05, the cutoff-value for this distribution
## is 3.841
## HENCE, since both test statistics, from the Normal Distribution method and the 
## Historical Simulation metod, both yield values less than the cutoff value of 3.841, 
## both VaR models are sufficient.

## However, because the test statistic value of the Historical Simulation method (0.3002292)
## is lower, it means that this method was more appropriate.