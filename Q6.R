library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)

gini_gwq_nsdp$year <- factor(gini_gwq_nsdp$year, levels=2000:2018)
on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ year + nsdp*year + I(nsdp**2)*year + I(nsdp**3)*year + gini*year, data=gini_gwq_nsdp)
print(summary(on_nsdp_poly_gini))