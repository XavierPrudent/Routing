library(ggplot2)

## Penalisation des tournants de 90 deg à gauche
## pour b = 0.7, p = 10


## Turn penalty
p = 7.5

## Turn bias
b = 1.075

## Duration function
fpos <- function(x){ 
  y <- p / (1 + exp(-(13*x/(180*b) - 6.5 * b)))
  return(y) 
}

fneg <- function(x){ 
  y <- p / (1 + exp(-(13*b*x*(-1)/180 - 6.5 * b)))
  return(y) 
}

ggplot(data = data.frame(x = 0), aes(x = x)) + 
  xlim(0,180) + 
  stat_function(fun = fpos, geom="line") +
  xlab("Angle (degrés)") + 
  ylab("Durée du tournant")


ggplot(data = data.frame(x = 0), aes(x = x)) + 
  xlim(-180,0) + 
  stat_function(fun = fneg, geom="line") +
  xlab("Angle (degrés)") + 
  ylab("Durée du tournant")

