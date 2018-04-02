###################################
# Part I. Multilevel linear model #
###################################

# This experiment investigated the effect of diet on the 
# early growth of chicks.



# 1. Load ChickWeight dataset from library(datasets).

library(datasets)
head(ChickWeight)
summary(ChickWeight)



# 2. First, explore the data by selecting 10 chicks and plotting 
#    weight against Time (hint: could use xyplot().

library(lattice)

set.seed(031318)
index = sample(ChickWeight$Chick, 10, replace = F)
sub = ChickWeight[which(ChickWeight$Chick %in% index), ]
xyplot(sub$weight ~ sub$Time | sub$Chick, type = c('p', 'r'))



# 3. Fit a null model and a full model that includes both 
#    a random slopes/intercept component and includes time 
#    and diet.

library(lme4)

# Null model:
mod0 = lmer(weight ~ 1 + (1 | Chick), data = ChickWeight)
summary(mod0)

# Full Model 1:
mod1 = lmer(weight ~ Diet + Time + (Time | Chick),
            data = ChickWeight)
summary(mod1)
            


# 4. Compare model fits using both anova() and AIC.

# Model fits - AIC
AIC(mod0); AIC(mod1)

# Model fits - ANOVA
anova(mod0, mod1)

# mod1 is a better fit to the data


# 5. Create a plot showing the predicted weights at each time 
#    point for each of the four diets.
 

ChickWeight$fixedint = rep(fixef(mod1)[1], nrow(ChickWeight))
ChickWeight$fixedslope = rep(fixef(mod1)[5], nrow(ChickWeight))
random = as.data.frame(ranef(mod1)$Chick)
random$Chick = rownames(random)
colnames(random) = c('randomint', 'randomslope', 'Chick')

ChickWeight = merge(ChickWeight, random, by = 'Chick')


ChickWeight$DietEffect = ifelse(ChickWeight$Diet == 1, 0,
                                ifelse(ChickWeight$Diet == 2, fixef(mod1)[2],
                                ifelse(ChickWeight$Diet == 3, fixef(mod1)[3],
                                 fixef(mod1)[4])))

ChickWeight$predint = with(ChickWeight, fixedint + randomint + DietEffect)
  
ChickWeight$predslope = with(ChickWeight, fixedslope + randomslope) 


ggplot() + 
  scale_x_continuous(limits=c(min(ChickWeight$Time), max(ChickWeight$Time))) +
  scale_y_continuous(limits = c(min(ChickWeight$weight), max(ChickWeight$weight))) +
  geom_abline(data = ChickWeight, aes(slope = predslope, intercept = predint, color = factor(Diet)))



#############################################
# Part II. Generalized linear mixed effects #
#############################################

# For the following questions, you will be using a dataset 
# from Don Hedecker's website (http://hedeker.people.uic.edu/ml.html). 
# The data is from a psychiatric study described in Reisby et al.
# (1977). "This study focused on the longitudinal relationship 
# between imipramine (IMI) and desipramine (DMI) plasma levels 
# and clinical response in 66 depressed patients" (Hedecker &  
# Gibbons, 2006).1111 (My cats added the 1's I think :| )

# You can use the following lines of code to read in the data 
# (note: the data are already in long format):
  
library(foreign)
drug = read.spss('riesbyt4.sav', to.data.frame = T)

# This dataset includes the following variables: a subject 
# identification variable (id); depression score from the 
# Hamilton Depression measure (hamdelt); week measurement 
# occurred (week); depression type (endogenous = 1; 
# nonendogenous = 0); log-transformed imipramine drug-plasma 
# levels (lnimi); and log-transformed desipramine drug-plasma 
# levels-a metabolite of imipramine (lndmi). 


# 1. Create longitudinal plots for each of the time-varying 
#    variables (Hamilton depression scores and log-transformed 
#    imipramine and desipramine drug-plasma levels). Describe 
#    the plots in terms of observed trends and variability in 
#    the data.

