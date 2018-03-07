# Import cebu data
# Missing values are -10
library(foreign)
library(lattice)
library(lme4)

cebu <- read.spss("cebu_birth_1.sav", use.value.labels=T, to.data.frame=T)
cebu$breast <- factor(cebu$breast, labels = c("not breastfed", "breastfed"))
names(cebu)[2] <- "mocc"
cebu <- cebu[, -9] ## drop intercept variable
cebu$heightC <-scale(cebu$heightbb, scale=F)

momkg <- aggregate(cebu$weightmm, by=list(as.factor(cebu$id)), mean)
## Create new vector with avergae mom weight
cebu$avgMw <- NA
for( i in 1:length(cebu$id)){
    cebu[cebu$id == momkg[i,1], 'avgMw'] <- momkg[i,2]
}

## add quadratic time effect
cebu$mocc2 <-  cebu$mocc^2
cebu$mocc2 <-  cebu$mocc^2/10

## addd time-varying predictorL: mother's weight

cebu$momkg.c <- scale(cebu$weightmm, scale = FALSE)/10

xyplot(weightmm ~ mocc, groups = id, data = cebu, type = 'l')
dev.off()

## Person-mean centered
cebu$momkg.pmc <- (cebu$weightmm - cebu$avgMw)/10
## Center the average mom weight as well
cebu$avgMw.c <- scale(cebu$avgMw, scale = FALSE)/10

#pdf(file = '../../Repo/figures/CebuCentered.pdf', width = 7, height = 3.5)
xyplot(avgMw.c + momkg.pmc ~ mocc, groups = id, data = cebu, type = 'l')
dev.off()

## drop according to missing values in avgMw
cebu2 <- cebu[!is.na(cebu$avgMw),]

mod3 <- lmer(weightbb~mocc+mocc2+avgMw.c + momkg.pmc + (mocc+mocc2+momkg.pmc|id),
             data=cebu2, na.action = na.exclude)
summary(mod3)
cebu2$fit3 <- predict(mod3)

#pdf(file = '../../Repo/figures/CebuInd.pdf', width = 8, height = 5)
xyplot(fit3 +  I(momkg.pmc*3+9) ~ mocc|id , groups = id, type = 'l', data = cebu2[cebu2$id <= 1119470,])
dev.off()

## Detrending the time varying predictor?
xyplot(cebu2$momkg.pmc ~ mocc, groups = id, type = 'l', data = cebu2)

xyplot(cebu2$heightbb ~ mocc, groups = id, type = 'l', data = cebu2)
dev.off()

## Step 1 - detrend heightbb
mean(cebu2$mocc)
step1 <- lmer(heightbbc~I(mocc-5.5)+I((mocc-5.5)^2)+ (I(mocc-5.5)+I((mocc-5.5)^2)|id),
              data=cebu2, na.action = na.exclude)

## Step 2: obtain residuals
cebu2$heightbb.dt <-  resid(step1)

#pdf(file = '../../Repo/figures/CebuBBDet.pdf', width = 8, height = 4)
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
#mod7 <- lmer(weightbb ~ mocc+mocc2+heightbbc+(mocc+mocc2+heightbbc|id),
#             data=cebu3, na.action = na.exclude)
#summary(mod7)

## detrended
mod8 <- lmer(weightbb~mocc+mocc2+avgHgt+heightbb.dt+(mocc+mocc2+heightbb.dt|id),
             data=cebu3, na.action = na.omit)
summary(mod8)


xyplot(fitted(mod8) ~ mocc, groups = id, type = 'l', data = cebu3)

## Instead of intercept, use predicted height
#pdf(file = '../../Repo/figures/CebuHgtPred.pdf', width = 7, height = 4)
xyplot(fitted(step1) ~ mocc, groups = id, type = 'l', data = cebu3)
dev.off()

cebu3$heightpred <- fitted(step1)

mod9 <- lmer(weightbb~heightpred+heightbb.dt+(heightpred+heightbb.dt|id),
             data=cebu3, na.action = na.exclude)
summary(mod9)
xyplot(fitted(mod9) ~ I(heightpred+heightbb.dt), groups = id, type = 'l', data = cebu3)

## load the nlme package
detach('package:lme4')
library(nlme)

## mod9 with nlme
mod8n <- lme(fixed  = weightbb ~ mocc + mocc2 + avgHgt + heightbb.dt,
             random = ~ 1 + mocc + mocc2 + heightbb.dt | id,
             data = cebu3, na.action = na.omit)

mod8
mod8n

acf(residuals(mod8n))
plot(ACF(mod8n), alpha = .05)

## add structured error variance cf. corStruct
mod9n <- update(mod8n, correlation = corAR1())
summary(mod9n)
anova(mod8n, mod9n)

plot(ACF(mod9n), alpha = .05)

mod10n <- update(mod8n, correlation = corAR1(form = ~ mocc+mocc2))
summary(mod10n)

plot(ACF(mod10n), alpha = .05)

acf(residuals(mod10n), type = 'partial')
ts.plot(residuals(mod10n))


##
mod11n <- update(mod8n, weights= varIdent(form = ~ 1 | breast))

summary(mod11n)



