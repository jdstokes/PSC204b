####################################################
##                                                ##
##                   204B Lab 6                   ##
##            MULTILEVEL LINEAR MODELS            ##
##                                                ##
##               Kristine O'Laughlin              ##
##                   Winter 2018                  ##
##                                                ##
####################################################



# TOPICS FOR TODAY
####################################################

# 1. Regression Inferences in R
#    a. Discrete Predictive Simulation
#    b. Continuous Predictive Simulation
# 
# 2. Multilevel Linear Models in R
#    a. Unconditional Growth Model
#    b. Individual Covariate Model


# Before we begin...
# Some packages to install for today:
install.packages('lme4')



# REGRESSION INFERENCES IN R
####################################################


## Discrete Predictive Simulation
#################################

# NOTE: REVIEWED FROM CLASS

# We know that the probability of that a baby is
# born a girl is 48.8%

# We can simulate 400 birth events using a binomial
# distribution:
n.girls = rbinom (1, 400, .488)
n.girls

# We could repeat this process 1000 times, to 
# get a sense of what this distribution would
# look like:
hist(rbinom(1000, 400, .488))


# Things become more complicated when we take into
# account that there are different types of births:
#     There is a 1/125 chance that a birth event 
#     results in fraternal twins
#          Of which each has an approximate 49.5%
#          chance of being a girl
#     There is a 1/300 chance of identical twins
#          Of which each has an approximate 49.5% 
#          chance of being girls


birth.type = sample(c("fraternal twin",
                      "identical twin",
                      "single birth"),
                      size = 400, replace = TRUE, 
                      prob = c(1/125, 1/300, 1 - 1/125 - 1/300))

girls = rep(NA, 400) # empty vector for girls

for (i in 1:400){
  
  if (birth.type[i] == "single birth"){
  
      girls[i] = rbinom (1, 1, .488)}

    else if (birth.type[i] == "identical twin"){
  
      girls[i] = 2 * rbinom (1, 1, .495)} 
  # Multiplied by 2, because if the twins are 
  # identical and girls then we have to add 2 girls
  
  else if (birth.type[i] == "fraternal twin"){
  
      girls[i] = rbinom(1, 2, .495)}
  
  # Number of trials is 2 because we could get a boy
  # and a girl fraternal twin
}

n.girls = sum(girls)
n.girls

# Now, we can repeat this process 1000 times to get a 
# sense of the uncertainty in this estimate:
n.sims = 1000

n.girls = rep(NA, n.sims)

for (s in 1:n.sims){

  for (i in 1:400){
    
    if (birth.type[i] == "single birth"){
      
      girls[i] = rbinom (1, 1, .488)}
    
    else if (birth.type[i] == "identical twin"){
      
      girls[i] = 2 * rbinom (1, 1, .495)} 
    
    else if (birth.type[i] == "fraternal twin"){
      
      girls[i] = rbinom(1, 2, .495)}
    
  }

    n.girls[s] <- sum(girls)
    
}

summary(n.girls)
sd(n.girls)
hist(n.girls)



## Continuous Predictive Simulation
###################################

# We can do the same thing with continous outcomes

sex = rbinom(10, 1, .52) # Selecting 10 at random
                         # 52% are female
sex

# Heights of men are distributed ~N(69.1, 2.9) in inches
# Heights of women are distributed ~N(63.7, 2.7) in inches
height = ifelse(sex == 0, 
                rnorm(10, 69.1, 2.9),
                rnorm(10, 63.7, 2.7))

avg.height = mean(height)
avg.height

# Now we can create a distribution of heights
# by repeating this 1000 times

n.sims = 1000
avg.height = rep(NA, n.sims)

for (s in 1:n.sims){
  
  sex = rbinom(10, 1, .52)
  height = ifelse(sex == 0, rnorm(10, 69.1, 2.9),
                  rnorm(10, 63.7, 2.7))
  avg.height[s] = mean(height)

  }


hist(avg.height, main = "Average height of 10 adults")

# Could also simulate for maximum heights: 
max.height = rep(NA, n.sims)

for (s in 1:n.sims){
  
  sex = rbinom(10, 1, .52)
  height = ifelse(sex == 0, rnorm(10, 69.1, 2.9),
                  rnorm(10, 63.7, 2.7))
  max.height[s] = max(height)
  
}

hist(max.height)


# It's generally cleaner to use functions in R...

# So we could just create a function to do this: 
Height.sim = function(n.adults, m.m, sd.m, m.f, sd.f){
  sex = rbinom(n.adults, 1, .52)
  height = ifelse(sex == 0, rnorm(n.adults, m.m, sd.m),
                    rnorm(n.adults, m.f, sd.f))
  mean(height)
}

avg.height = replicate(1000,
                        Height.sim(10, 69.5, 2.9, 64.5, 2.7))

hist(avg.height)



# MULTILEVEL LINEAR MODELS IN R
####################################################


