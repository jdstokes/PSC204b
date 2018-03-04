library(lme4)

Estuaries <- read.csv("/Users/jdstokes/repos/204b/data/Estuaries.csv", header = T)
lmm.data <- read.table("http://www.unt.edu/rss/class/Jon/R_SC/Module9/lmm.data.txt",
                       header = TRUE, sep = ",", na.strings = "NA", dec = ".", strip.white = TRUE) 
                       
# Model with both a fixed and random effect
ft.estu <- lmer(Total ~ Modification + (1|Estuary),data = Estuaries, REML=T)


# Check to see if our residuals are normally distributed
qqnorm(residuals(ft.estu))


# check y variance
scatter.smooth(residuals(ft.estu)~fitted(ft.estu))


# Full model and then a model that lacks the fixed effect
ft.estu <- lmer(Total ~ Modification + (1|Estuary), data=Estuaries, REML=F)
ft.estu.0 <- lmer(Total ~ (1|Estuary), data=Estuaries, REML=F)

# There is evidence of an effect of Modification
anova(ft.estu.0,ft.estu)

#
ft.estu <- lmer(Total ~ Modification + (1|Estuary), data=Estuaries, REML=F)
ft.estu.0 <- lm(Total ~ Modification, data=Estuaries)
anova(ft.estu.0,ft.estu)

# Mixed effect significance
library(nlme)
fit.lme <- lme(Total~Modification,random=~1|Estuary,data=Estuaries)
anova(fit.lme)

