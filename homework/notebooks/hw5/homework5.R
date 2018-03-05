#1
library(ggplot2)
library(dplyr)

set.seed(02082018)
x = rnorm(200)
y = x + x^2 + x^3 + rnorm(200, 0, 4)
dat = data.frame(y, x,x2=x^2,x3=x^3,x4=x^4,x5=x^5,x6=x^6)

fit_under = lm(data=dat,formula=y~x)
fit_over = lm(data=dat,formula=y~x+x2+x3+x4+x5+x6)
fit_true = lm(data=dat,formula=y~x+x2+x3)

x_seq <- seq(from=min(dat$x), to=max(dat$x),length.out=dim(dat)[1])
dat_new = data.frame(x=x_seq,x2=x_seq^2,x3=x_seq^3,x4=x_seq^4,x5 = x_seq^5,x6=x_seq^6)

dat_pred_under <-predict(fit_under,newdata=dat_new, interval="predict") 
dat_pred_under  = data.frame(dat_pred_under)

dat_pred_over <-predict(fit_over,newdata=dat_new, interval="predict") 
dat_pred_over  = data.frame(dat_pred_over)

dat_pred_true <-predict(fit_true,newdata=dat_new, interval="confidence") 
dat_pred_true  = data.frame(dat_pred_true)


ggplot(dat,aes(y = y, x = x)) +
  geom_point() +
  geom_line(data=dat_pred_under,aes(x=x_seq,y=fit,colour='red')) + 
  geom_ribbon(data=dat_pred_under,aes(x=x_seq,ymin=lwr,ymax=upr,fill='red'),alpha=0.3)+
  geom_line(data=dat_pred_over,aes(x=x_seq,y=fit,colour='green')) +
  geom_ribbon(data=dat_pred_over,aes(x=x_seq,ymin=lwr,ymax=upr,fill='green'),alpha=0.3)+
  geom_line(data=dat_pred_true,aes(x=x_seq,y=fit,colour='purple')) +
  geom_ribbon(data=dat_pred_true,aes(x=x_seq,ymin=lwr,ymax=upr,fill='purple'),alpha=0.3)

  
#   
# 
# ###############################
# sst <- sum((y - mean(y))^2)
# sse <- sum((y_predicted - y)^2)
# 
# # R squared
# rsq <- 1 - sse / sst
# rsq
# #> [1] 0.9318896 

  

  