# Grocery_items_time-series_demands_forecasting

**INTRODUCTION**

There are lot of benefits for effectively predicting sales forecasts.(1) Efficient supply chain scheduling where Forecasting the amount of sales and when they are likely to occur, would help better scheduling production, warehousing and shipping. (2)Better Labor Management where Anticipating demand means knowing when to increase staff and other resources to keep operations running smoothly during peak periods. (3) Adequate Cash Flow: Knowing the peaks and valleys of demand would help in better management of cash flow, ensuring there is enough money and bills are paid on time. (4)More Accurate Budgeting: The more accurately you can forecast demand, including the timing of your sales, the more accurate you can be with budgeting. Overstocking can be prevented at the Inventory SKU&#39;s thereby prevention of wastage loss.

Here we are Predicting future demand for different items in a grocery store. [Corporación Favorita](http://www.corporacionfavorita.com/) is a large Ecuadorian-based grocery retailer which operates hundreds of supermarkets, with over 200,000 different products on their shelves. They want to know how much they should stock up in order to prevent overstocking . They want to solve this using an analytical approach. It is a timeseries analytics problem and there are various methodologies to solve these kinds of problems. The client, [Corporación  Favorita](http://www.corporacionfavorita.com/), has come to an agreement for allowing the usage of their data for analyzing and coming up with a solution.

## **DATA**

The data used in this research is from the Kaggle competition which aims to forecast demand for millions of items at a store and day level for a South American grocery chain. (https://www.kaggle.com/c/favorita-grocery-sales-forecasting/data). The data is provided in different tables named train, test, stores (store related data), items (merchandise data), transaction, oil (oil prices can be a good predictor of sales as Ecuador is an oil-dependent economy), and holidays events (holiday &amp; major event related data). Table 2 provides a summary of all the important columns is given below along with the relations between each data table provided.




<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/Dataset%20Information2.png"/>
## Figure 1: Dataset Information

## **METHODOLOGY**

**Business Understanding:**

 We started with understanding the business&#39;s objectives of the problem and its application. We understood that in addition to the usual trend in shopping of items, there could be external factors (e.g. Oil Price, Holidays) which could affect the demand. Further, we understood the rationale of high weight given to perishable goods and its impact on the business. As we understood more, it was clear to use that it was a short-term (15th days) demand forecasting required at a granular level. We prepared a preliminary strategy by starting our research more into various modeling technique applicable to time-series and best practices and tooling required in dealing with the BigData (100 million rows of training). Through Literature review, we were mindful of the fact that some model-output (e.g. PCA, Clustering) would serve as input for other models and for this reason, it was included in the strategy to try out various model (with moving average features).

**Data Understanding:** We sourced flat data files and did some preprocessing to do EDA (Exploratory Data Analysis) exercise. Then, with a connection to Tableau, we collected the basic facts about the data and studied the distribution of all the key variables.



**Modelling overview:**

Various models like ARIMA, XGBOOST, ETS and Prophet were applied and the predicted values of test set and trainset were validated against each other. Predictions over a random time slice of 16 day horizon were generated using the below given methods, for a selected store and a selected item, and the RMSE values were calculated for those predicted values.
<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/Modelling%20Process.png"/>
## **MODELING**

**FORECASTING MODELS**

**ARIMA**

This is one of the oldest and most widely used methods of demand forecasting. In this method, the average sales of the previous days are used as the predictor for the sales of the next day. It is simple and gives good accuracy when done on a short-term horizon. However, it is not likely to predict well for a longer-duration span as it is not generalizing the trend mere following the past behavior with auto-regressive components.

Here, we used arima.fit which takes care of AIC BIC parameters,  AIC (Akaike Information Criterion) and BIC (Bayesian Information Criterion) values are estimators to compare models. The lower these values, the better is the model. Here the values are predicted based on the average of the previous observations

**XGBOOST**

Extreme gradient Boosting Model(LGBM) is a fast variant method in the class of tree-based boosting algorithm. XGBoost is also known as &#39; **regularized boosting**&#39; technique. GBoost is also known as &#39; **regularized boosting**&#39; technique. We chose XGBoost for its wide range of tuning parameters that can be implied to optimize, and it comes with a built-in cross validation model. XGBoost because it&#39;s computationally expensive, takes a while to come up with an optimal solution.

**ETS (Exponential Smoothing)**

This method gives more significance to recent observations, and it is used to predict forecast for a season ahead. It neglects the ups and downs associated with random variation which on a graph shows you a smoother line or curve. This it does not take into account the intricate changes caused by different factors within a cycle, gives an overview of the trends happening in the season.

**Prophet**

Prophet was developed by the team at facebook, and it is one of the best methods applied in demand forecasting when factors like seasonal changes, holidays are taken into consideration as it has a specific functional part assigned to each of these changes in its algorithm.

We use a decomposable time series model with three main model components: trend, seasonality, and holidays.

## **RESULTS**

**Descriptive Analytics**

We first perform descriptive analytics on the sample of data we have taken to discern any interesting trends. We plot the total unit sales across all stores with a variety of variables. The plots we got using Tableau are as follows:
<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/Oil%20Prices%20Vs%20Unit%20Sales%20axcross%20years.png"/>
Plot 1. Total oil price vs Total units sales through the years
<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/Store%20wise%20Unit%20Sales%20Bubble%20plot.png"/>
Plot 2: Bubble plot showing store number on the basis of unit sales
<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/Type%20of%20Day%20Vs%20unit%20Sales.png"/>
Plot 3: Pie chart showing the total unit sales depending in the type of day

We see from the first plot that there seems to be a near inverse relationship between the total oil price and the total unit sales throughout the months. Whenever the oil sales are high, sales tend to be low and vice-versa. The second plot gives us an idea about the stores that tend to sell a greater number of units. Clearly, stores 3, 44, 45 and 47 seem to sell the greatest number of items in the time duration. The third plot gives us an idea about the sum of sales of items on each type of day. Holidays tend to be the most attractive type of day for the grocery stores as most items sell during these days.

However, as we have nearly 221,400 store-item combinations, and the sales for each of these store-items is essentially a unique time series, visually inspecting all the features is not useful in this case.

**Forecasting models**

Considering the volume of data provided (125 million observations) and existing computing capacity, only single year of observations (37 Million observations) from 1st
 Aug 2016 to 31st
 July 2017 are used for analysis. The objective of this study is to predict no of unit sales for 4100 items sold through 54 stores at various locations from 16th
 Aug 2017 to 31st Aug 2017.

Four different forecasting models were developed for predictions namely, XG Boost, ARIMA, ETS (Exponential Smoothing Test space model) and PROPHET. For assessing the accuracy of each of these models the training data was split into training and testing data set.

Observations from 1st Aug 2016 to 15th July 2017 were used for training and observations from 16th Aug 2017 to 31st Aug 2017 were used for testing. The prediction models were developed at item and store level meaning, for each combination of an item at a store, one separate model was developed to predict its unit sales. For this analysis store number 40 and item number 314393 is selected for this analysis. With this approach, store and item specific information such as location of store, family of items does not affect the model performance as all the training observations for that model would have same values of these variables. 5 fold cross validation was used for assessing the performance of XG Boost models. Multi variate ARIMA model was developed using independent variables such as &quot;Day&quot;, &quot;Weekday&quot;, &quot;Onpromotion&quot;, &quot;Holiday&quot;.

ETS and PROPHET models did not consider any effect of other regressors than time. Following forecasting trends were estimated using selected models:


<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/Arima%20Forecasts.png"/>
**Unit sales forecasting trend: ARIMA**


<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/ETS%20Forecasts.png"/>
**Average Unit sales forecasting trend: ETS**

<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/Prophet%20Forecasts.png"/>
Forecasted Trends – Prophet Model

<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/Prophet%20WeekDay%20seasonality.png"/>
Weekday Seasonality Impact - Prophet Model


**Best Model Selection:**
RMSE (Root Mean Squared Error) value is used to compare the performance of selected models.

<img src="https://github.com/sushil1792/Grocery_items_time-series_demands_forecasting/blob/master/RMSE.png"/>


The RMSE value for ARIMA decreased after including other independent regressors from 9.63 to 8.54. But even then, PROPHET performed better than all other models. As shown below, the PROPHET model significantly captures the seasonality in sales trends.


## **CONCLUSIONS**

A small increase in predictive accuracy can help firms save substantial amount of inventory costs while maintaining acceptable service levels. This was seen with the model Prophet when compared to the other models. The RMSE values were low compared to the other models. As the results of this study demonstrate, machine learning techniques can help in improving the forecast accuracies to a certain extent, in our study, as our research was computationally limited provided the resources, given we had 125 million instances of data. However, with ever increasing technological innovations, future analysts can explore more input features related to intermittent demand prediction and the demand prediction would get extremely accurate over time.

More better model/algorithms can be made, which would take into account the transient changes more readily within a seasonal time forecast which follow a trend, like the one done in prophet where it takes into account the effect of holidays, and other intermittent changes within a trend. More better ways of calculating or predicting these changes would help in better forecasting the timeseries prediction.
