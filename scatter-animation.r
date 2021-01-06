library(dplyr)
library(ggplot2)
library(gganimate)
library(scales)
library(ggpubr)
library(scales)

data <- read.csv("owid-covid-data.csv")

data <- data[which(data$location != "World" & data$location != "International"),]

data$date <- as.POSIXct(data$date, format = "%Y-%m-%d")

framec <- 367

myformat <- function(x) {
    if (is.na(x)) {
        return("NA")
    } else if (abs(x) < 1 & abs(x) > 5e-3) {
        return(scales::label_number(accuracy = 0.01, big.mark = "")(x))
    } else {
        return(scales::label_number(accuracy = 1, big.mark = "")(x))
    }
}
myformatc <- function(x) {
    return(sapply(x, myformat))
}

myplot <- ggplot(data, aes(total_cases_per_million, total_deaths / total_cases, size = population / 1e6, color = human_development_index)) +
    geom_point() +
    scale_size(breaks = c(1, 10, 100, 500, 1000), range = c(2, 15)) +
    scale_colour_gradient(limits = c(0.1, 0.9)) +
    theme(text = element_text(size = 18, family = "Roboto")) +
    labs(title = 'Date: {format(frame_time, "%Y-%m-%d")}', x = 'Total cases per million', y = 'Death rate', size = "Population (Millions)", color = "Human development index") +
    guides(color = guide_colorbar(title.position = "top", barwidth = 12, barheight = 1, direction = "horizontal", ticks.linewidth = 2), size = guide_legend(nrow = 1)) +
    transition_time(date) +
    ease_aes('linear')

plot_log <- myplot + scale_x_log10(labels = myformatc) + scale_y_log10(labels = myformatc) +
    theme(legend.justification = c(1, 0), legend.position = c(0.99, 0.01), legend.box.just = "right")

animate(plot_log, width = 960, height = 1080, nframes = framec, device = "png", renderer = file_renderer("death-rate-log/", prefix = "plot", overwrite = TRUE))

plot_lin <- myplot + scale_x_log10(labels = myformatc) + scale_y_continuous(labels = myformatc) +
    theme(legend.position = "none")

animate(plot_lin, width = 960, height = 1080, nframes = framec, device = "png", renderer = file_renderer("death-rate-lin/", prefix = "plot", overwrite = TRUE))
