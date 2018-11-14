# Computation-of-VaR-with-different-simulation-methods

VaR or Value at Risk, is a model used by banks and portfolio managers to check what is the maximum amount they could lose, given a portfolio of securities, with a certain confidence level and a given time horizon. This value is then taken into account by the institution making the investments, as it is required that they keep a certain amount of capital to sustain such losses [And not go bankrupt in the event of huge losses]

- In this short piece of code, I have created a portfolio of securities, caclulated the value of my portfolio daily as per the quantity of each asset held, and then calculated the Value-At-Risk of my portfolio, using the Normal Distribution method, and the Historical Simulation method. 

If the VaR of a portfolio on any given day is exceeded by the value of the portfolio [in terms of return, i.e if the return of the portfolio is MORE negative than the VaR of the portfolio], then this is labelled an EXCEPTION; because such is a case where our potfolio lost more than the "maximum amount" that was expected to be lost as per the VaR model. 
The number of such Exceptions is then taken and used as a parameter in a test called the "Unconditional Kuipiec Log-Likelihood Test". This test is used to gauge the strength of our VaR model, whether it Over-Estimating or Under-Estimating the maximum value that the portfolio can lose; therefore whether the institution has to decrease or increase respectively the amount of capital they require. 
The test statistic follows a Chi-Square distribution with one degree of freedom, and by calculating the test statistic, we are performing the following hypothesis test:
Null Hypothesis= The number of exceptions is/ or below what is expected
Alternate Hypothesis= The number of exceptions is above what is expected

If the number of exceptions is indeed greater than what is to be expected by our VaR model, then we reject the Null Hypothesis and consider our model to be insufficient in predicting the appropriate VaR value. 

- So after having calculated the VaR values from both the Normal Distribtuion and Historical Simulation approach, I check the number (and dates) of the exceptions made by the portfolio, which I then use as a parameter in the Unconditional Kuipiec Log-Likelihood Test, and calculate the Test Statistic.

Conclusion:
The test statistics that I got from both methods are:
Normal Distribution method= 1.331267
Historical Simulation method= 0.3002292

Since the test statistic follows a Chi-Square distribution with one degree of freedom, with a Significance Level of 0.05, the cutoff-value for this distribution was 3.841.

Hence, we can see that, since neither test statitic value for both methods is greater than our cutoff-value, we fail to reject the Null Hypothesis in both cases. Therefore, we can consider both VaR methods to be appropriate for our portfolio. 
Note however, that because the Historical Simulation method gave us a much lower test statistic value (meaning that it is further away from the cut-off value), it means that the Historical Simulation method was a stronger approach in our case. 
