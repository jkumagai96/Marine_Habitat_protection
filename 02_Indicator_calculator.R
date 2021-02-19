
# Loading libraries -------------------------------------------------------

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(stringr) # Simple, Consistent Wrappers for Common String Operations
library(janitor) # Simple Tools for Examining and Cleaning Dirty Data
library(ggthemes) # Extra Themes, Scales and Geoms for 'ggplot2', CRAN v4.2.4

library(patchwork) # The Composer of Plots, CRAN v1.1.1
theme_set(theme_few())


# Data loading ------------------------------------------------------------

# GDP data

GDP <- read.csv('data/GDP.csv') %>% 
  select(ISO, GDP_last) %>% 
  rename(ISO_SOV1 = ISO)

# landlocked countries
landlocked <- read.csv('data/landlocked.csv') %>% 
  clean_names()

landlocked <- landlocked$i_country # creates a vector of countries to eliminate


# percent protection data

perc <- read.csv('data/percent_protected_boundaries.csv')



# Data wrangling ----------------------------------------------------------


# filtering out landlocked countries
perc <- perc %>% 
  filter(!UNION %in% landlocked)

# creating habitat categories
perc$habitats <- factor(perc$category, labels = c(
  "ColdCorals",
  "ColdCorals_allmpa",
  "ColdCorals_managed", 
  "ColdCorals_notake",
  "CoralReefs",
  "CoralReefs_allmpa",
  "CoralReefs_managed",
  "CoralReefs_notake",
  "Mangroves",
  "Mangroves_allmpa",
  "Mangroves_managed", 
  "Mangroves_notake",
  "Saltmarshes",
  "Saltmarshes_allmpa",
  "Saltmarshes_managed",
  "Saltmarshes_notake",
  "Seagrasses",
  "Seagrasses_allmpa",
  "Seagrasses_managed", 
  "Seagrasses_notake"
))


# separating habitats and level of protection and widen the data
effort_table <- perc %>%
  separate(habitats, c("habitats", "protection")) %>%
  mutate(protection = replace_na(protection, replace = "total_area")) %>%
  pivot_wider(UNION:habitats,
              names_from = "protection",
              values_from = "pixel_counts") %>%
  group_by(ISO_SOV1, habitats) %>% # I will summarize by SOVEREINITY, since it represents better the authority on the area
  summarise_at(c("total_area", "allmpa", "managed", "notake"), sum, na.rm = TRUE) %>%
  merge(., GDP, by = "ISO_SOV1", all.x = TRUE) %>%
  filter(total_area > 0) %>% # Filtering ones with NO habitat
  ungroup() %>%
  mutate(GDP_perc = round((GDP_last / sum(GDP_last, na.rm = T) * 100), 6)) %>%
  group_by(ISO_SOV1, habitats) %>%  #creating world stat
  mutate(mpa_perc = (allmpa / sum(total_area)) * 100)



# Effort by country -------------------------------------------------------

effort_country <- effort_table %>% 
  group_by(ISO_SOV1) %>% 
  summarise(total_habitat_area = sum(total_area),
            GDP_last = mean(GDP_last, na.rm = T), 
            GDP_perc = mean(GDP_perc, na.rm = T),
            mpa_perc_m = mean(mpa_perc, na.rm = T))




# Graphs ------------------------------------------------------------------

# How much countries are protecting

effort_country %>% 
  ggplot(aes(x = mpa_perc_m)) +
  geom_density(fill = "#2a9d8f", col = "#264653") + 
  labs(x = "Average % protected", y = "Value density")


effort_country %>% 
  ggplot(aes(x = log1p(GDP_last), y = log1p(mpa_perc_m), label = ISO_SOV1)) +
  #geom_point() +
  geom_text_repel(size = 3.5)





# Conceptualization -------------------------------------------------------


#' We have how a country protect on average by %
#' We have the GDP of the country
#' We create intervals of GDP to contextualize countries
#' We plot conservation % by each bin

# We standardize the GDP and round the value

effort_country_complete <- effort_country %>% 
  filter(!is.na(GDP_last))

effort_country_complete$GDP_index <- round(log1p(effort_country_complete$GDP_last), 0)

# we check the full range
range(effort_country_complete$GDP_index, na.rm = T)

# creating GDP intervals
effort_country_complete$GDP_breaks <- cut(effort_country_complete$GDP_index,
                                 breaks = seq(min(effort_country_complete$GDP_index, na.rm = T), 
                                              max(effort_country_complete$GDP_index, na.rm = T) + 4, 
                                              by = 4), 
                                 include.lowest = T, right = FALSE,
                                 labels = c("low", "medium", "high", "very high"))

# check the intervals (how many countries within intervals)
summary(effort_country_complete$GDP_breaks)

