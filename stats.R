library(ggplot2)
library(readr)
library(scales)

gini_gwq_nsdp <- read_csv("output/gini_gwq_nsdp.csv")
gini_gwq_nsdp <- na.omit(gini_gwq_nsdp)

# Total hardness
# hardness_quantiles <- quantile(gini_gwq_nsdp$hardnesstotal)
# ggplot(gini_gwq_nsdp, aes(x="", y=hardnesstotal)) +
#   geom_boxplot(outlier.size=1, outlier.alpha=0.2) +
#   ggtitle("Box plot for total hardness") +
#   xlab("All districts") +
#   ylab("Total hardness (CaCO3, mg/L)") +
#   scale_y_continuous(labels = comma) +
#   geom_hline(aes(yintercept=200), show.legend=TRUE, color="darkgreen") + 
#   geom_hline(aes(yintercept=600), show.legend=TRUE, color="red") +
#   stat_summary(fun.y="mean",color="red", shape=1) +
#   annotate("text", label="200         ", x=-Inf, y=200, size=3, color="darkgreen") +
#   annotate("text", label="                     Acceptable\n", x=-Inf, y=200, size=3, color="darkgreen") +
#   annotate("text", label="600         ", x=-Inf, y=600, size=3, color="red") +
#   annotate("text", label="                     Permissible\n", x=-Inf, y=600, size=3, color="red") +
#   coord_cartesian(clip="off")

cat("Total hardness statistics\n")
cat("Mean total hardness:", mean(gini_gwq_nsdp$hardnesstotal), "mg/L",
    "\nDistricts with acceptable total hardness (%):", mean(gini_gwq_nsdp$hardnesstotal <= 200) * 100, "%",
    "\nDistricts with permissible total hardness (%):", mean(gini_gwq_nsdp$hardnesstotal <= 600) * 100, "%",
    "\nDistricts with impermissible total hardness (%):", mean(gini_gwq_nsdp$hardnesstotal > 600) * 100, "%",
    "\nMean impermissible total hardness:", mean(gini_gwq_nsdp$hardnesstotal[gini_gwq_nsdp$hardnesstotal > 600]), "mg/L\n",
    "Hardness quantiles:"
)
print(hardness_quantiles)
cat("\n")

# NSDP
cat("NSDP statistics\n")
nsdp_quantiles <- quantile(unique(gini_gwq_nsdp$nsdp))
cat("Mean NSDP:", mean(gini_gwq_nsdp$hardnesstotal), " (Rupees Crore)\nNSDP quantiles:")
print(nsdp_quantiles)
cat("\n")

# Gini
cat("Gini index statistics\n")
gini_quantiles <- quantile(unique(gini_gwq_nsdp$gini))
cat("Mean gini index:", mean(gini_gwq_nsdp$gini), "\nGini index quantiles:")
print(gini_quantiles)
cat("\n")