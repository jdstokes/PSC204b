####################################################
##                                                ##
##                   204B Lab 4                   ##
##          LOGISTIC REGRESSION AND GLM           ##
##                                                ##
##               Kristine O'Laughlin              ##
##                   Winter 2018                  ##
##                                                ##
####################################################


# Install and load the 'titanic' package into your R 
# library using the following code: 
  
#install.packages('titanic')
library(titanic)

# You will also need to combine the test and training
# datasets in order to get the complete dataset for 
# this example:
  
data('titanic_train')
data('titanic_test')
titanic_test$Survived = NA
complete_data = rbind(titanic_train, titanic_test)

# And then subsetting the variables we will be using 
# for this homework assignment:
  
titanic_dat = complete_data[, c('Survived', 'Sex', 'Age',
                                'Fare')]

# You will use this dataset to answer the following
# questions.

head(titanic_dat)



# Question 1
############

# Report the summary statistics for the titanic_dat
# dataset (i.e., report means, standard deviations, 
# number of missing values). (Hint: this may be 
# important for a later question on this homework!)


# Get descriptives for continuous variables:
means = sapply(titanic_dat[, 3:4], mean, na.rm = T)
sds = sapply(titanic_dat[, 3:4], sd, na.rm = T)
nas = colSums(sapply(titanic_dat[3:4], is.na))
descrip = matrix(c(means, sds, nas), nrow = 2, 
                 ncol = 3)
colnames(descrip) = c('Mean', 'SD', 'Missing')
rownames(descrip) = c('Age', 'Fare')

# Get desriptives for categorical variables:
survivalcount = table(titanic_dat$Survived)
survivalnas = sum(sapply(titanic_dat[1], is.na))
survival = matrix(c(survivalcount, survivalnas), 
                  nrow = 3, ncol = 1)
rownames(survival) = c('Perished', 'Survived', 
                       'Missing')
colnames(survival) = 'Count'

gendercount = table(titanic_dat$Sex)
gendernas = sum(sapply(titanic_dat[2], is.na))
gender = matrix(c(gendercount, gendernas), 
                nrow = 3, ncol = 1)
rownames(gender) = c('Female', 'Male', 'Missing')
colnames(gender) = 'Count'

# Print all descriptives in a list
list(descrip, survival, gender)
 


# Question 2
############

# Run a logistic regression to predict whether 
# passengers' survival (Survived [levels: 1 = 
# survived; 0 = perished]) is predicted by cost of 
# fare paid by passengers (Fare). Write out the 
# logistic regression model that you have just fit. 

fit0 = glm(Survived ~ Fare, family = binomial, 
           data = titanic_dat)
summary(fit0)


# Regression Model:
# log(p_hat / (1 - p_hat)) = b_0 + b_1 * Fare



# Question 3
############

# Interpret each coefficient from the analysis 
# above in terms of both odds-ratios and 
# probabilities.


# Setting plotting parameters
par(mfrow = c(1, 3))

# Creating a range of x values
x_range = seq(min(titanic_dat$Fare, na.rm = T), 
              max(titanic_dat$Fare, na.rm = T),
              .01)

logit = coef(fit0)[1] + coef(fit0)[2] * x_range # Logits prediction
odds = exp(logit) # Odds prediction
prob = odds / (1 + odds) # Predicted Probability

# Plot predicted probabilities (sigmoidal)
plot(titanic_dat$Fare, titanic_dat$Survived, 
     ylab = "P(Survival)", xlab = 'Fare',
     main = "Predicted Probability")
points(x_range, prob, pch = 16, col = "green")

# Plot odds (multiplicative)
plot(x_range, odds, pch = 16,col = "red",
     xlab = 'Fare', ylab = "Odds of Survival",
     main = 'Odds')

# Plot log odds (linear)
plot(x_range, logit, col = "black",
     xlab = 'Fare', ylab = 'Log Odds of Survival',
     main = 'Log Odds')


# To get to odds-ratios, we can take the exponential
# of our coefficients:
exp(coef(fit0))

# B0: When cost of fare is 0 (probably not meaningful),
#     the odds of survival are 0.39.

# B1: For every one-unit increase in the price of fare
#     to be a passenger on the Titanic, the odds of 
#     survival increase by a factor of 1.02. So for 
#     each unit increase in fare, the odds
#     of survival are multiplied by 1.02.


# To interpret using probabilities:
exp(coef(fit0)) / (1 + exp(coef(fit0)))

# B0: Predicted probability of survival is .28 if fare 
#     is equal to 0 (again, probably not meaningful)

# B1: We could intepret this different ways, for example
#     we might interpret the predicted probability for the 
#     mean value of fare:
mean(titanic_dat$Fare, na.rm = TRUE)

predict(fit0, list(Fare = mean(titanic_dat$Fare, na.rm = TRUE)),
        type = 'resp')
#     type = 'resp' will return predicted probabilities

#     And we see that the predicted probability for
#     a passenger who paid the average price of fare
#     had a .39 probability of survival



# Question 4
############

# Plot the observed data with the logistic curve 
# overlaid on the scatterplot.

# Setting plotting parameters
par(mfrow = c(1, 1))

