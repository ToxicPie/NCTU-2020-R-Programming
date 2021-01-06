library("dplyr")

begin.date <- "2020-01-22"
end.date <- "2020-12-29"
date.seq <- seq.Date(as.Date(begin.date), as.Date(end.date), by = "day") %>% format("%m-%d-%Y")

data.raw <- date.seq[1] %>% paste(".csv", sep = "") %>% read.csv()
data.raw$Province.State <- NULL
colnames(data.raw) <- c("Country","Update","Confirmed","Deaths","Recovered")

for(i in 2:length(date.seq)){
    data.temp <- date.seq[i] %>% paste(".csv", sep = "") %>% read.csv()
    for(j in 1:length(data.raw[0,])){
        colnames(data.temp)[grepl(colnames(data.raw)[j],colnames(data.temp))] <- colnames(data.raw)[j]
    }
    data.raw <- rbind.data.frame(data.raw, data.temp[, names(data.raw)])
}

data.raw[is.na(data.raw)] <- 0
my.format <- c("%m/%d/%y %H:%M","%Y/%m/%d  %H:%M:%S PM","%Y/%m/%d  %H:%M:%S AM",
               "%m/%d/%Y %H:%M","%Y-%m-%dT%H:%M:%S","%Y-%m-%d %H:%M:%S")

data <- data.raw %>% group_by(Update, Country) %>%
    summarise(Confirmed =  sum(Confirmed), Deaths = sum(Deaths), Recovered = sum(Recovered))
for(i in 1:length(data$Update)){
    data[i,"Update"] <- format(as.POSIXlt(toString(data[i,"Update"]), tryFormats = my.format), format = "%y/%m/%d")
}
data <- data %>% group_by(Update, Country) %>%
    summarise(Confirmed =  sum(Confirmed), Deaths = sum(Deaths), Recovered = sum(Recovered))

write.csv(data, "my_daily_report_summarise.csv")
