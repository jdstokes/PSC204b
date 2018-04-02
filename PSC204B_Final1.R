library(lme4)
library(multcomp)
library(ggplot2)


#rm(list=ls()) 
options(scipen=999)
setwd('/Users/MichaelCarter/Desktop/PSC204B_W18')

################################################################################
#read in data
emo.dat = dat <- read.csv('emotion.csv',header = TRUE)

###plot data ################################################
###########################################################
xyplot(pa_gral ~ DAY, groups = ID_INDIV, 
       type = 'l', data = emo.dat)
#sample 150 random students (i.e.,rows) from the dataset 
sample = emo.dat[emo.dat$ID_INDIV %in%sample(unique(emo.dat$ID_INDIV), 10, replace = FALSE),]
head(sample)
######## ## 
par(mfrow = c(2, 2))
#plot pos aff
xyplot(pa_gral ~ DAY, groups = ID_INDIV, 
       type = 'l', data = sample, ylab = "Figure 1. Positive Affect", xlab = "Day")

xyplot(pa_gral_dt ~ DAY, groups = ID_INDIV, 
       type = 'l', data = sample, ylab = "Figure 2. Positive Affect Detrended", xlab = "Day")

xyplot(pa_gral + pa_gral_dt ~ DAY, groups = ID_INDIV, 
       type = 'l', data = sample)
#plot neg aff
xyplot(na_gral ~ DAY, groups = ID_INDIV, type = 'l', data = sample, ylab = "Figure 3. Negative Affect", xlab = "Day")

xyplot(na_gral_dt ~ DAY, groups = ID_INDIV, type = 'l', data = sample, ylab = "Figure 4. Negative Affect Detrended", xlab = "Day")

xyplot(na_gral + na_gral_dt ~ DAY, groups = ID_INDIV, 
       type = 'l', data = sample)
?xyplot()

xyplot(V1RelSat ~ DAY, groups = ID_INDIV, type = 'l', data = sample, ylab = "Relationship Satisfaction", xlab = "Day")

dim(sample.emo)
xyplot(pa_gral ~ DAY, groups = ID_INDIV, 
       type = 'l', data = sample.emo)
#plot predictor varaibles 
xyplot(na_gral ~ DAY, groups = ID_INDIV, 
       type = 'l', data = sample.emo)
#
xyplot(V1RelSat ~ DAY, groups = ID_INDIV, 
       type = 'l', data = sample.emo)

xyplot(GENDER ~ DAY, groups = ID_INDIV, 
       type = 'l', data = sample.emo)

#You are then going to predict positive affect with negative affect and you will 
#also include gender and relationship satisfaction as explanatory variables.
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ MODELS
#mod1 person mean centered 
mod1 = lmer(pa_gral ~ na_gral_pc + na_gral_b + GENDER + V1RelSat_pc + V1RelSat_b + (1| ID_INDIV), data = emo.dat)
summary(mod1)
head(emo.dat)
#mod2 not centered
mod2 = lmer(pa_gral ~ na_gral +  GENDER + V1RelSat + (1|ID_INDIV), data = emo.dat) 
summary(mod2)
#mod3 no predictors null
mod3 = lmer(pa_gral ~ (1|ID_INDIV), data = emo.dat)
summary(mod3)
anova(mod3, mod1, mod2)
#mod4 time detrended in outcome only 
mod4 = lmer(pa_gral_dt ~ na_gral + avgnegaff + GENDER + V1RelSat +
                 (1|ID_INDIV), data = emo.dat) 
#mod4 time detrended in outcome and predictor 
mod5 = lmer(pa_gral_dt ~ na_gral_dt + avgnegaff + GENDER + V1RelSat +
              (1|ID_INDIV), data = emo.dat) 

AIC(mod3); AIC(mod2); AIC(mod1); AIC(mod4); AIC(mod5)
anova(mod1, mod2, mod3, mod4)
anova(mod4, mod5)
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#install.packages("predictedmeans")
library(arm)
#install.packages("arm")
sjp.setTheme("forestgrey") # plot theme
sjp.lmer(mod5, type = "fe")
#install.packages("nlme")
library(nlme)
library(ggplot2)
emo.dat$fit5 <- predict(mod5)