library(ggplot2) 

# Plot Depression Score
ggplot(drug, aes(x = week, y = hamdelt, group = id)) +
  guides(colour = FALSE) +
  geom_point() +
  geom_line() +
  theme_bw() + 
  aes(colour = factor(id)) + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) 

# Plot imipramine drug-plasma levels
ggplot(drug, aes(x = week, y = lnimi, group = id)) +
  guides(colour = FALSE) +
  geom_point() +
  geom_line() +
  theme_bw() + 
  aes(colour = factor(id)) + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) 

# Plot desipramine drug-plasma levels
ggplot(drug, aes(x = week, y = lndmi, group = id)) +
  guides(colour = FALSE) +
  geom_point() +
  geom_line() +
  theme_bw() + 
  aes(colour = factor(id)) + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) 

# There appears to be a lot of variability in depression scores;
# most people seem to decrease in depression scores over time
# while others seem to increase or stay the same across the
# occasions. Both IMI and DMI do not appear to have trends over
# time, with most lines appearing to be parallel. There appears
# to be one outlier for DMI (1 person had a score of 0 at time
# 0).



# 2. Using multilevel modeling, predict individuals' depression 
#    scores from log-transformed imipramine and desipramine 
#    drug-plasma levels. Use person-mean centered values for lnimi 
#    and lndmi. Determine an implement an appropriate detrending 
#    strategy for these data; justify your decision theoretically.

# Between-person effect for IMI:
personimi = aggregate(drug$lnimi, 
                      by = list(drug$id), 
                      mean, na.rm = T)

names(personimi) = c('id', 'imi_b')

drug = merge(drug, personimi, by = 'id')

# Between-person effect for DMI:
persondmi = aggregate(drug$lndmi, 
                      by = list(drug$id), 
                      mean, na.rm = T)

names(persondmi) = c('id', 'dmi_b')

drug = merge(drug, persondmi, by = 'id')

head(drug)


# Person-mean centering within-person effects:
drug$imi_w = drug$lnimi - drug$imi_b
drug$dmi_w = drug$lndmi - drug$dmi_b

# Because there do not appear to be linear trends in either
# of the predictor variables, I did not detrend.

# Fit the model
fit = lmer(hamdelt ~ imi_w + dmi_w + imi_b + dmi_b +
             (imi_w + dmi_w | id), data = drug)

summary(fit)



# 3.	Write out the multilevel equation for the model you fit 
#     in 2 above. 

# Level 1: hamdelt_it = beta_0i + beta_1i * imi_wit + beta_2i * dmi_wit + r_it 

# Level 2: beta_0i = gamma_00 + gamma_01 * imi_bi + gamma_02 * dmi_bi + u_0i
#          beta_1i = gamma_10 + u_1i
#          beta_2i = gamma_20 + u_2i



# 4.	Interpret the model parameters found in 2. 

# The correlation between the random intercept and slope of imi_w is
# .59, suggesting that a higher intercept is associated with a higher 
# IMI slope.

# The correlation between the random intercept and slope of dmi_w is
# .35, suggesting that a higher intercept is associated with a higher 
# DMI slope.

# The correlation between random slopes for imi_w is dmi_w is .95,
# suggesting that slopes for imi_w and dmi_w were extremely similar
# within people.

# In terms of fixed effects, imi_w refers to the within-person fixed 
# effect for IMI. This value suggests that there is no within-person
# effect of IMI on depression scores.

# The next fixed effect, dmi_w refers to the within-person fixed 
# effect for DMI. This value suggest that there is a within-person
# effect of DMI on depression scores, suggesting that during times
# when the patient had a DMI level that was higher than their own
# average levels, at a later time the patient had a lower depression
# score. 

# The between-person effect for IMI (imi_b) suggests that there is not
# a between-person effect of IMI on depression scores. 

# The between-person effect for DMI (dmi_b) suggests that people with
# higher average DMI levels tend to have lower depression scores.