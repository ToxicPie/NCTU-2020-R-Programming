library(ggplot2)
library(dplyr)
library(countrycode)

begin.date <- "2020-1-22"
end.date <- "2020-12-29"
all_date <- seq.Date(as.Date(begin.date), as.Date(end.date), by = "day") %>% format("%Y-%m-%d")

data <- read.csv("owid-covid-data.csv")
data <- data[,c(1,4,6,12)]
data <- data[-which(data$iso_code == "" | data$iso_code == "OWID_WRL")]
world <- map_data("world")

world$region <- countrycode(world$region, 'country.name', 'iso3c')

myformat <- function(x) {
    return(c("1", "10", "100", "1000", "10000", "100000", "1000000")[as.integer(x) + 1])
}
myformatc <- function(x) {
    return(sapply(x, myformat))
}

png("cases/%03d.png", width = 1920, height = 1080)
for (day in all_date) {
    worldtmp <- left_join(world, data[which(data$date == day), c(1,3,4)], by = c("region"="iso_code"))
    worldtmp$date <- as.POSIXct(day, tz = "GMT")
    worldtmp$new_cases <- as.integer(worldtmp$new_cases)
    worldtmp$new_cases[which(is.na(worldtmp$new_cases))] <- 0
    worldtmp$new_cases_per_million <- as.double(worldtmp$new_cases_per_million)
    worldtmp$new_cases_per_million[which(is.na(worldtmp$new_cases_per_million))] <- 0

    myplot <- ggplot(worldtmp) +
    geom_polygon(aes(x = long, y = lat, group = group, fill = pmax(0, log10(pmax(0, new_cases_per_million)))), color = "grey90") +
        # scale_fill_gradient(limits = c(0, 6)) +
        # scale_fill_gradient(limits = c(0, 6), labels = myformatc) +
        scale_fill_gradient(limits = c(0, 4), labels = myformatc) +
        scale_y_continuous(limits = c(-84, 84), expand = c(0, 0)) +
        scale_x_continuous(limits = c(-170, 200), expand = c(0, 0)) +
        theme(text = element_text(size = 24, family = "Roboto")) +
        labs(title = paste("Date: ", day), fill = "New cases\n(per million)\n", x = "", y = "") +
        guides(fill = guide_colorbar(title.position = "top", barwidth = 2, barheight = 24, direction = "vertical", ticks.linewidth = 2)) +
        theme(legend.justification = c(0, 0.5), legend.position = c(0.01, 0.5), legend.box.just = "right", axis.text = element_blank(),
        axis.ticks = element_blank(), plot.margin = unit(c(10, 25, 0, 0), "points"), panel.grid.major = element_blank(), panel.grid.minor = element_blank())

    print(myplot)
}
dev.off()