## pdf(file = '../../Repo/figures/cebu9.pdf', width = 5, height = 6)
ggplot(emo.dat, aes(na_gral_dt, fit5, group=ID_INDIV, col=ID_INDIV )) + 
  geom_line(show.legend=FALSE)+
  geom_point(aes(y = pa_gral_dt), alpha = 0.3, show.legend=FALSE) +
  theme_bw()

head(emo.dat)
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
xyplot(pa_gral_dt ~ na_gral_dt + GENDER + V1RelSat_pc | ID_INDIV, data = sample2,
       strip = FALSE, aspect = "xy", pch = 16, 
       xlab = "Posative Affect", ylab = "Negative Affect")
sample2 = emo.dat[emo.dat$ID_INDIV %in%sample(unique(emo.dat$ID_INDIV), 5, replace = FALSE),]
head(sample)
xyplot(mod5, data = sample2, type = c("p", "smooth"), col.line = "black")
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
xyplot(fitted(mod5) ~ pa_gral_dt, groups = ID_INDIV, type = 'l', data = emo.dat)

### grandmean centering ################################################
###########################################################
# In the grand-mean centering approach, we  
# compute the between-persons characteristics of
# verbal ability as averaging across time points
# for each individual:
na_grat_pmean = aggregate(emo.dat$na_gral, by = list(emo.dat$ID_INDIV), mean, na.rm = T)
names(na_grat_pmean) = c('ID_INDIV', 'na_gral_b')
emo.dat = merge(emo.dat, na_grat_pmean, by = 'ID_INDIV')
head(emo.dat)
emo.dat$na_gral_gc = emo.dat$na_gral- mean(emo.dat$na_gral, na.rm = T)

#grandmean centering relational satisfaction
V1RelSat_pmean = aggregate(emo.dat$V1RelSat, by = list(emo.dat$ID_INDIV), mean, na.rm = T)
names(V1RelSat_pmean) = c('ID_INDIV', 'V1RelSat_b')
emo.dat$V1RelSat_gc = emo.dat$V1RelSat- mean(emo.dat$V1RelSat, na.rm = T)
### person mean centering ################################################
###########################################################
#person mean center na_gral
emo.dat$na_gral_pc = emo.dat$na_gral - emo.dat$na_gral_b
head(emo.dat)

#person mean center relationship satisfaction 
rel_pmean = aggregate(emo.dat$V1RelSat, 
                     by = list(emo.dat$ID_INDIV), 
                     mean, na.rm = T) #greating verbal mean for each person 
names(rel_pmean) = c('ID_INDIV', 'V1RelSat_b') #giving them a name
emo.dat = merge(emo.dat, rel_pmean, by = 'ID_INDIV')
emo.dat$V1RelSat_pc = emo.dat$V1RelSat - emo.dat$V1RelSat_b
head(emo.dat)
list(emo.dat)

###Detrending variables of interest ################################################
###########################################################
#gm center time
emo.dat$DAY_gm = emo.dat$DAY - mean(emo.dat$DAY, na.rm = T)
### ### ### # Using the 2-step procedure to detrend x(na_gral): ### ####
step1.x = lmer(na_gral_pc ~ DAY_gm + (DAY_gm|ID_INDIV), 
               data = emo.dat)
summary(step1.x)
# Save Residuals
emo.dat$na_gral_dt = resid(step1.x)
library(lattice)
xyplot(na_gral_pc + na_gral_dt ~ DAY, groups = ID_INDIV, 
       type = 'l', data = emo.dat)
# Save intercepts
negaff = ranef(step1.x)$ID_INDIV[, '(Intercept)']
negaff = data.frame(cbind(unique(emo.dat$ID_INDIV), negaff))
colnames(negaff) = c('ID_INDIV', 'avgnegaff')
emo.dat = merge(emo.dat, negaff, by = 'ID_INDIV')
head(emo.dat)
### ### ### # Using the 2-step procedure to detrend y(pa_gral): ### ####
# Step 1:
step1.y = lmer(pa_gral ~ DAY_gm + (DAY_gm|ID_INDIV), 
               data = emo.dat)
