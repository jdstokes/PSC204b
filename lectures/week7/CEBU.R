# Import cebu data
# Missing values are -10
library(foreign)
library(lme4)
cebu <- read.spss("/Users/jdstokes/repos/204b/lectures/week7/cebu_birth_1.sav", use.value.labels=T, to.data.frame=T)
cebu

cebu$breast <- factor(cebu$breast, labels = c("not breastfed", "breastfed"))
names(cebu)[2] <- "mocc"

names(cebu)
cebu <- cebu[, -9] ## drop intercept variable


## Wide format 
cebu.wide <- reshape(cebu, idvar = "id", timevar = "mocc", direction = "wide")
head(cebu.wide)

names(cebu.wide)
cebu <- reshape(cebu.wide, direction = "long", sep = ".")
cebu


cebu$heightC <-scale(cebu$heightbb, scale=F)
head(cebu)

head(cebu[order(cebu$id), ])
names(cebu) <- gsub('.0', '', names(cebu))


library(lme4)
## find NA
#narow <- which(is.na(cebu$weightbb))
#cebu[narow, ]
#cebu <- cebu[,narow]

## Variance Component


ols <- lm(weightbb~1, data=cebu, na.action = na.exclude)
summary(ols)

resvar <- sum(residuals(ols)^2)/(nrow(cebu)-1)
resvar
sqrt(resvar)

vc.mod <- lmer(weightbb~1+(1|id), data=cebu)
summary(vc.mod)

pdf(file = '../../Repo/figures/cebu1.pdf', width = 5, height = 6)
plot(jitter(rep(0, length(fitted(vc.mod)))), fitted(vc.mod), xlim = c(-0.1, 0.1))
dev.off()

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
pdf(file = '../../Repo/figures/cebu2.pdf', width = 5, height = 6)
ggplot(cebu, aes(mocc, weightbb, group=id, col=id )) + 
    geom_line(show.legend=FALSE)+
    theme_bw() + xlab("Measurement Occasion") +ylab("Birthweight Baby")
dev.off()

## random intercept
mod0 <- lmer(weightbb~1+mocc+(1|id), data=cebu, na.action = na.exclude)
summary(mod0)

## variances:
0.7039/(0.7039+0.5231) # within
0.5231/(0.7039+0.5231) # between

## changes in variance due to inclusion of mocc
## Proportion of variance explained at level 1:
## js: variance bf a predictor and variance after the predictor we can see how of variance we're eplaining
(2.8007-0.7039)/2.8007  #74% of variance at L1 explained by inclusion of mocc
(0.3488 - 0.5231)/0.3488 # increase of level 2 variance!

pdf(file = '../../Repo/figures/cebu3.pdf', width = 5, height = 6)
xyplot(fitted(mod0) ~ mocc, groups = id, data = cebu, type = 'l')
dev.off()

# random intercept and slope
# js. so we are now adding a covariance along the intercept and slope
mod1 <- lmer(weightbb~1+heightC+(heightC+mocc|id), data=cebu, na.action = na.exclude)
summary(mod1)
VarCorr(mod1)
anova(mod0,mod1)
AIC(mod0)
AIC(mod1)


# Average mother weight in KG
momkg <- aggregate(cebu$weightmm, by=list(as.factor(cebu$id)), mean)
momkg <- cbind(momkg, matrix(rep(1:208, 12), ncol=12))
momkg
weightM <- make.univ(momkg, momkg[,3:14], tname="mocc", outname="meanmother")
names(weightM)
cebu$weightmean <- weightM$x

names(cebu)
## create dummy for weights  below 48, 49--67, 68+
quantile(cebu$weightmean, c(0.20, 0.80), na.rm = TRUE)

d2 <- ifelse(cebu$weightmean>=53, 1, 0)
d1 <- ifelse(cebu$weightmean>=43, 1,0)-d2
cbind(d1,d2)
mod2 <- lmer(weightbb~1+mocc+d1+d2+mocc*d1+mocc*d2+(mocc|id), data=cebu, na.action = na.exclude)
summary(mod2)

cebu$grouping <- factor(d1-d2, labels = c("53+", "-43", "44-52"))

pdf(file = '../../Repo/figures/cebu4.pdf', width = 5, height = 6)
xyplot(fitted(mod2) ~ mocc |grouping, groups = id, type = 'l', data = cebu)
dev.off()

## add quadratic time effect
cebu$mocc2 <-  cebu$mocc^2
cebu$mocc2 <-  cebu$mocc^2/10

mod3 <- lmer(weightbb~mocc*d1+mocc*d2+mocc2*d1+mocc2*d2+(mocc|id), data=cebu, na.action = na.exclude)
summary(mod3)

pdf(file = '../../Repo/figures/cebu5.pdf', width = 5, height = 6)
xyplot(fitted(mod3) ~ mocc |grouping, groups = id, type = 'l', data = cebu)
dev.off()
anova(mod2, mod3)


mod4 <- lmer(weightbb~mocc*d1+mocc*d2+mocc2*d1+mocc2*d2+(mocc+mocc2|id), data=cebu, na.action = na.exclude)
summary(mod4)
anova(mod3, mod4)

pdf(file = '../../Repo/figures/cebu6.pdf', width = 5, height = 6)
xyplot(fitted(mod4) ~ mocc |grouping, groups = id, type = 'l', data = cebu)
dev.off()
pdf(file = '../../Repo/figures/cebu7.pdf', width = 5, height = 6)
xyplot(fitted(mod4) + cebu$weightbb ~ mocc |grouping, groups = id, type = 'l', data = cebu)
dev.off()
pdf(file = '../../Repo/figures/cebu8.pdf', width = 5, height = 6)
xyplot(fitted(mod3) + fitted(mod4) + cebu$weightbb ~ mocc |grouping, groups = id, type = 'l', data = cebu)
dev.off()


cebu$fit4 <- predict(mod4)

library(ggplot2)
cebgg <- cebu[!is.na(cebu$grouping), ] ## drop NA's in grouping

pdf(file = '../../Repo/figures/cebu9.pdf', width = 5, height = 6)
ggplot(cebgg, aes(mocc, fit4, group=id, col=id )) + 
      facet_grid(. ~ grouping) +
    geom_line(show.legend=FALSE)+
    geom_point(aes(y = weightbb), alpha = 0.3, show.legend=FALSE) +
    theme_bw()
dev.off()


