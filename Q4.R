library(ggplot2)
library(readr)
library(scales)

on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ nsdp + I(nsdp**2) + I(nsdp**3) + gini, data=gini_gwq_nsdp)
summary(on_nsdp_poly_gini)