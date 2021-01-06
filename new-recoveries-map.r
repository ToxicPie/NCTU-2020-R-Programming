library(ggplot2)
library(dplyr)
library(countrycode)


begin.date <- "2020-1-22"
end.date <- "2020-12-29"
all_date <- seq.Date(as.Date(begin.date), as.Date(end.date), by = "day") %>% format("%Y-%m-%d")

data <- read.csv("owid-covid-data.csv")
data <- data[,c(1,4,6,38)]
data <- data[-which(data$iso_code == "" | data$iso_code == "OWID_WRL")]
world <- map_data("world")

world$region <- countrycode(world$region, 'country.name', 'iso3c')

data.recover <- read.csv("time_series_covid19_recovered_global.csv")
data.recover2 <- data.recover[1,]

for (i in 2 : nrow(data.recover)) {
    if (data.recover2$Country.Region[nrow(data.recover2)] != data.recover$Country.Region[i]) {
        data.recover2 <- rbind(data.recover2, data.recover[i,])
    } else {
        for (j in 5 : length(data.recover2)) {
            data.recover2[nrow(data.recover2), j] <- data.recover2[nrow(data.recover2), j] + data.recover[i, j]
        }
    }
}

for (i in 1 : nrow(data.recover2)) {
    for (j in length(data.recover2) : 6) {
        data.recover2[i, j] <- data.recover2[i, j] - data.recover2[i, j - 1]
    }
}

data.recover2$Country.Region <- countrycode(data.recover2$Country.Region, origin = "country.name", destination = "iso3c")
data.recover2 <- data.recover2[-which(is.na(data.recover2$Country.Region)),]

myformat <- function(x) {
    return(c("0.00001", "0.0001", "0.001", "0.01", "0.1", "1", "10", "100", "1000", "10000")[as.integer(x) + 5])
}
myformatc <- function(x) {
    return(sapply(x, myformat))
}

mylog10 <- function(x) {
    if (is.na(x) | is.infinite(x) | x <= 0) {
        return(-4)
    } else {
        return(log10(x))
    }
}
mylog10c <- function(x) {
    return(sapply(x, mylog10))
}

png("rec/%03d.png", width = 1920, height = 1080)
for (i in 1 : length(all_date)) {
    worldtmp <- left_join(world, data[which(data$date == all_date[i]), c(1,3,4)], by = c("region"="iso_code"))
    worldtmp$date <- as.POSIXct(all_date[i], tz = "GMT")
    worldtmp$new_cases <- as.integer(worldtmp$new_cases)
    worldtmp$new_cases[which(is.na(worldtmp$new_cases))] <- 0
    worldtmp <- left_join(worldtmp, data.recover2[, c(2, i + 4)], by = c("region"="Country.Region"))

    myplot <- ggplot(worldtmp) +
        geom_polygon(aes(x = long, y = lat, group = group, fill = mylog10c(worldtmp[, 10] / population * 1e6)), color = "grey90") +
        scale_fill_gradient(limits = c(-4, 4), labels = myformatc) +
        scale_y_continuous(limits = c(-84, 84), expand = c(0, 0)) +
        scale_x_continuous(limits = c(-170, 200), expand = c(0, 0)) +
        theme(text = element_text(size = 24, family = "Roboto")) +
        labs(title = paste("Date: ", all_date[i]), fill = "New recoveries\n(per million)\n", x = "", y = "") +
        guides(fill = guide_colorbar(title.position = "top", barwidth = 2, barheight = 24, direction = "vertical", ticks.linewidth = 2)) +
        theme(legend.justification = c(0, 0.5), legend.position = c(0.01, 0.5), legend.box.just = "right", axis.text = element_blank(),
        axis.ticks = element_blank(), plot.margin = unit(c(10, 25, 0, 0), "points"), panel.grid.major = element_blank(), panel.grid.minor = element_blank())

    print(myplot)
}
dev.off()
