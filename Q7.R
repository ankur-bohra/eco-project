library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)
gini_gwq_nsdp <- gini_gwq_nsdp[gini_gwq_nsdp$hardnesstotal > 0,]

state_regions <- read_csv("input/regions.csv")
gini_gwq_nsdp <- merge(gini_gwq_nsdp, state_regions, by="state", all.x=TRUE, all.y=FALSE)
gini_gwq_nsdp$region <- factor(gini_gwq_nsdp$region, levels=c("NORTHERN REGION", "NORTH-EASTERN REGION", "EASTERN REGION", "CENTRAL REGION", "WESTERN REGION", "SOUTHERN REGION"))
on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ region + nsdp*region + I(nsdp**2)*region + I(nsdp**3)*region + gini*region, data=gini_gwq_nsdp)
print(summary(on_nsdp_poly_gini))

plot <- ggplot(data=gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp, colour=region)) +
  geom_point(alpha=0.08, colour="lightgray") +
  stat_smooth(geom="line", method=lm, formula=y~x + I(x**2) + I(x**3), se=FALSE, linewidth=1, alpha=0.8) +
  theme(legend.position=c(0.8, 0.79), legend.title=element_blank()) +
  ggtitle("Total hardness vs NSDP") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE)
png("plots/Region-wise Total hardness vs NSDP.png")
print(plot)
dev.off()
print(plot)