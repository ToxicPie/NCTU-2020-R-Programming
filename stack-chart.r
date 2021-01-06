library("ggplot2")
library("dplyr")
library("ggpubr")
library("scales")
library("extrafont")

loadfonts()

data.raw <- read.csv("owid-covid-data.csv")
max5 <- c("United States", "India", "Brazil", "Russia", "France", "World")

data <- data.raw[which(data.raw$location != max5[1] &
                       data.raw$location != max5[2] &
                       data.raw$location != max5[3] &
                       data.raw$location != max5[4] &
                       data.raw$location != max5[5] &
                       data.raw$location != max5[6]),]

data <- data[which(is.na(data$total_cases) == F),]

data <- data %>% group_by(date) %>% summarise(total_cases = sum(total_cases), location = "Others")

for(i in 1:5){
    data <- rbind.data.frame(data, data.raw[which(data.raw$location == max5[i]),names(data)])
}

data$location <- factor(data$location, c("United States", "India", "Brazil", "Russia", "France", "Others"))

my.color <- c("#D5538D", "#D265AC", "#9974C3", "#5988DE", "#399FDB", "#2883CC")

ggplot(data, aes(x = as.POSIXct(date, "%Y-%m-%d", tz = "GMT"), y = total_cases, fill = location)) +
    geom_area() +
    theme(text = element_text(size = 16, family = "Roboto")) +
    scale_fill_manual(values = my.color) +
    scale_x_datetime(labels = date_format("%m")) +
    theme(
        panel.background = element_rect(fill = "transparent"), # bg of the panel
        plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
        legend.background = element_rect(fill = "transparent"), # get rid of legend bg
        plot.title = element_text(size=11)
    ) + xlab("Date") + ylab("Total cases")

ggsave("total_cases.svg", bg = "transparent", width = 9)
