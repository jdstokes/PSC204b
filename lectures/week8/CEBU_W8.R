# Import cebu data
# Missing values are -10
library(foreign)
cebu <- read.spss("cebu_birth_1.sav", use.value.labels=T, to.data.frame=T)
cebu

cebu$breast <- factor(cebu$breast, labels = c("not breastfed", "breastfed"))
names(cebu)[2] <- "mocc"

names(cebu)
cebu <- cebu[, -9] ## drop intercept variable


## ## Wide format 
## cebu.wide <- reshape(cebu, idvar = "id", timevar = "mocc", direction = "wide")
## head(cebu.wide)

## names(cebu.wide)
## cebu <- reshape(cebu.wide, direction = "long", sep = ".")
## names(cebu)


cebu$heightC <-scale(cebu$heightbb, scale=F)
head(cebu)

head(cebu)
## names(cebu) <- gsub('.0', '', names(cebu))


library(lme4)
## find NA
#narow <- which(is.na(cebu$weightbb))
#cebu[narow, ]
#cebu <- cebu[,narow]

## Variance Component


ols <- lm(weightbb~1, data=cebu, na.action = na.omit)
summary(ols)

resvar <- sum(residuals(ols)^2)/(nrow(cebu)-1)
resvar
sqrt(resvar)

vc.mod <- lmer(weightbb~1+(1|id), data=cebu)
summary(vc.mod)

## pdf(file = '../../Repo/figures/cebu1.pdf', width = 5, height = 6)
plot(jitter(rep(0, length(fitted(vc.mod)))), fitted(vc.mod), xlim = c(-0.1, 0.1))
## dev.off()

##ICC:
0.349/(0.349+2.8)

library(multilevel)
ICC1(aov(weightbb~as.factor(id), data=cebu))


## within and between subject variance:
2.8007/(2.8007 + 0.3488) # within subject variance
0.3488/(2.8007 + 0.3488) # between subject variance

## Plot data
library(lattice)
xyplot(weightbb ~ mocc, groups = id, data = cebu, type = 'l')

library(ggplot2)
## pdf(file = '../../Repo/figures/cebu2.pdf', width = 5, height = 6)
ggplot(cebu, aes(mocc, weightbb, group=id, col=id )) + 
    geom_line(show.legend=FALSE)+
    theme_bw() + xlab("Measurement Occasion") +ylab("Birthweight Baby")
## dev.off()

## random intercept + measurement occasions
mod0 <- lmer(weightbb~1+mocc+(1|id), data=cebu, na.action = na.exclude)
summary(mod0)

## variances:
0.7039/(0.7039+0.5231) # within
0.5231/(0.7039+0.5231) # between

## changes in variance due to inclusion of mocc
## Proportion of variance explained at level 1:
(2.8007-0.7039)/2.8007  #74% of variance at L1 explained by inclusion of mocc
(0.3488 - 0.5231)/0.3488 # increase of level 2 variance!

## pdf(file = '../../Repo/figures/cebu3.pdf', width = 5, height = 6)
xyplot(fitted(mod0) ~ mocc, groups = id, data = cebu, type = 'l')
## dev.off()

# random intercept and slope
mod1 <- lmer(weightbb~1+mocc+(mocc|id), data=cebu, na.action = na.exclude)
summary(mod1)

##
xyplot(fitted(mod0) + fitted(mod1) ~ mocc, groups = id, data = cebu, type = 'l')
## compare model fit:
anova(mod0,mod1)

## Level 2 predictor
## Average mother weight in KG
momkg <- aggregate(cebu$weightmm, by=list(as.factor(cebu$id)), mean)
momkg

## Create new vector with avergae mom weight
cebu$avgMw <- NA
for( i in 1:length(cebu$id)){
    cebu[cebu$id == momkg[i,1], 'avgMw'] <- momkg[i,2]
}

cebu