summary(step1.y)
# Save Residuals
emo.dat$pa_gral_dt = resid(step1.y)
# Retain individual intercepts:
posaff = ranef(step1.y)$ID_INDIV[, '(Intercept)']
posaff = data.frame(cbind(unique(emo.dat$ID_INDIV), posaff))
colnames(posaff) = c('ID_INDIV', 'avgposaff')
emo.dat = merge(emo.dat, posaff, by = 'ID_INDIV')
# Add individual intercepts back in:
emo.dat$pa_gral.int = emo.dat$pa_gral_dt + emo.dat$avgposaff
xyplot(pa_gral + pa_gral.int ~ DAY, groups = ID_INDIV, 
       type = 'l', data = emo.dat)

### running models ################################################
###########################################################
mod.xyd = lmer(pa_gral_dt ~ na_gral_dt + avgnegaff + GENDER + V1RelSat +
                 (1|ID_INDIV), data = emo.dat) 

####@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
###@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#Dr. Cher Ami is conducting a mega-analysis of 500 pigeons under similar fixed-interval reinforcement schedules. 
#Pigeons were placed in a Skinner box where reinforcement (food) was administered after the 
#pigeon pecked a target button following the fixed interval period. These trials lasted ~20 min.
pigeon = dat <- read.csv('pigeon.csv',header = TRUE)
head(pigeon)
dim(pigeon)
pigeon$id = 1:500
#a. Plot the pigeon data. Make sure the plot is properly labeled. (3 points)
xyplot(pecks ~ trial , groups = id, data = pigeon, xlab = "Trial Number (ID = Color)", ylab = "Number of Pecks")
?xyplot()
list(pigeon)
xyplot(trial ~ pecks , groups = id, data = pigeon, xlab = "Number of Pecks (ID = Color)", ylab = "Trial")

#######################################################################################################################


##goal: can you create a model that predicts pecks from the trial?


pig1 = lm(pecks~ trial, data= pigeon)
plot(pecks ~ trial, data = pigeon, 
     pch = 20, ylab = "Number of Pecks", 
     main = "SkinnerBox")
abline(pig1, col = "darkorange")

pig2 = lm(pecks~ trial + I(trial^2), data= pigeon)
plot(pecks ~ trial, data = pigeon, 
     pch = 20, ylab = "Number of Pecks", 
     main = "SkinnerBox")
abline(pig2, col = "darkorange")

pig3 = lm(pecks~ trial + I(trial^2) + I(trial^3) + I(trial^4) + I(trial^5) + I(trial^6) + I(trial^7) , data= pigeon)
abline(pig3, col = "darkorange")


pig4 = lm(trial~ pecks, data= pigeon)
plot(trial ~ pecks, data = pigeon, 
     pch = 20, ylab = "Number of Pecks", 
     main = "SkinnerBox")
abline(pig4, col = "darkorange")
pig5 = lm(trial ~ pecks + I(pecks^2), data=pigeon)

AIC(pig1); AIC(pig2); AIC(pig4); AIC(pig5)
head(pigeon)


summary(pig1)
head(pigeon)
summary(pigeon)

list(pigeon)

###@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
###@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
harvard <- read.table(url("https://www.hsph.harvard.edu/fitzmaur/ala/lead.txt"), header = TRUE, fill = TRUE)
har <- read.table("lead.txt", header = TRUE, fill = TRUE)
harv = har[3:52, 1:5]
harv$id = 1:50
list(hardva)
dim(hardva)
colnames(harv) <- c("lead1", "lead2" , "lead3", "lead4", "N/A", "id")
#convert to long format 
longharv = reshape(hardva, 
               varying = c('lead1', 'lead2', 'lead3', 'lead4'), idvar = 'id',
               v.names = 'lead', direction = "long", timevar = "leadamount")
longharvordered = longharv[order(longharv$id), ]
head(longharvordered)





#install.packages('tidyr')
library(tidyr)
?gather()

longharvd = gather(hardva, key = "id", value , -id)
head(longharvd)


head(harv)
dim(harv)
colnames(harv)




har
har$lead2 = as.numeric(gsub("\\X", "", har$Lead))
head(har)
##convert data to long formate 

hardva = harv[1:50,c( 1:4, 6)]
longharv <- melt(hardva, id.vars = c("lead1", "lead2", "lead3", "lead4", "id"))

?melt()
?reshape()

harlong = reshape(harvard, 
               varying = list(c('Lead', 'Level', 'Week', 'verb6'),
                              c('perfo1', 'perfo2', 'perfo4', 'perfo6')),
               direction = 'long', timevar = 'time', idvar = 'id',
               v.names = c('verbal', 'perform'))