with(titanic_dat, plot(Fare, Survived))

curve(predict(fit0, data.frame(Fare = x), type = 
              'resp'), add = T, col = 'red', lwd = 2)



# Question 5
############

# Evaluate the fit of your logistic regression 
# model (hint: see slides 50-54).


# Error rate is defined as the proportion of cases 
# for which the deterministic prediction is wrong

# So, if the model predicts a probability greater
# than .5 (greater than chance survival rate), but
# the passenger actually perished, then this is 
# counted as error.

# Likewise, if the model predicts a probability
# less than .5 (less than chance survival rate),
# but the passenger actually survived, then this
# is also counted as error.

# Here, we run into an issue due to missing values.
# If you try to run this using the analyses conducted
# above:
mean((fitted(fit0) > 0.5 & titanic_dat$Survived == 0) |
     (fitted(fit0) < 0.5 & titanic_dat$Survived == 1))
# ...you'll get NA because missing values were dropped
# when you fit the model, but they are still included
# in the original data set

# To get around this, we are going to create a complete
# dataset with no missing values and then re-run our
# analysis:
titanic_sub = titanic_dat[complete.cases(titanic_dat), ]

# Now rerun the model with complete data:
mod0 = glm(Survived ~ Fare, family = binomial, 
           data = titanic_sub)

# Now, we can evaluate the fit of our model:
mean((fitted(mod0) > 0.5 & titanic_sub$Survived == 0) |
     (fitted(mod0) < 0.5 & titanic_sub$Survived == 1))

# So our error rate is 0.33. This is not great, 
# but is better than chance (0.5)

# We can also compare this to a null model:
modnull = glm(Survived ~ 1, family = binomial, data = titanic_sub)
mean((fitted(modnull) > 0.5 & titanic_sub$Survived == 0) |
     (fitted(modnull) < 0.5 & titanic_sub$Survived == 1))

# ...and we're doing slightly better than the
# null model which has an error rate of .41.


# We can also evaluate model deviance--a statistical
# summary of model fit, defined for generalized
# linear models to be an analogy to residual
# standard deviation

# Deviance is a measure of error: lower deviance
# means better fit to the data

# If a predictor that is simply random noise
# is added to a model, we expected deviance to
# decrease by 1, on average

# When informative predictor is added to a model,
# we expect deviance to decrease by more than 1. 
# When k predictors are added to a model, we 
# expect deviance to decrease by more than k.


# For models that are not multilevel, deviance
# is equal to -2 * log(likelihood function)

summary(mod0)

# Null deviance (model including intercept only)
# is 964.52 on 713 degrees of freedom

# Residual deviance (model adding in fare) is 
# 901.25 on 712 degrees of freedom

# Deviance has decreased by 
964.52 - 901.25 # which is more than we would 
                # expect if the predictor
                # had been just noise.


# We can also evaluate AIC, which allows us to 
# compare models while applying a penalty
# for model complexity (penalty is equal to 
# +2p with p = k + 1)


summary(mod0)$deviance + 2 * (1 + 1)

# And this matches what we saw in our output:
summary(mod0)

summary(modnull)

# When evaluating AIC, lower is better and we
# see that the model including the predictor
# has a lower AIC value than does the null model



# Question 6
############

# Imagine that you have just remembered that women 
# and children were given priority in boarding 
# lifeboats. Repeat your logistic regression, this 
# time adding in additional predictors of Age and 
# Sex [levels: male; female]. Include an appropriate 
# interaction term.


fit1 = glm(Survived ~ Fare + Age + Sex + Age*Sex, 
           family = binomial, data = titanic_dat)
summary(fit1)



# Question 7
############

# Interpret all coefficients from the analysis above
# in terms of both odds-ratios and probabilities.


# Odds Ratios:
exp(coef(fit1))

# B0: The predicted odds of survival for a female at age 0
#     and Fare equal to 0 is 1.37 (probably not meaningful)

# B1: For every one-unit increase in the price of fare,
#     the odds of survival increase by a factor of 1.01,
#     when holding the other predictors constant. 

# B2: For every one-year increase in age, the odds of of 
#     survival increase by a factor of 1.01, when holding
#     the other predictors constant

# B3: This is the ratio of survival between males and
#     females. Odds of Male Survival/Odds of Female Survival
#     is about .27.
#     So, males are about 1/4 as likely to survival as 
#     females, when holding the other predictors constant.
#     We can reverse this ratio to make it more interpretable
#     (i.e., compute the odds of female survival/odds of male
#     survival) by dividing 1 by the coefficient like so:

1 / exp(coef(fit1)[4]) # And we see that females were about 
                       # 3.69 times more likely to survive
                       # than males

# B4: Interaction between Sex and Age. This coefficient indicates
#     that for each additional year of Age, the odds of survival
#     change by a factor of 0.96 for males. Stated differently,
#     for every additional year of age, males odds of survival
#     decrease by...
1 / exp(coef(fit1)[5]) # ...a factor of 1.04, when holding the 
                       # other predictors constant


# Probabilities:
exp(coef(fit1)) / (1 + exp(coef(fit1)))

