
##########################################
# Part I

# 1.
# library(dplyr)

GetMaleAdhd = function(){
  subNames =c('IA','HI','IA_HI')
  probSub=c(.075*0.5*.684,.075*0.25*.632,.075*0.25*.821)
  probNon = 1 - sum(probSub)
  subSim = sample(c(subNames,'non'), 10000, replace=TRUE, prob=c(probSub,probNon))
  return(list(IA = sum(subSim == "IA"),HI = sum(subSim == "HI"), IA_HI = sum(subSim == "IA_HI"),non = sum(subSim == "non")))
}

simData = do.call("rbind", replicate(1000, data.frame(GetMaleAdhd()), simplify = FALSE))

# Mean number of males in each subtype. non = mean number of children without adhd + females with adhd
colMeans(simData)

# 2.
GetCT = function(){
  n = 100
  nDem = rbinom(1,n,1/14)
  nNon = n - nDem
  return(mean(c(rnorm(nDem,2.5,.7),rnorm(nNon,1.25,.4))))
}
hist(replicate(1000,GetCT()),main="Mean cortical thickness (population > 65 years of age)",xlab = "sample mean")

# Bonus
library(boot)
data(swiss)

# linear model
fit = lm(formula=Fertility~Agriculture,data=swiss)

# confidence intervals
confint(fit)

# bootstrap
bs_slope <- function(formula,data,indices){
  d <- data[indices,] # allows boot to select sample 
  fit <- lm(formula, data=d)
  return(coef(fit)[2])
}

bs_aic <- function(formula,data,indices){
  d <- data[indices,] # allows boot to select sample 
  fit <- lm(formula, data=d)
  return(AIC(fit))
}

# bootstrap agriculture coef
results.slope <- boot(data=swiss, statistic=bs_slope, 
                R=1000, formula=Fertility~Agriculture)
boot.ci(results.slope, type="bca", index=1)

# bootstrap AIC
results.aic <- boot(data=swiss, statistic=bs_aic, 
                      R=1000, formula=Fertility~Agriculture)
boot.ci(results.aic, type="bca", index=1)


##########################################
# Part II
library(foreign)
hsb = read.spss('/Users/jdstokes/repos/204b/data/hsb.sav', to.data.frame = TRUE)
hsb$school = factor(hsb$school)
# 1.
# take a random sample
dat <- hsb[sample(1:nrow(hsb), 50,replace=FALSE),]

# plot achievement againste SES
plot(dat$ses,dat$mathach,xlab='SES',ylab='match achievement',col=dat$school)

library(ggplot2)
qplot(ses,mathach,data=dat,colour=factor(school))

# 2.

library(lme4)
library(reshape2)


nullmod = lmer(mathach ~ 1 + (1 | school), 
               data = hsb)
summary(nullmod)

# ICC. Tells us amount of variance in mathach due to between school differences
8.614/(8.614+39.148)

# 3. 

# 4. 

# fixed effects only. we've seen this before.
fit.lm = glm(formula = mathach ~ ses,data = hsb)
fit.lm

# Simple random effects model. It will estimate the average math
# achievment score but will allow math achievement to vary 
# between school. 
fit.null = lmer(mathach ~ 1 +  (1 | school), data = hsb)
summary(fit.null)

# We can also access the estimated deviation between each school
# and the average math achievement score
ranef(fit.null)

#to get the fitted average mathach for each school
mathach_school <- fixef(fit.null) + ranef(fit.null)$school
mathach_school$school<-rownames(mathach_school)
names(mathach_school)[1]<-"Intercept"
reaction_subject <- mathach_school[,c(2,1)]
#plot
ggplot(mathach_school,aes(x=school,y=Intercept))+geom_point()

# random intercept model
fit.rnd.int = lmer(mathach ~ 1 + ses +  (1 | school), data = hsb)
# matach_slp <- as.data.frame(t(apply(ranef(fit.rnd.int)$school,
#                                       1,function(x) fixef(fit.rnd.int) + x)))

mathach_slp <- data.frame(ranef(fit.rnd.int)$school) + fixef(fit.rnd.int)[1]
mathach_slp$ses <- fixef(fit.rnd.int)[2]