long = long[order(long$id), ]

harvard[1:19, ]

head(long)
?read.table()

###@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
###@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

high <- read.csv('highway.csv',header = TRUE)
head(high)

high$crash <- rowSums(high[1:76, 2:9])

high$nocrash<- rowSums(high[1:76, 2:9]==0)
sample2 = high[1:61, 2:10]
sample1 = high[62:76, 2:10]

sample1$total = sum(sample1$S1, sample1$S2, sample1$S3, sample1$S4, sample1$S5, sample1$S6, sample1$S7, sample1$S8)
sample2$total = sum(sample2$S1, sample2$S2, sample2$S3, sample2$S4, sample2$S5, sample2$S6, sample2$S7, sample2$S8)

newdatafram = rbind(sample1[1,], sample2[1,])
newdat = high[1:76, c(1, 10,12:13)]
monthid = c(1:105, 1:105)
crash_nocrash
head(high)
highlong = reshape(high, 
                  varying = list(c('S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'total', 'crash', 'nocrash'),
                                 
                  direction = 'long', timevar = 'month', idvar = 'Month'), v.names = c('', 'perform'))

highlong =reshape(high, direction = "long", varying = list(c('S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8')), v.names = "crashcount", 
        idvar = "sample", timevar = "Month")


?reshape()


long = long[order(long$id), ]

#install.packages('reshape2')
library(reshape2)
longhigh <- melt(high, id.vars = c("sample", "Month"))
head(high)
dd = high[1:76, c(1, 10,3, 6, 7, 9)]
longdd <- melt(dd, id.vars = c("sample", "Month"))


#########################################################################################################################

summary(m1 <- glm(num_awards ~ prog + math, family="poisson", data=p))
longhigh

#1.	Is the accident frequency of sample 2 significantly smaller than that of sample 1?
high$sample[high$sample==2] <- 0
hmod = glm(crash ~ sample, family=poisson(link=log), data = high)
print = data.frame(high, pred=hmod$fitted)
print

summary(hmod)

hmodnew = glm(total ~ sample, family=poisson(link=log), data = newdatafram)
printnew = data.frame(newdatafram, pred=hmodnew$fitted)
printnew
summary(hmodnew)
exp(2.7726)
exp(1.3698)

#install.packages('pscl')
library(pscl)
m1 <- zeroinfl(value ~ sample | sample,
               data = longhigh, dist = "negbin", EM = TRUE)
summary(m1)

#is the number of successful montsh differ by sample?
hmodno = glm(nocrash ~ sample, family=poisson(link=log), data = high)
print1 = data.frame(high, pred=hmodno$fitted)
print1



summary(hmodno)

#1.	Is the accident frequency on section S1 [a defined section of the road with a given length of some miles] 
#of sample 2 significantly smaller than that section S1 of sample 1?

s1 = high[ , c(2, 10)]
hmod2 = glm(S1 ~ sample, family=poisson(link=log), data = high)
print2 = data.frame(high, pred=hmod2$fitted)
summary(hmod2) #no

#what if we generate data based on the distributions of each section (sample is small, maybe there is a true difference)
#install.packages("rethinking")

crash

post <- sample.emo = sample[sample(nrow(emo.dat), 100), ]


lambda_old <- high$samle== 1 
lambda_new <- high$sample ==0

summary(lambda_new)


#1.	Is the accident frequency in sections S2 and S5 and S6 and S8 of sample 2 significantly 
#lower than the corresponding sections of sample 1?
longdd 
head(longdd)

longddfit = glm(value ~ sample, family=poisson(link=log), data = longdd)

hmod3 = glm(S2 ~ sample, family="poisson", data = high)
summary(hmod3)

hmod4 = glm(S5 ~ sample, family="poisson", data = high)
summary(hmod4)

hmod5 = glm(S6 ~ sample, family="poisson", data = high)
summary(hmod5)

hmod6 = glm(S8 ~ sample, family="poisson", data = high)
summary(hmod6)



#sum the rate of car accenedts by sample 

list(high)

high$total = sum(high$S1, high$S2, high$S3, high$S4, high$S5, high$S6, high$S7, high$S8)









