
# Lab 3 getting started with logistic regression

# Jumping right in. Let's compare a simple linear reg to 
# log reg
###########################################################
library(ggplot2)
library(dplyr)
library(pander)

# Load the mt cars datset. We're just going to use vs (V/S Engine configuarion) 
#and mpg 
data(mtcars)
head(mtcars)

# linear regression
fit_lm  = lm(vs ~ mpg, data = mtcars)

# logistic regression
fit_glm <- glm(vs ~ mpg, data = mtcars, family = binomial)

#Note: Also, glm is a less specific version of lm(). Ordinary linear regression can also be fit with
#glm(admit ~ gre, data = admit) with the family argument specified to gaussian as default


# With just one predictor, we can plot our models and compare them. 
###########################################################

x_pred <- seq(from=min(mtcars$mpg), to=max(mtcars$mpg),length.out=100)

plot(vs ~ mpg, data = mtcars, 
     pch = 20, ylab = "Estimated Probability", 
     main = "Ordinary vs Logistic Regression")

abline(fit_lm, col = "darkorange")

y_probs <- predict(fit_glm,data.frame(mpg = x_pred),type = "response")

lines(x_pred,y_probs, col = "dodgerblue", lty = 2)

legend("topleft", c("Ordinary", "Logistic", "Data"), lty = c(1, 2, 0), 
       pch = c(NA, NA, 20), lwd = 2, col = c("darkorange", "dodgerblue", "black"))

# Here's how to plot the log reg curve in ggplot

# ggplot(mtcars, aes(x=mpg, y=vs)) + geom_point() + 
#   stat_smooth(method="glm", method.args=list(family="binomial"), se=FALSE)

# -Note that the logistic regression predictions are neither greater than one or less than zero.

# Let's use the summary() routine to take a look at our log reg model
###########################################################

summary(fit_glm)

# -Remember, ur predictor is in Logit units. 
# -Deviance is a measure of the goodness of fit. Higher deviance indicates worse fit.
# -R reports two forms of deviance – the null deviance and the residual deviance. The null deviance shows how well the response variable is predicted by a model that includes only the intercept (grand mean).
# -If your Null Deviance is really small, it means that the Null Model explains the data pretty well. Likewise with your Residual Deviance.
# -The Fisher scoring algorithm is related to the maximum likelihood method used to fit this model. We won't worry about that today.


# Self reported gaming experience:
# Here's some navigation data from my lab, that I will tell you about..right now
########################################

# You can download off of Canvas (week 4)
d <- read.csv("https://raw.githubusercontent.com/jdstokes/PSC204b/master/data/YSPdata.csv", header = TRUE, na.strings = "")

# Just need to clean up some missing values
gameEXP <- data.frame(d$ExprVG,d$withdrew,d$"Sex")
colnames(gameEXP) <- c("gameEXP","withdrew","Sex")
gameEXP <- gameEXP[which(!is.na(gameEXP$gameEXP) & gameEXP$withdrew != -99),]

# Logistic regression with no predictors
########################################
model0 <- glm(withdrew ~ 1, 
family="binomial"(link="logit"), data = gameEXP)
coef(model0)

# We get an intercept of -0.6506 logits of study withdrawal. 
# What does this mean? Well let's convert it to probability

intercept.logit <- as.vector(coef(model0))
odds <- exp(intercept.logit)
prob = odds / (1 + odds)
prob

mean(gameEXP$withdrew)


# Logistic regression with a single dichotomous 
# predictor variable
########################################


# Frequency table and more
T<-gameEXP %>%
group_by(Sex,withdrew) %>%
summarise(freq=n()) %>%
mutate(all=sum(freq),prob=freq/all,odds=prob/(1-prob),logodds=log(odds)) %>%
round(.,5)
pander(T)

# Let's rerun our log reg but with binary predictor
model1 <- glm(withdrew ~ Sex, 
              family="binomial"(link="logit"), data = gameEXP)
summary(model1)

odds_WD_Sex1 <- (8/17)/(9/17)
odds_WD_Sex0 <- (4/18)/(14/18)
odds_ratio <- odds_WD_Sex1/odds_WD_Sex0 #Remember, odds ratio of 1 means a 50/50 chance
log(odds_ratio) 

predSex1 <- coef(model1)[1] + 1*coef(model1)[2]
predSex0 <- coef(model1)[1] + 0*coef(model1)[2]

predSex1_prob <- exp(predSex1)/(1+exp(predSex1))
predSex0_prob <- exp(predSex0)/(1+exp(predSex0))

#A difference in gender corresponds to a positive difference of _______ in the probability of withdrawing from the study
predSex1_prob - predSex0_prob


# Logistic regression with a single continuous 
# predictor variable
########################################

# model for game experience
model2 <- glm(withdrew ~ gameEXP, 
              family="binomial"(link="logit"), data = gameEXP)

# Output model coefficients etc.
summary(model2)

# Convert game experience logit coefficient to odds ratio using inverse logit function
odds_ratio <- exp(coef(model2)[2])/(1+exp(coef(model2)[2]))

#         Interpreation: For every one unit increase in game experience, 
#         we expect 2/3 less likely withdrawal


# We can evaluate how the probability differs with a unit difference in x near the central value (Gelman & Hill)
xVals <- seq(1,5,by = 0.25) # Generate x values
logit  <- coef(model2)[1]+coef(model2)[2]*xVals #Logit prediction
oddsWithdraw     <- exp(logit) # exponetiate to get the odds of dropout from logOdds
probWithdraw     <- oddsWithdraw/(1+oddsWithdraw) # odds/1+odds = probability
logOddsWithdraw  <- log(probWithdraw/(1-probWithdraw)) # Here's how we could transform back logit, just because


predict(model2,newdata = data.frame(gameEXP=xVals),type = "response")

#Let's subtract the predicted probability with 2 units of experience from the predicted probability with 2 units of experience
probWithdraw[5] - probWithdraw[9]

#         Interpretation: For a one unit increase in game experience,
#         we'd expect a 16% percent difference in probability of leaving the study


# We can see how well the model fits
with(model2, null.deviance - deviance)

# Differences in degrees of freedom
with(model2, df.null - df.residual)

# We can use a chi square test to find out if our model fits better than the null. This will return a p value.
with(model2, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE))


par(mfrow=c(1,3))

# plot probabilities
plot(gameEXP$gameEXP,gameEXP$withdrew,
     main="Probability: VR-Sickness -- Gaming EXP",
     xlab = c("Gaming Experience"),ylab = c("Probability of Withdrawal"))
points(xVals,probWithdraw,pch=16,col="green")
abline(h=0.5,col="blue")
abline(v=xVals[which.min(abs(probWithdraw-0.5))],col="blue")

# plot odds
plot(xVals,oddsWithdraw,pch=16,col="red",
     main="Odds: VR-Sickness -- Gaming Exp",
     xlab = c("Gaming Experience"),ylab = c("Odds of Withdrawal"),ylim = c(0,3))
abline(h=1,col="blue")
abline(v=xVals[which.min(abs(oddsWithdraw-1))],col="blue")

# plot log odds
plot(xVals,logOddsWithdraw,pch=16,col="black",
     main="Linear Logit Transform (Gaming Exp)",
     xlab = c("Gaming Experience"),ylab = c("Log-Odds of Withdrawal"),ylim = c(-2.5,1.5))
abline(h=0,col="blue")
abline(v=xVals[which.min(abs(logOddsWithdraw))],col="blue")