country_effort_gap <- effort_country_complete %>% 
  select(ISO_SOV1, GDP_breaks, mpa_perc_m) %>% 
  group_by(GDP_breaks) %>% 
  mutate(mean_effort = mean(mpa_perc_m),
         effort_gap = mpa_perc_m - mean_effort) %>% 
  mutate(color = ifelse(effort_gap < 0, "under", "over"))

country_effort_gap %>% 
  select(ISO_SOV1, GDP_breaks, effort_gap, color) %>% 
  arrange(GDP_breaks, effort_gap) %>% 
  filter(ISO_SOV1 == "POL")

# Plotting 
country_effort_gap$effort_gap <- (round(country_effort_gap$effort_gap, digits = 1))


(
  p1 <- country_effort_gap %>%
    filter(color == "over") %>%
    ggplot(aes(
      reorder(ISO_SOV1, -effort_gap),
      effort_gap,
      col = color,
      label = round(effort_gap, 1)
    )) +
    geom_segment(aes(
      x = reorder(ISO_SOV1, -effort_gap),
      xend = reorder(ISO_SOV1, -effort_gap),
      y = 0,
      yend = effort_gap
    )) +
    #geom_point(size = 4) +
    geom_text(aes(label = format(effort_gap,  nsmall = 1),
                  hjust = ifelse(effort_gap >= 0, 0, 1), 
                  vjust = .5), 
              angle = 90) +
    scale_color_manual(values = c("#83c5be", "#e29578")) +
    scale_y_continuous(limits = c(-100, 100)) +
    #coord_flip() +
    geom_hline(yintercept = 0, col = "gray80") + 
    labs(x = "ISO codes", y = "Effort gap %", subtitle = "Positive Gap") +
    theme(legend.position = "", 
          text = element_text(family = "serif"),
          axis.text.y = element_text(size = 8), 
          axis.text.x = element_text(angle = 90)
    )
)

(
  p2 <- country_effort_gap %>%
    filter(color == "under") %>%
    ggplot(aes(
      reorder(ISO_SOV1, -effort_gap),
      effort_gap,
      col = color,
      label = round(effort_gap, 1)
    )) +
    geom_segment(aes(
      x = reorder(ISO_SOV1, -effort_gap),
      xend = reorder(ISO_SOV1, -effort_gap),
      y = 0,
      yend = effort_gap
    )) +
    #geom_point(size = 4) +
    geom_text(aes(label = format(effort_gap,  nsmall = 1),
                  hjust = ifelse(effort_gap >= 0, 0, 1), 
                  vjust = .5), 
              angle = 90) +
    scale_color_manual(values = c("#e29578")) +
    scale_y_continuous(limits = c(-100, 100)) +
    #coord_flip() +
    geom_hline(yintercept = 0, col = "gray80") + 
    labs(x = "ISO codes", y = "Effort gap %", subtitle = "Negative Gap") +
    theme(legend.position = "", 
          text = element_text(family = "serif"),
          axis.text.y = element_text(size = 8), 
          axis.text.x = element_text(angle = 90)
    )
)



# Effort Gap Figure -------------------------------------------------------


p1/p2


# Saving (it is better to see the saved version)
ggsave("effort_gap.jpeg", dpi = 300, height = 6, width = 12)




# Effort by habitat -------------------------------------------------------

## Habitat effort 

effort_table %>% 
  group_by(habitats) %>%
  mutate(
    mean_effort = mean(mpa_perc),
    median_effort = median(mpa_perc),
    effort_gap_habitat = mean_effort - median_effort
  ) %>%
  group_by(ISO_SOV1, habitats) %>%
  mutate(effort_gap_country = mean_effort - mpa_perc) %>%
  select(
    ISO_SOV1,
    habitats,
    GDP_perc,
    mpa_perc,
    mean_effort,
    median_effort,
    effort_gap_habitat,
    effort_gap_country
  ) %>%
  mutate(increase = mpa_perc + effort_gap_country) %>%
  ggplot(aes(x = habitats, y = mpa_perc, label = ISO_SOV1)) +
  geom_point(aes(x = habitats, y = mpa_perc, size = GDP_perc), col = "gray80") +
  geom_point(aes(x = habitats, y = mean_effort),
             col = "blue",
             size = 2) +
  geom_point(aes(x = habitats, y = median_effort),
             col = "red",
             size = 2) +
  geom_hline(yintercept = 30) +
  coord_flip() +
  theme_bw()
  

# Saving Habitat effort gap table

effort_table %>%
  group_by(habitats) %>% 
  mutate(mean_effort = mean(mpa_perc),
         median_effort = median(mpa_perc),
         effort_gap_habitat = mean_effort - median_effort) %>%
  group_by(ISO_SOV1, habitats) %>% 
  mutate(effort_gap_country = mean_effort - mpa_perc) %>% 
  select(ISO_SOV1, habitats, GDP_perc, mpa_perc, mean_effort, median_effort, effort_gap_habitat, effort_gap_country) %>% 
  write.csv(., 'effort_gap.csv', row.names = F)



# END OF SCRIPT -----------------------------------------------------------




