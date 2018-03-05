####################################################
##                                                ##
##                   204B Lab 2                   ##
##            VIOLATION OF ASSUMPTIONS            ##
##                                                ##
##               Kristine O'Laughlin              ##
##                   Winter 2018                  ##
##                                                ##
####################################################



## REVIEW OF HOMEWORK 2
####################################################

## 1. Download the hw_w2_1.RDat file from canvas 
#     and load it into R

setwd('C:/Users/Kristine/Dropbox/Winter2018/PSC204B/Homeworks')
load(file = 'hw_w2_1.RDat')

head(hw_w2_1)


#     Run a linear regression and check with there is 
#     suppression, and if so, what type?


# Start with a correlation matrix to determine 
# relations among our set of variables:
cor(hw_w2_1) # So we see that there are positive
             # relations between the predictors
             # and outcome variables, while
             # there is a negative association 
             # between the two predictors.


# Model 1:
summary(lm(y ~ x1, data = hw_w2_1)) #r^2_y,x1 = .1306

# Model 2:
summary(lm(y ~ x2, data = hw_w2_1)) #r^2_y,x2 = .1987

# Model 3:
summary(lm(y ~ x1 + x2, data = hw_w2_1)) # R^2_y,x1x2 = .4151


# Is the sum of the r^2_y,x1 and r^2_y,x2 < R^2_y,x1x2?

(.1306 + .1987) < .4151 # TRUE--taken as evidence of 
                        # suppression

# Because correlation between x1 and x2 is < 0, and 
# relation between predictors with outcome is > 0, 
# this is an example of cooperative suppression



## 2. Download the hw_w2_2.RDat file from canvas and 
#     load it into R

load(file = 'hw_w2_2.RDat')
head(hw_w2_2)

#     Fit a quadratic model and center at the beginning 
#     of the study, at the grand-mean and at the end.

# Centering:
#     Beginning:
hw_w2_2$x_b = hw_w2_2$x - min(hw_w2_2$x)


#     Grand-mean:
hw_w2_2$x_m = hw_w2_2$x - mean(hw_w2_2$x)

#     End:
hw_w2_2$x_e = hw_w2_2$x - max(hw_w2_2$x)


# What is the effect of centering the data?
par(mfrow = c(3, 1))

with(hw_w2_2, plot(x_b, y, xlim = c(-60, 60), 
                   main = 'Centering at Beginning'))
with(hw_w2_2, plot(x_m, y, xlim = c(-60, 60),
                   main = 'Centering at Grand-Mean'))
with(hw_w2_2, plot(x_e, y, xlim = c(-60, 60),
                   main = 'Centering at End'))


# Now fitting the quadratic model for each:
#     Beginning:
fit1 = summary(lm(y ~ x_b + I(x_b^2), data = hw_w2_2))

#     Grand-mean:
fit2 = summary(lm(y ~ x_m + I(x_m^2), data = hw_w2_2))

#     End:
fit3 = summary(lm(y ~ x_e + I(x_e^2), data = hw_w2_2))


coef(fit1); coef(fit2); coef(fit3)


#     Plot the figure with the fitted line and the simple 
#     slope or instantaneous rate of change at the three 
#     centering points.


# Start with bivariate scatterplot of raw data:
par(mfrow = c(1, 1))
with(hw_w2_2, plot(x, y))

# Creating squared variable (this will make it
# easier to plot the quadratic function later):
hw_w2_2$x2 = hw_w2_2$x^2

# Fit the quadratic model to the raw data:
fit = lm(y ~ x + x2, data = hw_w2_2)

# Create a sequence of x values at short intervals
# to get a smooth function:
times = seq(min(hw_w2_2$x), max(hw_w2_2$x), .01)

# Get predicted y-values for each of the values
# above
pred = predict(fit, list(x = times, x2 = times^2))

# Add the quadratic function:
lines(times, pred, col = 'red', lwd = 3)


# To get the instantaneous rate of change, we can
# pull this value from each of the fitted models
# we ran earlier:

# Beginning:
slope_b = coef(fit1)[2, 1]

# Grand-mean:
slope_m = coef(fit2)[2, 1]

# End:
slope_e = coef(fit3)[2, 1]

# Get predicted y-values using raw equation:
y_b = coef(fit1)[1]
y_m = coef(fit2)[1]
y_e = coef(fit3)[1]

# Get intercept for tangent lines:
b_b = y_b - slope_b*min(hw_w2_2$x)
b_m = y_m - slope_m*mean(hw_w2_2$x)
b_e = y_e - slope_e*max(hw_w2_2$x)


# We need to plot the instantaneous rate of change at each
# of the following points:

