# Question 1
##############

library(car)
?Leinhardt

Leinhardt = Leinhardt[-which(Leinhardt$region == 'Europe'), ]

Leinhardt$Africa = ifelse(Leinhardt$region == 'Africa', 1, 0)
Leinhardt$Asia = ifelse(Leinhardt$region == 'Asia', 1, 0)

# Question 1a
##############

fit = lm(infant ~ Africa + Asia, data = Leinhardt)
summary(fit)


# Mean value for the Americas is 55.12
##     The average infant-mortality rate for regions in the
##     Americas is 55.12 per 1,000 live births

# Difference between the mean value of Africa and
# mean value of America is 87.17
##     The average infant-mortality rate for regions in Africa
##     is 87.15 per 1,000 live births higher than for 
##     the Americas

# Difference between the mean value of Asia and 
# mean value of America is 41.05
##     The average infant-morality rate for regions in 
##     Asia is 41.05 per 1,000 live births higher than for
##     the Americas



# Question 1b
##############

Leinhardt$oildummy = ifelse(Leinhardt$oil == 'no', 0, 1)
Leinhardt$Africaxoil = Leinhardt$Africa*Leinhardt$oildummy  
Leinhardt$Asiaxoil = Leinhardt$Asia*Leinhardt$oildummy
  
fittedmodel = lm(infant ~ Africa + Asia + oildummy + Africaxoil + Asiaxoil, data = Leinhardt)
summary(fittedmodel)

# Mean value for American non-oil-exporting regions is 54.125
##     The average infant-morality rate for American
##     non-oil-exporting regions is 54.125 per 1,000 live births

# Difference between African non-oil-exporting regions and
# American non-oil-exporting regions
##     The average infant-mortality rate of African non-oil exporting
##     regions is 87.604 per 1,000 live births higher than for 
##     American non-oiling exporting regions

# Difference between Asian non-oil-exporting regions and
# American non-oil-exporting regions
##     The average infant-mortality rate of Asian non-oil exporting
##     regions is 20.604 per 1,000 live births higher than for 
##     American non-oiling exporting regions

# Difference between American oil-exporting regions and 
# American non-oil-exporting regions
##     The average infant-mortality rate of American 
##     oil-exporting regions is 10.975 per 1,000 live births
##     higher than American non-oil-exporting regions

# The amount by which the mean difference, of African
# oil-exporting regions versus American non-oil-exporting
# regions exceeds the simple effects of B1 and B3
##     The average infant-mortality rate of African oil-exporting
##     regions is 4.604 per 1,000 live births lower than
##     American non-oil-exporting regions

# The amount by which the mean difference, of Asian
# oil-exporting regions versus American non-oil-exporting
# regions exceeds the simple effects of B2 and B3
##     The average infant-mortality rate of Asian oil-exporting
##     regions is 181.996 per 1,000 live births higher than
##     American non-oil-exporting regions
#


# Question 1c
#############

par(mfrow = c(1, 2))
plot(fittedmodel, which = 1:2)


# Question 1 BONUS
##################

par(mfrow = c(1, 1))

# Create vectors of means
B0 = coef(summary(fittedmodel))[1, 1]
B1 = coef(summary(fittedmodel))[2, 1]
B2 = coef(summary(fittedmodel))[3, 1]
B3 = coef(summary(fittedmodel))[4, 1]
B4 = coef(summary(fittedmodel))[5, 1]
B5 = coef(summary(fittedmodel))[6, 1]




America = c(B0, B0 + B3)
Africa = c(B0 + B1, B0 + B1 + B3 + B4)
Asia = c(B0 + B2, B0 + B2 + B3 + B5)

yrange = range(0, America, Africa, Asia)

plot(America, type = 'o', col = 'blue', ylim = yrange,
     axes = F, ann = F)

axis(1, at = 1:2, lab = c('No', 'Yes'))
axis(2, las = 1, at = 50*0:yrange[2])

box()

lines(Africa, type = 'o', pch = 22, lty = 2, col = 'red')
lines(Asia, type = 'o', pch = 24, lty = 3, col = 'black')

title(main = 'Interaction Plot for Infant Morality Rate \n
      by Region and Oil-Exportation')

title(xlab = 'Region Exports Oil')
title(ylab = 'Infant Mortality per 1,000')

legend(1, yrange[2], c('America', 'Africa', 'Asia'),
       cex = 0.8, col = c('blue', 'red', 'black'),
       pch = c(21, 22, 24), lty = 1:3)



# Question 2
############

dir.data <- "/Users/jdstokes/repos/204b/data"
fpath <- file.path(dir.data,"mcdonald.dat")
mcdat <- read.table(fpath,header = TRUE)
head(mcdat)

# Question 2a
#############

plot(mcdat$NOX, mcdat$MORT)
mcfit = lm(MORT ~ NOX, data = mcdat)
summary(mcfit)

plot(mcfit, which = 1)

# Question 2b
#############

summary(mcfit)$r.square

# Exponential model
mcfit.exp = lm(log(MORT) ~ NOX, data = mcdat)
summary(mcfit.exp)$r.square
plot(mcfit.exp)

#Quadratic mdoel
mcfit.quad = lm(sqrt(MORT) ~ NOX, data = mcdat)
summary(mcfit.quad)$r.square
plot(mcfit.quad)

# Recipocal Model 
mcfit.rec = lm(I(1/MORT) ~ NOX, data = mcdat)
summary(mcfit.rec)$r.square
plot(mcfit.rec)

# Logarithmic Model -- BEST MODEL
mcfit.log = lm(MORT ~ I(log(NOX)), data = mcdat)
summary(mcfit.log)$r.square
plot(mcfit.log)

# Power Model
mcfit.pow = lm(log(MORT) ~ I(log(NOX)), data = mcdat)
summary(mcfit.pow)$r.square
plot(mcfit.pow)


# Question 2c
#############

# Logarithmic model worked best
summary(mcfit.log)

# A 1% increase in level of nitric oxides,
# there is a .153 increase in mortality rate


# Question 2d
#############

mcdat$NOX.log = log(mcdat$NOX)
pairs(mcdat[, c('MORT', 'NOX.log', 'SOx', 'HC')])

# Log transform HC
mcdat$HC.log = log(mcdat$HC)


fittedmodel = lm(MORT ~ NOX.log + HC.log + SOx + I(SOx^2),
                 data = mcdat)
summary(fittedmodel)



# Question 2e
#############

car::qqPlot(fittedmodel)

plot(fittedmodel, which = 1)




# BONUS QUESTION
################

dat = read.table('spline.dat', header = T)
head(dat)

with(dat, plot(x, y))

fit.spline = lm(y ~ 1 + x + I((x^2)*(x < 0)) + 
                  I((x)*(x > 0)), data = dat)


summary(fit.spline)

b.0 <- coef(fit.spline)[1]
b.1 <- coef(fit.spline)[2]
b.2 <- coef(fit.spline)[3]
b.3 <- coef(fit.spline)[4]
x.0 <- seq((min(dat$x) - 1), 0, 1)
x.1 <- seq(0, (max(dat$x) + 1), 1)
y.0 <- b.0 + b.1 * x.0 + b.2 * x.0^2
y.1 <- (b.0 + b.1 * 0 + b.2 * 0 + (b.1 + b.3) * x.1)
with(dat, plot(x, y))
lines(x.0,y.0, col="red", lwd = 2)
lines(x.1,y.1, col="blue", lwd = 2)




