library(tidyverse)
library(DT)
library(data.table)
library(lubridate)
library(caret)
library(knitr)
library(kableExtra)
library(forecast)
library(prophet)

fillColor = "#FFA07A"
fillColor2 = "#F1C40F"
#setwd("/home/sachamwa/Desktop/Project")

train <- as.tibble(fread("train.csv", skip = 86672217, header = FALSE))
setnames(train, c("id","date", "store_nbr", "item_nbr", "unit_sales","onpromotion"))


oil = as.tibble(fread('oil.csv'))
holidays = as.tibble(fread('holidays_events.csv'))
stores = as.tibble(fread('stores.csv'))
items = as.tibble(fread('items.csv'))
test = as.tibble(fread('test.csv'))

#REMOVE/IMPUTE MISSING VALUES
#TRAIN DATA
summary(train)
#Only unit sales has missing values
dim(train[!complete.cases(train$unit_sales),])[[1]]/nrow(train)*100
#As percentage of missing values is less than 0.05%, we will drop these values
train <- train[complete.cases(train$unit_sales), ]

#STORES DATA
summary(stores)
#No missing values

#OIL DATA
summary(oil)
#Oil price data for 43 dates is missing
dim(oil[!complete.cases(oil$dcoilwtico),])[[1]]/nrow(oil)*100
#As percentage of missing values is less than 5%, we will impute these values using caret, mice package
#imputing missing values for oil price data
library(mice)
imputedValues <- mice(data=oil, m=3, method="cart", seed=2016)
oil <- complete(imputedValues,1)



#ITEMS DATA
summary(items)
#No missing values

#HOLIDAYS DATA
summary(holidays)
#No missing values

#TRANSACTIONS DATA
summary(transactions)
#as this data can be extracted from the Train dataset itself. We will not use it any further



#change the dates to date time format
train$date=as.Date(train$date)
oil$date=as.Date(oil$date)
holidays$date=as.Date(holidays$date)
test$date=as.Date(test$date)

###################
#XGBOOST
###################

#function for replacing missing values with zero

TransformColumn = function(x)
{
  if (is.na(x))
  {
    return (0)
  }
  else
  {
    return (x)
  }
}


trainprep = function(ds,ItemNumber=314393,StoreNumber=40)
{
  d = train %>%
    filter(store_nbr == StoreNumber) %>%
    filter(item_nbr == ItemNumber) %>%
    arrange(desc(date)) %>%
    mutate(year = year(ymd(date)))  %>%
    mutate(month = month(ymd(date)))  %>%
    mutate(dayOfWeek = wday(date))  %>%
    mutate(day = day(ymd(date))) %>%
    head(360)
  
  d = left_join(d,oil,by="date")
  imputedValues <- mice(data=d, m=3, method="cart", seed=2016)
  d <- complete(imputedValues,1)
  
  
  HolidaysNational = holidays %>%
    filter(type != "Work Day") %>%
    filter(locale == "National")
  
  d = left_join(d,HolidaysNational, by = "date") 
  str(d)
  names(d)[12]="holiday"
  d = d %>%
    select( -locale,-locale_name,-description,-transferred)
  
  d = d %>%
    select(-id,-store_nbr,-item_nbr,-date) 
  
  d = d %>%
    mutate(onpromotion = as.numeric(onpromotion))
  
  d$holiday = sapply(d$holiday,TransformColumn)
  
  features <- colnames(d)
  
  for (f in features) {
    if ((class(d[[f]])=="factor") || (class(d[[f]])=="character")) {
      levels <- unique(d[[f]])
      d[[f]] <- as.numeric(factor(d[[f]], levels=levels))
    }
  }
  
  return(d)
  
}

###########################
#XG Boost Forecasting
###########################
dtrain = trainprep(train,314393,40)
dtest= trainprep(test,314393,40)

formula = unit_sales ~ .

fitControl <- trainControl(method="cv",number = 5)