# B0: The predicted probability of survival for a female at age 0
#     and Fare equal to 0 is .58 (probably not meaningful)

# B1 & B2: We could just get the predicted probabilities when
#          Fare and Age are set to their mean:

predict(fit1, list(Fare = mean(titanic_dat$Fare, na.rm = TRUE),
                   Age = mean(titanic_dat$Age, na.rm = TRUE),
                   Sex = 'male'), type = 'resp') 
#          ...and we get a predicted probability of Survival 
#          of .21 for a male of average age and cost of fare

#          We could also look at differences in predicted 
#          probabilities between different points along the
#          range of predictors

#          Let's compute the predictive difference with respect
#          to Age at the average value of Age and 0 Fare for males

age.mean.pred = predict(fit1, list(Fare = 0,
                Age = mean(titanic_dat$Age, na.rm = TRUE),
                Sex = 'male'), type = 'resp')

age.plus1.pred = predict(fit1, list(Fare = 0,
                 Age = (mean(titanic_dat$Age, na.rm = TRUE) + 1),
                 Sex = 'male'), type = 'resp')

age.mean.pred - age.plus1.pred

# In the Gelman and Hill text, they point out that the divide by 4
# rule gives you a good estimate of the predicted difference for a 
# one unit change in the predictor

coef(fit1)[3] / 4 # and we see that the estimate is fairly similar to 
                  # what we got above

#          So, for males who paid a fare of 0, each 
#          additional year of age made a 0.3% positive difference
#          in probability of survival.


# B3: We can get the difference in predicted probabilites betwee
#     males and females who paid 0 fare, at age 0:

Male = predict(fit1, list(Fare = 0,
                          Age = 0,
                          Sex = 'male'), type = 'resp')

Female = predict(fit1, list(Fare = 0,
                            Age = 0, 
                            Sex = 'female'), type = 'resp')
Male - Female

#     And we see that males who paid 0 fare, and are age 0, 
#     decreased by about 30.7% in probability of survival
#     relative to females

# B4: Interaction between Sex and Age. This makes my head 
#     explode, so we're probably best sticking to explaining
#     this relationship in terms of odds here :) 
#     (Also, see plot at end)



# Question 8
############

# Use the predict() function to determine the odds 
# of your own survival had you been a passenger on 
# the Titanic (you can use the mean value for Fare). 
# Note that predict() returns the predicted values 
# at the linear scale, i.e., on the logit scale. 


predict(fit1, list(Fare = mean(titanic_dat$Fare, na.rm = T),
                               Age = 31,
                               Sex = 'female'), type = 'resp')


# Your TA's predicted probability of survival on
# the Titanic would be .76. (Woo?)



# Question 9
############

# We mentioned that missing values may be important
# to note early in this assignment...this is because
# the likelihood ratio test will not work if your
# models 

# Let's look at how  missing data is handled in lm()
?glm # So glm() by default will use na.omit

# So different numbers are being excluded from each of
# our two models


# Now rerun the models with complete data:
mod0 = glm(Survived ~ Fare, family = binomial, 
           data = titanic_sub)
mod1 = glm(Survived ~ Fare + Age + Sex + Age*Sex, 
           family = binomial, data = titanic_sub)

# install.packages('lmtest')
library(lmtest)

lrtest(mod0, mod1)


anova(mod0, mod1, test = 'Chisq')



# BONUS
#######

# Create a plot to illustrate the interaction effect
# found in question 6.  

summary(fit1)

# Save coefficients
b0 = fit1$coef[1]    # intercept
Fare = fit1$coef[2]  # slope for Fare
Age = fit1$coef[3]   # slope for Age
male = fit1$coef[4]  # slope for Sex
AgeSex = fit1$coef[5]# slope for interaction

# Create a range of ages for plotting
Age_range = seq(min(titanic_dat$Age, na.rm = T), 
                max(titanic_dat$Age, na.rm = T), .01)

# Set Fare to be equal to the mean
Fare_val = mean(titanic_dat$Fare, na.rm = T)

# Equation for females in logits:
female_logits = b0  + Age * Age_range + Fare * Fare_val + 
                male * 0 + AgeSex * Age_range * 0 
                # Note that these last two terms drop
                # out of the equation

# Equation for males in logits:
male_logits = b0 + Age * Age_range + Fare * Fare_val +
              male * 1 + AgeSex * Age_range * 1
              # Now the last two terms are included

# Convert from logits to probability scale
Female = exp(female_logits) / (1 + exp(female_logits))
Male = exp(male_logits) / (1 + exp(male_logits))

# Plot the age range against predicted probabilities
# for females
plot(Age_range, Female, ylim = c(0, 1), type = 'l',
     lwd = 3, lty = 2, col = 'orangered', xlab = 'Age',
     ylab = 'P(Survival)', 
     main = 'Probability of Survival on the Titanic')

# Add in the predicted probabilities for males
lines(Age_range, Male, type = 'l',
      lwd = 3, lty = 3, col = 'turquoise2')

# Add a legend to the plot
legend('topleft', c('Female', 'Male'), col = 
       c('orangered', 'turquoise2'), lwd = 3,
       lty = c(2, 3), horiz = T)