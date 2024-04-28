library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)
gini_gwq_nsdp <- gini_gwq_nsdp[gini_gwq_nsdp$hardnesstotal > 0,]
gini_gwq_nsdp$year <- factor(gini_gwq_nsdp$year, levels=2000:2018)
on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ year + nsdp*year + I(nsdp**2)*year + I(nsdp**3)*year + gini*year, data=gini_gwq_nsdp)
print(summary(on_nsdp_poly_gini))

plot <- ggplot(data=gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp, colour=year)) +
          geom_point(alpha=1, colour="lightgray") +
          stat_smooth(method=lm, formula=y~x + I(x**2) + I(x**3), se=FALSE, linewidth=0.8) +
          ggtitle("Total hardness vs NSDP") +
          xlab("NSDP (Rupees Crore)") +
          ylab("Total hardness (CaCO3, mg/L)") +
          scale_x_continuous(labels = comma)
          # coord_cartesian(expand = FALSE)

png("plots/Year-wise Total hardness vs NSDP.png")
print(plot)
dev.off()
print(plot)