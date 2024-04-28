library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)

# Total hardness
hardness_plot <- ggplot(gini_gwq_nsdp, aes(x="", y=hardnesstotal)) +
  geom_boxplot(outlier.size=1, outlier.alpha=0.2) +
  ggtitle("Box plot for total hardness") +
  xlab("All districts") +
  ylab("Total hardness (CaCO3, mg/L)") +
  scale_y_continuous(labels = comma) +
  geom_hline(aes(yintercept=200), show.legend=TRUE, color="darkgreen") +
  geom_hline(aes(yintercept=600), show.legend=TRUE, color="red") +
  stat_summary(fun="mean",color="red", shape=1) +
  annotate("text", label="200         ", x=-Inf, y=200, size=3, color="darkgreen") +
  annotate("text", label="                     Acceptable\n", x=-Inf, y=200, size=3, color="darkgreen") +
  annotate("text", label="600         ", x=-Inf, y=600, size=3, color="red") +
  annotate("text", label="                     Permissible\n", x=-Inf, y=600, size=3, color="red") +
  coord_cartesian(clip="off")

print(hardness_plot)

cat("Total hardness statistics\n")
hardness_quantiles <- quantile(gini_gwq_nsdp$hardnesstotal, probs=c(0.25, 0.5, 0.75, 0.95))
acceptable <- mean(gini_gwq_nsdp$hardnesstotal <= 200) * 100
permissible <- mean(gini_gwq_nsdp$hardnesstotal <= 600) * 100
impermissible <- mean(gini_gwq_nsdp$hardnesstotal > 600) * 100
mean_impermissible_hardness <- mean(gini_gwq_nsdp$hardnesstotal[impermissible])
cat("Mean total hardness:", mean(gini_gwq_nsdp$hardnesstotal), "mg/L\n")
cat("Districts with acceptable total hardness (%):", acceptable, "%\n")
cat("Districts with permissible total hardness (%):", permissible, "%\n")
cat("Districts with impermissible total hardness (%):", impermissible, "%\n")
cat("Mean impermissible total hardness:", mean_impermissible_hardness, "mg/L\n")
cat("Hardness quantiles:\n")
print(hardness_quantiles)
cat("\n")

# NSDP
cat("NSDP statistics\n")
nsdp_quantiles <- quantile(unique(gini_gwq_nsdp$nsdp), probs=c(0.25, 0.5, 0.75, 0.95))
cat("Mean NSDP:", mean(gini_gwq_nsdp$hardnesstotal), " (Rupees Crore)\nNSDP quantiles:\n")
print(nsdp_quantiles)
cat("\n")

# Gini
cat("Gini index statistics\n")
gini_quantiles <- quantile(unique(gini_gwq_nsdp$gini), probs=c(0.25, 0.5, 0.75, 0.95))
cat("Mean gini index:", mean(gini_gwq_nsdp$gini), "\nGini index quantiles:\n")
print(gini_quantiles)
cat("\n")
