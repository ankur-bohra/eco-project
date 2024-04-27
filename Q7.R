library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)

state_regions <- read_csv("input/regions.csv")
gini_gwq_nsdp <- merge(gini_gwq_nsdp, state_regions, by="state", all.x=TRUE, all.y=FALSE)
gini_gwq_nsdp$region <- factor(gini_gwq_nsdp$region, levels=c("NORTHERN REGION", "NORTH-EASTERN REGION", "EASTERN REGION", "CENTRAL REGION", "WESTERN REGION", "SOUTHERN REGION"))
on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ region + nsdp*region + I(nsdp**2)*region + I(nsdp**3)*region + gini*region, data=gini_gwq_nsdp)
print(summary(on_nsdp_poly_gini))