## create dummy for weights  below 48, 49--67, 68+
quantile(cebu$avgMw, c(0.20, 0.80), na.rm = TRUE)

cebu$d2 <- ifelse(cebu$avgMw>=53, 1, 0)
cebu$d1 <- ifelse(cebu$avgMw>=43, 1,0) - cebu$d2

mod2 <- lmer(weightbb ~ mocc + d1 + d2 + mocc*d1 + mocc*d2 + (mocc|id),
             data=cebu, na.action = na.exclude)
summary(mod2)

## factorize for plot
cebu$grouping <- factor(cebu$d1-cebu$d2, labels = c("53+", "-43", "44-52"))
cebu$fitted2 <- fitted(mod2)

cebu[order(cebu$id),-5]

## pdf(file = '../../Repo/figures/cebu4.pdf', width = 5, height = 6)
xyplot(fitted(mod2) ~ mocc |grouping, groups = id, type = 'l', data = cebu)
## dev.off()

## add quadratic time effect
cebu$mocc2 <-  cebu$mocc^2
cebu$mocc2 <-  cebu$mocc^2/10

mod3 <- lmer(weightbb~mocc*d1+mocc*d2+mocc2*d1+mocc2*d2+(mocc|id), data=cebu, na.action = na.exclude)
summary(mod3)

## pdf(file = '../../Repo/figures/cebu5.pdf', width = 5, height = 6)
xyplot(fitted(mod3) ~ mocc |grouping, groups = id, type = 'l', data = cebu)
## dev.off()
anova(mod2, mod3)


mod4 <- lmer(weightbb~mocc*d1+mocc*d2+mocc2*d1+mocc2*d2+(mocc+mocc2|id), data=cebu, na.action = na.exclude)
summary(mod4)
anova(mod3, mod4)

## pdf(file = '../../Repo/figures/cebu6.pdf', width = 5, height = 6)
xyplot(fitted(mod4) ~ mocc |grouping, groups = id, type = 'l', data = cebu)
## dev.off()
## pdf(file = '../../Repo/figures/cebu7.pdf', width = 5, height = 6)
xyplot(fitted(mod4) + cebu$weightbb ~ mocc |grouping, groups = id, type = 'l', data = cebu)
## dev.off()
## pdf(file = '../../Repo/figures/cebu8.pdf', width = 5, height = 6)
xyplot(fitted(mod3) + fitted(mod4) + cebu$weightbb ~ mocc |grouping, groups = id, type = 'l', data = cebu)
## dev.off()


cebu$fit4 <- predict(mod4)

## library(ggplot2)
cebgg <- cebu[!is.na(cebu$grouping), ] ## drop NA's in grouping

## pdf(file = '../../Repo/figures/cebu9.pdf', width = 5, height = 6)
ggplot(cebgg, aes(mocc, fit4, group=id, col=id )) + 
      facet_grid(. ~ grouping) +
    geom_line(show.legend=FALSE)+
    geom_point(aes(y = weightbb), alpha = 0.3, show.legend=FALSE) +
    theme_bw()
## dev.off()



## addd time-varying predictorL: mother's weight

cebu$momkg.c <- scale(cebu$weightmm, scale = FALSE)/10

pdf(file = '../../Repo/figures/Cebumomweight.pdf', width = 7, height = 5)
xyplot(weightmm ~ mocc, groups = id, data = cebu, type = 'l')
dev.off()

## Person-mean centered
cebu$momkg.pmc <- (cebu$weightmm - cebu$avgMw)/10
## Center the average mom weight as well
cebu$avgMw.c <- scale(cebu$avgMw, scale = FALSE)/10

pdf(file = '../../Repo/figures/CebuCentered.pdf', width = 7, height = 3.5)
xyplot(avgMw.c + momkg.pmc ~ mocc, groups = id, data = cebu, type = 'l')
dev.off()

## not same amount of missingness in vars
cebu[, c('momkg.c', 'momkg.pmc', 'avgMw')]

