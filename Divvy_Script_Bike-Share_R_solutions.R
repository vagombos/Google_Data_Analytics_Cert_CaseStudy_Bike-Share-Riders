# Based on the Divvy R script provided by Google for the Data Analytics Case Study 1 Capstone
# Has been altered where appropriate as current dataset is different than the one from this exercise

library(tidyverse)
library(lubridate)

getwd()
setwd("C:/Users/Victor/Documents/Data Science Projects/Google Capstone/Google Provided Case Study 1-Bike-Share/Data Sources")

# Collecting Data (note that file names were simplified from original dataset)
ym_202202 <- read_csv("tripdata_202202.csv")
ym_202203 <- read_csv("tripdata_202203.csv")
ym_202204 <- read_csv("tripdata_202204.csv")
ym_202205 <- read_csv("tripdata_202205.csv")
ym_202206 <- read_csv("tripdata_202206.csv")
ym_202207 <- read_csv("tripdata_202207.csv")
ym_202208 <- read_csv("tripdata_202208.csv")
ym_202209 <- read_csv("tripdata_202209.csv")
ym_202210 <- read_csv("tripdata_202210.csv")
ym_202211 <- read_csv("tripdata_202211.csv")
ym_202212 <- read_csv("tripdata_202212.csv")
ym_202301 <- read_csv("tripdata_202301.csv")

# Note that original Divvy R script has renaming of any non-matching columns, but the monthly data already contains matching column names
# Converting ride_id to character
ym_202202 <- mutate(ym_202202, ride_id = as.character(ride_id))
ym_202203 <- mutate(ym_202203, ride_id = as.character(ride_id))
ym_202204 <- mutate(ym_202204, ride_id = as.character(ride_id))
ym_202205 <- mutate(ym_202205, ride_id = as.character(ride_id))
ym_202206 <- mutate(ym_202206, ride_id = as.character(ride_id))
ym_202207 <- mutate(ym_202207, ride_id = as.character(ride_id))
ym_202208 <- mutate(ym_202208, ride_id = as.character(ride_id))
ym_202209 <- mutate(ym_202209, ride_id = as.character(ride_id))
ym_202210 <- mutate(ym_202210, ride_id = as.character(ride_id))
ym_202211 <- mutate(ym_202211, ride_id = as.character(ride_id))
ym_202212 <- mutate(ym_202212, ride_id = as.character(ride_id))
ym_202301 <- mutate(ym_202301, ride_id = as.character(ride_id))

# Stacking all rides for all months into one dataframe
all_trips <- bind_rows(ym_202202, ym_202203, ym_202204, ym_202205, ym_202206, ym_202207, ym_202208, ym_202209, ym_202210, ym_202211, ym_202212, ym_202301)

# Removing irrelvant fields: latitudes, longitudes
all_trips <- all_trips %>%
  select(-c(start_lat, start_lng, end_lat, end_lng))

# Inspect the new table that has been created
colnames(all_trips)  #List of column names
nrow(all_trips)  #How many rows are in data frame?
dim(all_trips)  #Dimensions of the data frame?
head(all_trips)  #See the first 6 rows of data frame.  Also tail(all_trips)
str(all_trips)  #See list of columns and data types (numeric, character, etc)
summary(all_trips)  #Statistical summary of data. Mainly for numerics

# There are a few problems we will need to fix (Note, this has been altered from the original R script as the new monthly dataset does not contain the member_casual data entry variances):
# (1) The data can only be aggregated at the ride-level, which is too granular. We will want to add some additional columns of data -- such as day, month, year -- that provide additional opportunities to aggregate the data.
# (2) We will want to add a calculated field for length of ride since the 2020Q1 data did not have the "tripduration" column. We will add "ride_length" to the entire dataframe for consistency.
# (3) There are some rides where tripduration shows up as negative, including several hundred rides where Divvy took bikes out of circulation for Quality Control reasons. We will want to delete these rides.

# (1) Add columns for month, day, and year for each ride
all_trips$date <- as.Date(all_trips$started_at) #The default format is yyyy-mm-dd
all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")

# (2) Add calculated field "ride_length" to all_trips (in seconds)
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)
# Convert "ride_length" from Factor to numeric so we can run calculations on the data
is.factor(all_trips$ride_length)
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)

# (3) Remove "bad" data
# The dataframe includes a few hundred entries when bikes were taken out of docks and checked for quality by Divvy or ride_length was negative
# We will create a new version of the dataframe (v2) since data is being removed
all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length<0),]

# Descriptive analysis on ride_length (all figures in seconds)
summary(all_trips_v2$ride_length)

# Compare members and casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)

# See the average ride time by each day for members vs casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# Notice that the days of the week are out of order. Let's fix that.
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

# Now, let's run the average ride time by each day for members vs casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# analyze ridership data by type and weekday
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%  #creates weekday field using wday()
  group_by(member_casual, weekday) %>%  #groups by usertype and weekday
  summarise(number_of_rides = n()	#calculates the number of rides and average duration 
            ,average_duration = mean(ride_length)) %>% 		# calculates the average duration
  arrange(member_casual, weekday)								# sorts

# Let's visualize the number of rides by rider type
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")

# Let's create a visualization for average duration
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")

# EXPORT SUMMARY FILE FOR FURTHER ANALYSIS
# Create a csv file that we will visualize in Excel, Tableau, or my presentation software
counts <- aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
write.csv(counts, file = 'C:/Users/Victor/Documents/Data Science Projects/Google Capstone/Google Provided Case Study 1-Bike-Share/Data Sources/avg_ride_length.csv')
