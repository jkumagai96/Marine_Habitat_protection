# Joy Kumagai 
# Date: March 2021
# Statistics
# Marine Habitat Protection Indicator

##### Load Packages #####
library(tidyverse) # Easily Install and Load the 'Tidyverse'

data <- read.csv("Data_final/percent_protected_boundaries.csv")

n_zero <- data %>% 
  filter(pp_mean_all == 0) %>% 
  count()/(length(unique(data$habitat)))

n_hundred <- data %>% 
  filter(pp_mean_all == 100) %>% 
  count()/(length(unique(data$habitat)))

n <- data %>% 
drop_na(pp_mean_all) %>% 
  count()/(length(unique(data$habitat))) 

indicator <- data %>% 
  group_by(UNION) %>% 
  summarize(mean(pp_mean_all))

colnames(indicator) <- c("Area", "Indicator")
hist(indicator$Indicator)
quantile(indicator$Indicator, na.rm = TRUE)

data %>% 
  filter(pp_mean_all < 25) %>% 
  count()/(length(unique(data$habitat)))

