library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)
on_nsdp <- lm(formula=hardnesstotal ~ nsdp, data=gini_gwq_nsdp)
# on_nsdp_poly <- lm(formula=hardnesstotal ~ nsdp + I(nsdp**2) + I(nsdp**3), data=gini_gwq_nsdp)
# on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ nsdp + I(nsdp**2) + I(nsdp**3) + gini, data=gini_gwq_nsdp)

hardness_nsdp_plot <- ggplot(gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp)) +
  geom_point() +
  ggtitle("Total hardness vs NSDP") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  geom_abline(aes(intercept=coef(on_nsdp)[1], slope=coef(on_nsdp)[2], colour="blue"), linewidth=1) +
  # guides (
    # colour = guide_legend(position="inside", theme=theme(legend.title = element_blank()))
  # ) +
  scale_discrete_manual(c("colour"), name="Legend", values='blue', labels='hardnesstotal ~ nsdp') +
  theme(legend.position=c(0.8, 0.9), legend.title=element_blank())

residuals_nsdp_plot <- ggplot(gini_gwq_nsdp, aes(y=on_nsdp$residuals, x=nsdp)) +
  geom_point(alpha=0.15) +
  ggtitle("Residuals vs NSDP") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Residual (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE)

resid_hist <- hist(on_nsdp$residuals,
     main="Histogram of residuals",
     xlab="Residual (CaCO3, mg/L)",
     breaks=40,
     freq=FALSE
)


print(summary(on_nsdp))
cat("Sum of residuals:", sum(on_nsdp$residuals), "(CaCO3, mg/L)\n")
print(hardness_nsdp_plot)
print(residuals_nsdp_plot)
print(resid_hist)