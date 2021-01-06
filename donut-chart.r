library("ggplot2")
library("dplyr")
library("ggpubr")
library("extrafont")

loadfonts()

data <- read.csv("owid-covid-data.csv")

data.total <- data[which(data$date == "2021-01-01"),]

data.total <- data.total[order(data.total$total_cases, decreasing = T),]

data.max5 <- data.total[2:6,]
cases_rate <- data.frame(location = data.max5$location, rate = data.max5$total_cases/data.total[1,"total_cases"])
cases_rate <- rbind(cases_rate, data.frame(location = "Others", rate = 1-sum(cases_rate$rate)))
cases_rate$ymax <- cumsum(cases_rate$rate)
cases_rate$ymin <- c(0, head(cases_rate$ymax, n=-1))
cases_rate$labelPosition <- (cases_rate$ymax + cases_rate$ymin) / 2
cases_rate$labelPosition[5] <- 0.53
cases_rate$label <- paste0(cases_rate$location, "\n", cases_rate$rate%/%0.01, "%")

cases_rate$location <- factor(cases_rate$location, c("United States", "India", "Brazil", "Russia", "France", "Others"))

my.color <- c("#D5538D", "#D265AC", "#9974C3", "#5988DE", "#399FDB", "#2883CC")

ggplot(cases_rate, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=location)) +
    geom_rect() +
    theme(text = element_text(size = 16, family = "Roboto Bold")) +
    geom_text( x=5.5, aes(y=labelPosition, label=label, color=location, family="Roboto", fontface="bold"), size=5, check_overlap = F) +
    scale_fill_manual(values = my.color) +
    scale_color_manual(values = my.color) +
    coord_polar(theta="y") +
    xlim(c(-1, 7)) +
    theme_void() +
    theme_transparent() +
    theme(legend.position = "none")

ggsave("case_rate.svg", bg = "transparent")
