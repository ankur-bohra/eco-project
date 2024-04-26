library(ggplot2)
library(readr)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)
on_nsdp <- lm(formula=hardnesstotal ~ nsdp, data=gini_gwq_nsdp)

quantile(gini_gwq_nsdp$nsdp)
quantile(gini_gwq_nsdp$hardnesstotal)