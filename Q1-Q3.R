library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)
on_nsdp <- lm(formula=hardnesstotal ~ nsdp, data=gini_gwq_nsdp)
# on_nsdp_poly <- lm(formula=hardnesstotal ~ nsdp + I(nsdp**2) + I(nsdp**3), data=gini_gwq_nsdp)
# on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ nsdp + I(nsdp**2) + I(nsdp**3) + gini, data=gini_gwq_nsdp)

ggplot(gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp)) +
  geom_point() +
  geom_point() +
  ggtitle("Total hardness vs NSDP") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE)

ggplot(gini_gwq_nsdp, aes(y=on_nsdp$residuals, x=nsdp)) +
  geom_point() +
  ggtitle("Residuals vs NSDP") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Residual (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE)

hist(on_nsdp$residuals,
     main="Histogram of residuals",
     xlab="NSDP (Rupees Crore)",
     breaks=40,
     freq=TRUE
)

cat("Sum of residuals:")
sum(on_nsdp$residuals)
# summary(on_nsdp)
# summary(on_nsdp_poly)
# summary(on_nsdp_poly_gini)
# sum(on_nsdp_poly$residuals)
# sum(on_nsdp_poly_gini$residuals)