# Beginning:
points(min(hw_w2_2$x), y_b, pch = 8, cex = 1.8, col = 'blue',
       lwd = 2)

# Grand-mean:
points(mean(hw_w2_2$x), y_m, pch = 8, cex = 1.8, col = 'green',
       lwd = 2)


# End:
points(max(hw_w2_2$x), y_e, pch = 8, cex = 1.8, col = 'purple',
       lwd = 2)

# Adding the tangent lines:
abline(b_b, slope_b, col = 'blue', lty = 2, lwd = 2)
abline(b_m, slope_m, col = 'green', lty = 2, lwd = 2)
abline(b_e, slope_e, col = 'purple', lty = 2, lwd = 2)

# Adding a legend:
legend('topright', c('Beginning', 'Mean', 'End'), 
       col = c('blue', 'green', 'purple'),
       lty = c(2, 2, 2), lwd = c(2, 2, 2))



## 3. In this exercise you will simulate two variables that 
#     are statistically independent of each other to see what 
#     happens when we run a regression of one on the other.

##    a. First generate 1000 data points from a normal 
#        distribution with mean 0 and standard deviation 1 
#        by typing var1 <- rnorm(1000,0,1) in R. Generate 
#        another variable in the same way (call it var2). 
#        Run a regression of one variable on the other. Is 
#        the slope coefficient statistically significant?


set.seed(012318)
var1 <- rnorm(1000,0,1)
var2 <- rnorm(1000,0,1)

summary(lm(var2 ~ var1)) # Slope is not statistically 
                         # significant


##    b. Now run a simulation repeating this process 100 
#        times. This can be done using a loop. From each 
#        simulation, save the z-score (the estimated 
#        coefficient of var1 divided by its standard error). 
#        If the absolute value of the z-score exceeds 2, 
#        the estimate is statistically significant. Here is 
#        code to perform the simulation:


# (If you do not have the following package installed, 
# the simulation will not run).
# install.packages('arm')
library(arm)

z.scores <- rep (NA, 100)

set.seed(012618)
for (k in 1:100) {
  var1 <- rnorm (1000,0,1)
  var2 <- rnorm (1000,0,1)
  fit <- lm (var2 ~ var1)
  z.scores[k] <- coef(fit)[2]/se.coef(fit)[2]
}

#        How many of these 100 z-scores are statistically 
#        significant?

# To answer this, we can look at how many of the results
# had an absolute value greater than 2:

sum(abs(z.scores) > 2)

# Our sum should be around 5...why?



## 4. Download the child.iq.dta dataset. You have 
#     access to children's test scores at age 3, mother's
#     education, and the mother's age at the time she 
#     gave birth for a sample of 400 children. The data 
#     are a Stata file which you can read into R by saving 
#     in your working directory and then typing the 
#     following:

#install.packages('foreign')  
library (foreign)
iq.data <- read.dta ("child.iq.dta")

#     a. Fit a regression of child test scores on mother's 
#        age, display the data and fitted model, check 
#        assumptions, and interpret the slope coefficient. 
#        When do you recommend mothers should give birth? 
#        What are you assuming in making these 
#        recommendations?

head(iq.data)

iq.fit = lm(ppvt ~ momage, data = iq.data)

summary(iq.fit)

# We can get some useful diagnostic plots by using
# the plot() wrapper around the object from lm():
par(mfrow = c(2, 2)) # First rearranging the ploting window
plot(iq.fit)

par(mfrow = c(1, 1))
with(iq.data, plot(momage, ppvt, xlab = 'Mother\'s \n Age',
                   ylab = 'Child\'s Test Score'))
abline(lm(ppvt ~ momage, data = iq.data), col = 'red',
       lwd = 3)

# So what is the interpretation of the slope here?

# When would you recommend that women have children?

# What assumptions do this recommendation depend on?


#     b. Repeat this for a regression that further includes 
#        mother's education, interpreting both slope 
#        coefficients in this model. Have your conclusions 
#        about the timing of birth changed?

summary(lm(ppvt ~ momage + educ_cat, data = iq.data))

# How would you interpret the slope for mother's age?

# How would you interpret the slope for mother's education?

# Have your conclusions changed?



## 5. Download  data from Hamermesh and Parker (2005) on 
#     student evaluations of instructors' beauty and 
#     teaching quality for several courses at the
#     University of Texas. The teaching evaluations were 
#     conducted at the end of the semester, and the beauty 
#     judgments were made later, by six students who had
#     not attended the classes and were not aware of the 
#     course evaluations.

load(file = './TeachingRatings.rda')

