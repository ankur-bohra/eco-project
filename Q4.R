library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)

on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ nsdp + I(nsdp**2) + I(nsdp**3) + gini, data=gini_gwq_nsdp)
print(summary(on_nsdp_poly_gini))

model_rstudents <- rstudent(on_nsdp_poly_gini)

nsdp_trend_plot <- ggplot(gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp)) +
  geom_point() +
  stat_smooth(method='lm', formula=y ~ x + I(x**2) + I(x**3), se=FALSE, aes(colour="blue")) +
  ggtitle("Partial dependence plot of total hardness on NSDP") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  # geom_point(data=gini_gwq_nsdp[model_rstudents > 3,], aes(colour="red")) +
  scale_discrete_manual(c("colour"), name="Legend", values=c("blue", "red"), labels=c("hardnesstotal ~ nsdp + nsdp^2 + nsdp^3", "Outliers (|RSTUDENT| > 3) of full model\nhardnesstotal ~ nsdp + nsdp^2 + nsdp^3 + gini")) +
  theme(legend.position=c(0.72, 0.9), legend.title=element_blank())

gini_trend_plot <- ggplot(gini_gwq_nsdp, aes(y=gini, x=nsdp)) +
  geom_point(colour='darkgray', alpha=0.7) +
  stat_smooth(method='lm', formula=y ~ x + I(x**2) + I(x**3), se=TRUE, aes(colour="blue")) +
  ggtitle("Kuznets curve") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Gini index (increasing inequality)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  # geom_point(data=gini_gwq_nsdp[model_rstudents > 3,], aes(colour="red")) +
  scale_discrete_manual(c("colour"), name="Legend", values=c("blue", "red"), labels=c("hardnesstotal ~ gini + gini^2 + gini^3", "Outliers (|RSTUDENT| > 3) of full model\nhardnesstotal ~ nsdp + nsdp^2 + nsdp^3 + gini")) +
  theme(legend.position=c(0.72, 0.9), legend.title=element_blank())

outliers_plot <- ggplot(gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp)) +
  geom_point(alpha=0.2) +
  # stat_smooth(method='lm', formula=y ~ x + I(x**2) + I(x**3), se=FALSE, aes(colour="blue")) +
  ggtitle("Outliers of the full gini model") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  geom_point(data=gini_gwq_nsdp[model_rstudents > 3,], aes(colour="red"), alpha=0.6) +
  scale_discrete_manual(c("colour"), name="Legend", values="red", labels="Outliers (|RSTUDENT| > 3) of full model\nhardnesstotal ~ nsdp + nsdp^2 + nsdp^3 + gini") +
  theme(legend.position=c(0.72, 0.9), legend.title=element_blank())

# Influential observations
dfbetas <- dfbetas(on_nsdp_poly_gini)
dfbetas_cutoff = 2/sqrt(nrow(gini_gwq_nsdp))
beta_infl_obs_idx = rowSums(abs(dfbetas) > dfbetas_cutoff) > 0
dffits <- dffits(on_nsdp_poly_gini)
dffits_cutoff <- 2 * sqrt((length(on_nsdp_poly_gini$coefficients))+1) / sqrt(nrow(gini_gwq_nsdp))
fit_infl_obs_idx = (abs(dffits) > dffits_cutoff) > 0

influence_plot <- ggplot(gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp)) +
  geom_point(alpha=0.2) +
  ggtitle("Influential points of the full gini model") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  geom_point(data=gini_gwq_nsdp[beta_infl_obs_idx,], aes(colour="orange"), alpha=0.4) +
  geom_point(data=gini_gwq_nsdp[fit_infl_obs_idx,], aes(colour="purple"), alpha=0.2, size=3) +
  scale_discrete_manual(c("colour"), name="Legend", values=c("orange", "purple"), labels=c("Beta-influential points", "Fit-influential points")) +
  theme(legend.position=c(0.72, 0.9), legend.title=element_blank())
print(influence_plot)
influential_pts <- gini_gwq_nsdp[beta_infl_obs_idx & fit_infl_obs_idx,]
district_influence <- aggregate(hardnesstotal ~ state + district + year, influential_pts, mean)
district_influence$mean_infl_hardnesstotal <- district_influence$hardnesstotal
district_influence$hardnesstotal <- NULL
district_influence <- district_influence[with(district_influence, order(state)),]
print(district_influence)

state_influence <- aggregate(hardnesstotal ~ state + year, influential_pts, mean)
state_influence$mean_inf_hardnesstotal <- state_influence$hardnesstotal
state_influence$hardnesstotal <- NULL
state_influence <- state_influence[with(state_influence, order(state)),]
print(state_influence)