xgbGrid <- expand.grid(nrounds = 500,
                       max_depth = 4,
                       eta = .05,
                       gamma = 0,
                       colsample_bytree = .5,
                       min_child_weight = 1,
                       subsample = 1)

set.seed(1234)

XGBModel = train(formula, data = dtrain,
                 method = "xgbTree",trControl = fitControl,
                 tuneGrid = xgbGrid,na.action = na.pass,metric="RMSE")


PlotImportance = function(importance)
{
  varImportance <- data.frame(Variables = row.names(importance[[1]]), 
                              Importance = round(importance[[1]]$Overall,2))
  
  # Create a rank variable based on importance
  rankImportance <- varImportance %>%
    mutate(Rank = paste0('#',dense_rank(desc(Importance))))
  
  rankImportancefull = rankImportance
  
  ggplot(rankImportance, aes(x = reorder(Variables, Importance), 
                             y = Importance)) +
    geom_bar(stat='identity',colour="white", fill = fillColor) +
    geom_text(aes(x = Variables, y = 1, label = Rank),
              hjust=0, vjust=.5, size = 4, colour = 'black',
              fontface = 'bold') +
    labs(x = 'Variables', title = 'Relative Variable Importance') +
    coord_flip() + 
    theme_bw()
}

importance = varImp(XGBModel)

PlotImportance(importance)

xgbpred = round(predict(XGBModel,dtest,na.action= na.pass))

cat("The predictions are ","\n")

xgbpred

##############################
#ARIMA
##############################
a=dtrain[c(16:nrow(dtrain)),]
a=Filter(function(x)(length(unique(x))>1), a)
a.y=a[,1]
a.x=a[,-1]
b=dtrain[c(1:15),]
b.y=b[,1]
b.x=b[,-1]

tsdtrain = ts(a.y)

fit <- auto.arima(tsdtrain, xreg = a.x)

summary(fit)
arpreds = forecast(fit, h = 15,xreg =b.x )

arpreds %>% autoplot(include=60) +theme_bw()

arpredictions = round(as.numeric(arpreds$mean))

cat("The predictions are ","\n")

arpredictions

##########################
#ETS
##########################

fit <- ets(tsdtrain)

etspreds = forecast(fit, h = 15)

summary(fit)
etspreds %>% autoplot(include=60) +theme_bw()

ETSpredictions = round(as.numeric(etspreds$mean))

cat("The mean predictions are ","\n")

ETSpredictions

#############################
#PROPHET
#############################
proptrain = train %>%
  filter(store_nbr == 40) %>%
  filter(item_nbr == 314393) %>%
  arrange(desc(date)) %>%
  select(date,unit_sales) %>% head(360)
colnames(proptrain) = c("ds","y")


a=proptrain[c(16:nrow(proptrain)),]
colnames(a) = c("ds","y")

b=proptrain[c(1:15),]
colnames(b) = c("ds","y")


m <- prophet(a,changepoint.prior.scale = 0.1)
summary(m)
future <- make_future_dataframe(m, periods = 15,freq = "day")

forecast <- predict(m, future)

prophpredictions = tail(round(forecast$yhat),15)

plot(m, forecast)

cat("The predictions are ","\n")

prophpredictions

## Break into the Prophet Components
prophet_plot_components(m, forecast)

####################
#MODEL PREDICTIONS
####################
b$y
names(b)[2]="actual"
b$PROPHET=prophpredictions
b$ARIMA=arpredictions
b$ETS=ETSpredictions
#############################
#MODEL PERFORMANCE COMPARISONf
#############################
ArimaRMSE = sqrt(mean((b$ARIMA - b$actual)^2))
ArimaRMSE

ETSRMSE = sqrt(mean((b$ETS - b$actual)^2))
ETSRMSE

ProphetRMSE = sqrt(mean((b$PROPHET - b$actual)^2))
ProphetRMSE
## Based on RMSE values Prophet is the most suitable model for forecasting sales.