#     a. Run a regression using beauty to predict course 
#        evaluations (eval), controlling for various other 
#        inputs. Display the fitted model graphically, and 
#        explaining the meaning of each of the coefficients. 
#        Plot the residuals versus fitted values.

head(TeachingRatings)

fit_eval = lm(eval ~ minority + age + gender + beauty, 
              data = TeachingRatings)

summary(fit_eval)

# We can plot the predicted regression line while controlling
# for covariates by holding values of the covariates constant

# Start by setting a range of values for beauty:
beauty_range = seq(min(TeachingRatings$beauty), 
                   max(TeachingRatings$beauty), .01) 

# Get values predicted for the fit_eval model, for white 
# males, who are average age in the sample:
pred_eval_m = predict(fit_eval, list(minority = rep('no', length(beauty_range)),
                                     age = rep(mean(TeachingRatings$age), length(beauty_range)), 
                                     gender = rep('male', length(beauty_range)),
                                     beauty = beauty_range))

# Same as above, but now repeating for white females
# who are average age in the sample:
pred_eval_f = predict(fit_eval, list(minority = rep('no', length(beauty_range)),
                                     age = rep(mean(TeachingRatings$age), length(beauty_range)), 
                                     gender = rep('female', length(beauty_range)),
                                     beauty = beauty_range))


par(mfrow = c(1, 1))
with(TeachingRatings, plot(beauty, eval,
                           xlab = 'Beauty Rating',
                           ylab = 'Teacher Evaluation'))
lines(beauty_range, pred_eval_m, col = 'blue',
      lwd = 3)
lines(beauty_range, pred_eval_f, col = 'red',
      lwd = 3)

# Another approach--we can use visreg from the visreg()
# package to control for other variables in the plot:
# install.package('visreg')
library(visreg)
visreg(fit_eval)

# As we saw earlier, we can get plots for our fitted model, 
# including a plot of residuals verus fitted values:
plot(fit_eval, which = 1) # We can use which = 1 to get 
                          # only the first plot


#     b. Fit some other models, including beauty and also 
#        other input variables. Consider at least one model 
#        with interactions. For each model, state what the 
#        predictors are, and what the inputs are (see Section 
#        2.1), and explain the meaning of each of its 
#        coefficients.

summary(lm(eval ~ students + tenure + division + beauty, 
           data = TeachingRatings))

summary(lm(eval ~ gender + credits + tenure + beauty, 
           data = TeachingRatings))

summary(lm(eval ~ age + gender + age*gender + beauty, 
           data = TeachingRatings))

# Focusing on the final model above, how would we interpret
# each of the coefficients?



## 6. The data wfw90.dat is from the Work, Family, and Well-
#     Being Survey (Ross, 1990). Pull out the data on earnings, 
#     sex, height, and weight.

dat = read.table('wfw90.dat', header = T)
head(dat)

#     a. Fit a linear regression model predicting earnings 
#        from height. What transformation should you perform 
#        in order to interpret the intercept from this model 
#        as average earnings for people with average height?

summary(lm(earnings ~ height, data = dat))

# Need to mean center height to make the intercept
# interpretable as the average earnings for someone 
# of average height.
dat$height_c = dat$height - mean(dat$height)
summary(lm(earnings ~ height_c, data = dat))

# Now, we interpret the intercept as the expected value
# for someone of average height. We see that this value
# is 2,400.76.

#     b. Fit some regression models with the goal of 
#        predicting earnings from some combination of sex, 
#        height, and weight. Be sure to try various 
#        transformations and interactions that might make 
#        sense. Choose your preferred model and justify.

summary(lm(earnings ~ sex + height + sex*height, data = dat))

summary(lm(earnings ~ height + weight + height*weight, data = dat))

dat$bmi = (dat$weight*.45)/((dat$height*.025)^2)

summary(lm(earnings ~ sex + bmi + sex*bmi, data = dat))

#     c. Interpret all model coefficients.

# How would we interpret the coefficients from the last 
# model we fit above?




## 7. An economist runs a regression examining the 
#     relations between the average price of cigarettes, 
#     P, and the quantity purchased, Q, across a large 
#     sample of counties in the United States, assuming 
#     the following functional form, log Q = alpha+beta log P.
#     Suppose the estimate for beta is 0.3. Interpret this 
#     coefficient.


# When the outcome is log-transformed, we know that we
# would interpret the slope as the percent change in the
# outcome for a one-unit change in x.


# When both the criterion and predictor variables are 
# log-transformed (as is true in our example above), the 
# relationship can be interpretted as the percent change 
# in y for a one-percent increase in x.


# So for our current example, an increase in the price of 
# cigarettes by 1% is associated with a 0.3% increase in the
# quantity of cigarettes purchased. 