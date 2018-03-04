## Project title:
##    Created at:
##        Author: Philippe Rast <prast@ucdavis.edu>
##          Data: 
##       Summary:
##                
## ---------------------------------------------------------------------- ##
library(boot)


model <- lm(Fertility ~ Agriculture, data = swiss)
plot(swiss$Agriculture, swiss$Fertility, pch = 21, col="green",bg="red")
abline(model,col="blue")

summary(model)
## CI from model
confint(model)

## The first step is to write what is known as the ‘statistic’ function. This shows boot how to calculate the
## statistic we want from the resampled data (the slope in this case). The resampling of the data is achieved by
## a subscript provided by boot (here called index). The point is that every time the model is fitted within
## the bootstrap it uses a different data set (yv and xv): we need to describe how these data are constructed and
## how they are to be used in the model fitting:

ci.boot <- function(data, index){
    xv <- data$Agriculture[index]
    yv <- data$Fertility[index]
    model <- lm(yv~xv)
    coef(model)
}

## Now we can run the boot function, then extract the intervals with the boot.ci function:
ci.model <- boot(swiss,ci.boot,R=10000)
boot.ci(ci.model,index=2) ## with index=2 slope CI is selected (withi index=1, the intercept)
## All the intervals are reasonably similar: statisticians typically prefer the bias-corrected, accelerated (BCa)
## intervals.

## Now, bootstrap the AIC of the model to obtain a CI around AIC
AIC.boot <- function(data, index){
    xv <- data$Agriculture[index]
    yv <- data$Fertility[index]
    model <- lm(yv~xv)
    return(AIC(model))
}

AIC.model <- boot(swiss,AIC.boot,R=10000)
plot(AIC.model)

boot.ci(AIC.model)