## drop according to missing values in avgMw
cebu2 <- cebu[!is.na(cebu$avgMw),]

mod2 <- lmer(weightbb~mocc+mocc2+momkg.c+(mocc+mocc2+ momkg.c|id), data=cebu2, na.action = na.exclude)
summary(mod2)

mod3 <- lmer(weightbb~mocc+mocc2+avgMw.c + momkg.pmc + (mocc+mocc2+momkg.pmc|id),
             data=cebu2, na.action = na.exclude)
summary(mod3)

anova(mod2, mod3)

pdf(file = '../../Repo/figures/CebuM2M3.pdf', width = 8, height = 5)
xyplot(fitted(mod2)+fitted(mod3) ~ mocc, groups = id, type = 'l', data = cebu2)
dev.off()

cebu2$fit3 <- predict(mod3)


pdf(file = '../../Repo/figures/CebuInd.pdf', width = 8, height = 5)
xyplot(fit3 +  I(momkg.pmc*3+9) ~ mocc|id , groups = id, type = 'l', data = cebu2[cebu2$id <= 1119470,])
dev.off()

## Detrending the time varying predictor?
xyplot(cebu2$momkg.pmc ~ mocc, groups = id, type = 'l', data = cebu2)

names(cebu2)

pdf(file = '../../Repo/figures/CebuBBc.pdf', width = 8, height = 5)
xyplot(cebu2$heightbb ~ mocc, groups = id, type = 'l', data = cebu2)
dev.off()

## Step 1 - detrend heightbb
mean(cebu2$mocc)
step1 <- lmer(heightbbc~I(mocc-5.5)+I((mocc-5.5)^2)+ (I(mocc-5.5)+I((mocc-5.5)^2)|id),
              data=cebu2, na.action = na.exclude)
step1

## Individual OLS's
## step1ols <- lmList(heightbbc~I(mocc-6)+I((mocc-6)^2) | id,  data=cebu2, na.action = na.exclude)
## intols <- ranef(step1ols)[,'(Intercept)']


## Step 2: obtain residuals
cebu2$heightbb.dt <-  resid(step1)

pdf(file = '../../Repo/figures/CebuBBDet.pdf', width = 8, height = 4)
xyplot(heightbbc + heightbb.dt~ mocc, groups = id, type = 'l', data = cebu2)
dev.off()

## Obtain intercept
hgt <- ranef(step1)$id[, '(Intercept)']

## Obtain intercept
hgt <- ranef(step1)$id[, '(Intercept)']
cebu2$avgHgt <- NA
for( i in 1:length(cebu2$id)){
    cebu2[cebu2$id == unique(cebu2$id)[i], 'avgHgt'] <- hgt[i]
}

cebu3 <- cebu2[!is.na(cebu2$avgHgt),]
cebu3

## not detrended
mod7 <- lmer(weightbb ~ mocc+mocc2+heightbbc+(mocc+mocc2+heightbbc|id),
             data=cebu3, na.action = na.exclude)
summary(mod7)

## detrended
mod8 <- lmer(weightbb~mocc+mocc2+avgHgt+heightbb.dt+(mocc+mocc2+heightbb.dt|id),
             data=cebu3, na.action = na.exclude)
summary(mod8)


xyplot(fitted(mod7) + fitted(mod8) ~ mocc, groups = id, type = 'l', data = cebu3)

## Instead of intercept, use predicted height
pdf(file = '../../Repo/figures/CebuHgtPred.pdf', width = 7, height = 4)
xyplot(fitted(step1) ~ mocc, groups = id, type = 'l', data = cebu3)
dev.off()

cebu3$heightpred <- fitted(step1)

mod9 <- lmer(weightbb~heightpred+heightbb.dt+(heightpred+heightbb.dt|id),
             data=cebu3, na.action = na.exclude)
summary(mod9)