hsb_small <-hsb %>%
  filter(school %in% rownames(mathach_slp[1:5,]))
ses_seq <- seq(min(hsb_small$ses),max(hsb_small$ses),length.out=10)

pred_slp <- melt(apply(matach_slp[1:5,],1,function(x) x[1] + x[2]*ses_seq),
                 value.name = "mathach")

pred_slp[,1] = rep(ses_seq,5)
#some re-formatting for the plot
names(pred_slp)[1:2] <- c("ses","school")
pred_slp$school <- as.factor(pred_slp$school)

# plot with actual data
ggplot(pred_slp,aes(x=ses,y=mathach,color=school))+
  geom_line() +
  geom_point(data=hsb_small,aes(x=ses,y=mathach))

# random slopes model
fit.rnd.slopes = lmer(mathach ~ 1 + ses +  (1 + ses | school), data = hsb)
n = 10
mathach_slp <- as.data.frame(t(apply(ranef(fit.rnd.slopes)$school,
                                       1,function(x) fixef(fit.rnd.slopes) + x)))

hsb_small <-hsb %>%
  filter(school %in% rownames(mathach_slp[1:n,]))
ses_seq <- seq(min(hsb_small$ses),max(hsb_small$ses),length.out=10)

pred_slp <- melt(apply(mathach_slp[1:n,],1,function(x) x[1] + x[2]*ses_seq),
                 value.name = "mathach")

pred_slp[,1] = rep(ses_seq,n)
#some re-formatting for the plot
names(pred_slp)[1:2] <- c("ses","school")
pred_slp$school <- as.factor(pred_slp$school)

# plot with actual data
ggplot(pred_slp,aes(x=ses,y=mathach,color=school))+
  geom_line() +
  geom_point(data=hsb_small,aes(x=ses,y=mathach))

# Compare AICs:
AIC(fit.lm); AIC(fit.null); AIC(fit.rnd.int); AIC(fit.rnd.slopes)

# Could calc AIC as follows
logLikelihood = logLik(fit.rnd.slopes)
deviance = -2*logLikelihood[1]; 
p = 5# 
deviance + 2*(p+1) 

# Compare to full
anova(fit.rnd.slopes,fit.rnd.int,fit.null,fit.lm)

# 5.
hsb$ses_grand = scale(hsb$ses,scale=FALSE)
hsb$ses_group = scale(hsb$ses - hsb$meanses,scale=FALSE)

fit.ses = lmer(mathach ~ 1 + ses +  (1 + ses | school), data = hsb)
fit.ses_grand = lmer(mathach ~ 1 + ses_grand +  (1 + ses_grand | school), data = hsb)
fit.ses_group = lmer(mathach ~ 1 + ses_group +  (1 + ses_group | school), data = hsb)
fit.ses_group_b = lmer(mathach ~ 1 + ses_group + meanses +  (1 + ses_group | school), data = hsb)
fit.ses_group_unc = lmer(mathach ~ 1 + ses_group + meanses +  (1 | school) + (0 + ses_group | school), data = hsb)

AIC(fit.ses)
AIC(fit.ses_grand)
AIC(fit.ses_group)
AIC(fit.ses_group_b)
AIC(fit.ses_group_unc)
anova(fit.ses_group_b,fit.ses_group,fit.ses_grand,fit.ses)
anova(fit.ses_group_b,fit.ses,fit.ses_group_unc)

# 6.
library(lmerTest)
summary(fit.ses_group)
# The SES fixed effect suggests that a one unit increase in SES from the school averages would predict a 2.19 increase in math achievement. 
# Fixed effect intercept represents the predicted average math score when SES is set to zero.
# School intercepts represent predicted math score value added to the mean from for each school.

# Extra credit
hsb$size = scale(hsb$size,scale=FALSE)
fit.int = lmer(mathach ~ 1 +size+ ses_group*size + meanses+ (1 + ses_group| school), data = hsb)
summary(fit.int)
AIC(fit.int)
anova(fit.ses_group_b,fit.int)