library(ggplot2)
library(readr)
library(scales)
library(data.table)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)
gini_gwq_nsdp <- gini_gwq_nsdp[gini_gwq_nsdp$hardnesstotal > 0,]
on_nsdp_quad_gini <- lm(formula=hardnesstotal ~ nsdp + I(nsdp**2) + gini, data=gini_gwq_nsdp)
on_nsdp_poly_gini <- lm(formula=hardnesstotal ~ nsdp + I(nsdp**2) + I(nsdp**3) + gini, data=gini_gwq_nsdp)
print(summary(on_nsdp_quad_gini))
print(summary(on_nsdp_poly_gini))

coefs_poly = coef(on_nsdp_poly_gini)
f <- function(x){coefs_poly[1] + coefs_poly[2]*x + coefs_poly[3]*x^2 + coefs_poly[4]*x^3}
coefs_quad = coef(on_nsdp_quad_gini)
f_quad <- function(x){coefs_quad[1] + coefs_quad[2]*x + coefs_quad[3]*x^2}

model_rstudents <- rstudent(on_nsdp_poly_gini)

nsdp_trend_plot <- ggplot(gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp)) +
  geom_point() +
  # stat_smooth(method='lm', formula=y ~ x + I(x**2) + I(x**3), se=TRUE, aes(colour="blue")) +
  stat_function(fun=f, aes(colour="blue"), linewidth=1) +
  ggtitle("Partial dependence plot of total hardness on NSDP") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  # stat_smooth(method='lm', formula=y ~ x + I(x**2), se=TRUE, aes(colour="red")) +
  stat_function(fun=f_quad, aes(colour="red"), linewidth=1) +
  scale_discrete_manual(c("colour"), name="Legend", values=c("blue", "red"), labels=c("hardnesstotal ~ nsdp + nsdp^2 + nsdp^3 + gini\n(partial effect)\n", "hardnesstotal ~ nsdp + nsdp^2 + gini\n(partial effect)\n")) +
  theme(legend.position=c(0.72, 0.88), legend.title=element_blank())

gini_trend_plot <- ggplot(gini_gwq_nsdp, aes(y=hardnesstotal, x=gini)) +
  geom_point(alpha=0.2) +
  geom_abline(intercept=coefs_poly[1], slope=coefs_poly[5], colour="blue", linewidth=1) +
  geom_abline(intercept=coefs_poly[1], slope=0, colour="black", linetype="dashed") +
  ggtitle("Total hardness vs Gini") +
  xlab("Gini index") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  scale_discrete_manual(c("colour"), name="Legend", values="blue", labels="hardnesstotal ~ nsdp + nsdp^2 + nsdp^3 + gini\n(partial effect)\n") +
  theme(legend.position=c(0.72, 0.9), legend.title=element_blank())

outliers_plot <- ggplot(gini_gwq_nsdp, aes(y=hardnesstotal, x=nsdp)) +
  geom_point(alpha=0.2) +
  # stat_smooth(method='lm', formula=y ~ x + I(x**2) + I(x**3), se=FALSE, aes(colour="blue")) +
  ggtitle("Outliers of the cubic-NSDP gini model") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  geom_point(data=gini_gwq_nsdp[abs(model_rstudents) > 3,], aes(colour="red"), alpha=0.6) +
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
  ggtitle("Influential points of the model") +
  xlab("NSDP (Rupees Crore)") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_x_continuous(labels = comma) +
  coord_cartesian(expand = FALSE) +
  geom_point(data=gini_gwq_nsdp[beta_infl_obs_idx,], aes(colour="orange"), alpha=0.4) +
  geom_point(data=gini_gwq_nsdp[fit_infl_obs_idx,], aes(colour="purple"), alpha=0.2, size=3) +
  scale_discrete_manual(c("colour"), name="Legend", values=c("orange", "purple"), labels=c("Slope-influential points", "Fit-influential points")) +
  theme(legend.position=c(0.72, 0.9), legend.title=element_blank())

png("plots/Partial dependence plot of total hardness on NSDP.png")
print(nsdp_trend_plot)
dev.off()
print(nsdp_trend_plot)

png("plots/Outliers of the cubic-NSDP gini model.png")
print(outliers_plot)
dev.off()
print(outliers_plot)

png("plots/Influential points of the model.png")
print(influence_plot)
dev.off()
print(influence_plot)

png("plots/Gini trend.png")
print(gini_trend_plot)
dev.off()
print(gini_trend_plot)

outlier_pts <- gini_gwq_nsdp[abs(model_rstudents) > 3,]
outlier_pts_dt <- setDT(outlier_pts)
influential_pts <- gini_gwq_nsdp[beta_infl_obs_idx | fit_infl_obs_idx,]
influential_pts_dt <- setDT(influential_pts)

cat("\n\nInfluential points:\n")
df <- influential_pts[with(influential_pts, order(state, district, year, hardnesstotal))][, c("state", "district", "year", "hardnesstotal")]
print(nrow(df))
print(df, nrow=nrow(df)*ncol(df))

cat("Influential points count by district:\n")
district_influence <- aggregate(hardnesstotal ~ state + district, influential_pts, NROW)
district_influence <- district_influence[with(district_influence, order(state, district)),]
district_influence$n_inflpts <- district_influence$hardnesstotal
district_influence$hardnesstotal <- NULL
print(district_influence)

cat("Influential points by state:\n")
state_influence <- aggregate(hardnesstotal ~ state, influential_pts, NROW)
state_influence <- state_influence[with(state_influence, order(state)),]
state_influence$n_inflpts <- state_influence$hardnesstotal
state_influence$hardnesstotal <- NULL
print(state_influence)

cat("\n\nOutliers:\n")
print(outlier_pts[with(outlier_pts, order(state, district, year, hardnesstotal))][, c("state", "district", "year", "hardnesstotal")])

cat("Outlier count by district:\n")
district_outliers <- aggregate(hardnesstotal ~ state + district, outlier_pts, NROW)
district_outliers <- district_outliers[with(district_outliers, order(state, district)),]
district_outliers$n_outliers <- district_outliers$hardnesstotal
district_outliers$hardnesstotal <- NULL
print(district_outliers)

cat("Outlier count by state:\n")
state_outliers <- aggregate(hardnesstotal ~ state, outlier_pts, NROW)
state_outliers <- state_outliers[with(state_outliers, order(state)),]
state_outliers$n_outliers <- state_outliers$hardnesstotal
state_outliers$hardnesstotal <- NULL
print(state_outliers)