# Multilevel models go by MANY different names and
# tend to vary by field--multilevel models, 
# hierarchical linear models, random effects models,
# mixed models, and so on...

# Don't get confused--these are all the same thing!


# We can use MLM to model longitudinal data because
# we can think of repeated measures as nested 
# within individuals.

# This model is statistically equivalent to the 
# growth curve model in structural equaiton 
# modeling.


# For this example we will be using data from the
# Wechsler Intelligence Scale for Children (WISC)

# We have repeated measures of children's verbal
# and performance scores on the WISC from grades 
# 1, 2, 4, and 6; we also have some covariates
# such as mother's education (among others)

setwd('C:/Users/Kristine/Dropbox/Winter2018/PSC204B/Labs2018')

wisc = read.csv('wisc3raw.csv', header = T)
head(wisc)

dim(wisc)
summary(wisc)


## Data Preparation
###################

# For lmer, data need to be read in long format,
# so we will start by reshaping the data:
long = reshape(wisc, 
               varying = list(c('verb1', 'verb2', 'verb4', 'verb6'),
                              c('perfo1', 'perfo2', 'perfo4', 'perfo6')),
               direction = 'long', timevar = 'time', idvar = 'id',
               v.names = c('verbal', 'perform'))

long = long[order(long$id), ]

head(long)

# Because our time intervals are not equally 
# spaced, I am also reassigning values for the
# time variable. 
long$time = rep(c(1, 2, 4, 6), nrow(long)/4)
long$time_c = long$time - 1



## Plot Data
############

# For this example, we will consider the performance
# factor of the WISC

# Start by plotting the raw data:
interaction.plot(long$time, # x-axis 
                 long$id, # grouping variable
                 long$perform, # y-axis
                 ylab = 'Performance', 
                 xlab = 'Grade', col = c(1:10), 
                 legend = F)



## Computing Intraclass Correlation Coefficient
###############################################

# We will be using lmer() from the lme4 package

# The model is specified similar to the lm()
# function. We start by defining the outcome followed
# by the tilde (~). Next, we define predictors 
# separated by "+". Next, random effects need to be
# provided in brackets ( ). The random predictors
# will go inside the brackets, followed by the |
# symbol, then the grouping variable.

# Make sure lme4 is loaded into your R library
library(lme4)

# Begin by fitting an intercept only model to the
# data:

nullmod = lmer(perform ~ 1 + (1 | id), 
               data = long)
summary(nullmod)


# ICC
29.65 / (29.65 + 230.92) # About 11% of variance
                         # due to differences 
                         # between individuals

230.92 / (29.65 + 230.92) # About 89% of variance
                          # due to differences 
                          # within individuals


# Next, fit the unconditional linear growth
# model.

## WHAT ARE THE LEVEL 1 AND LEVEL 2 EQUATIONS FOR
## THE UNCONDITIONAL LINEAR GROWTH MODEL?

mod0 = lmer(perform ~ time_c + (time_c | id), 
            data = long)
summary(mod0)



# Adding time-invariant individual-level covariate

# If we were to leave mother's education in its raw
# form, our interpretation for the fixed effects would
# be for individual's with mother's education equal
# to 0

# To make this interpretation more reasonable, instead
# we can grand-mean center mother's education:
long$momed_gm = long$momed - mean(long$momed)

# Now our fixed effects apply to average mothers'
# education in the sample.

# Things become more complicated for time-varying
# predictors!


# Let's fit the model, adding the covariate


## WHAT ARE THE LEVEL 1 AND LEVEL 2 EQUATIONS HERE?


# Random slope for time only
mod1 = lmer(perform ~ time + momed_gm + 
            (time | id), 
            data = long)
summary(mod1)

# Random slope for time and momed only
mod2 = lmer(perform ~ time + momed_gm + 
            (time + momed_gm| id), 
            data = long)
summary(mod2)


# Compare AICs:
AIC(nullmod); AIC(mod0); AIC(mod1); AIC(mod2)


# You could then consider adding additional predictors
# in your model to help further reduce the residual
# variance in your model

plot(data = long, perform ~ time, type = 'n', 
     ylim = c(min(long$perform), max(long$perform)),
     xlim = c(min(long$time_c),max(long$time_c)),
     cex.main = .75,
     xlab = 'Grade', 
     ylab = "WISC Performance",
     main = "Variability in Slope and Intercepts- Individual")


fix = fixef(mod1)
rand = ranef(mod1)
parmsIndiv = cbind((rand$id[1] + fix[1]), (rand$id[2] + fix[2]))


# Plot individual trajectories
for(i in 1:length(unique(long$id))){
  
  abline(a = parmsIndiv[i, 1], b = parmsIndiv[i, 2],
         col = 'lightblue')
  
  par = par(new=F)
  
}

# Adding mean trajectory
abline(a = fix[1], b = fix[2], lwd = 2,col = 'red')
