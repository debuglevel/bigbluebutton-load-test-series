ggplotRegression <- function (fit, idx) {
  require(ggplot2)
  
  ggplot(fit$model, aes_string(x = names(fit$model)[idx], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("AdjR2=", signif(summary(fit)$adj.r.squared, 2),
                       "Intercept=", signif(fit$coef[[1]], 2),
                       " Slope=", signif(fit$coef[[idx]], 2),
                       " P=", signif(summary(fit)$coef[idx,4], 2)))
}

library(readr)
cpu_load <- read_csv("../cpu_load.csv", 
                     col_types = cols(webcams = col_integer(), 
                                      bitrate = col_integer(), framerate = col_integer(), 
                                      sample = col_integer(), cpu = col_integer()))
#View(cpu_load)

model <- lm(cpu ~ webcams + bitrate + framerate, data = cpu_load)
summary(model)

ggplotRegression(model, 2)
ggplotRegression(model, 3)
ggplotRegression(model, 4)


# #install.packages("ggiraphExtra")
# require(ggplot2)
# require(ggiraph)
# require(ggiraphExtra)
# require(plyr)
# ggPredict(model, se=TRUE, interactive=FALSE)
