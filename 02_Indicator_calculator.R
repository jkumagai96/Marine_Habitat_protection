
# Loading libraries -------------------------------------------------------

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(stringr) # Simple, Consistent Wrappers for Common String Operations
library(janitor) # Simple Tools for Examining and Cleaning Dirty Data

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
perc_wide <- perc %>% 
  separate(habitats, c("habitats", "protection")) %>% 
  mutate(protection = replace_na(protection, replace = "total_area")) %>% 
  pivot_wider(names_from = protection, values_from = pixel_counts) %>% 
  mutate_if(is.numeric, ~replace_na(., 0))






perc %>%
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
  mutate(mpa_perc = (allmpa / sum(total_area)) * 100) %>%
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
  #geom_point(col = "gray50")+
  geom_point(aes(x = habitats, y = mean_effort),
             col = "blue",
             size = 2) +
  geom_point(aes(x = habitats, y = median_effort),
             col = "red",
             size = 2) +
  geom_hline(yintercept = 30) +
  #geom_text(size = 2) +
  coord_flip() +
  theme_bw()
  

 




# Saving effort gap table

perc %>% 
  separate(habitats, c("habitats", "protection")) %>% 
  mutate(protection = replace_na(protection, replace = "total_area")) %>% 
  pivot_wider(UNION:habitats, names_from = "protection", values_from = "pixel_counts") %>% 
  group_by(ISO_SOV1, habitats) %>% 
  summarise_at(c("total_area", "allmpa", "managed", "notake"), sum, na.rm = TRUE) %>% 
  merge(., GDP, by = "ISO_SOV1", all.x = TRUE) %>% 
  filter(total_area > 0) %>% # Filtering ones with NO habitat
  ungroup() %>% 
  mutate( GDP_perc = round((GDP_last/sum(GDP_last, na.rm = T)*100), 6)) %>% 
  group_by(ISO_SOV1, habitats) %>%  #creating world stat
  mutate(mpa_perc = (allmpa/sum(total_area))*100) %>%
  group_by(habitats) %>% 
  mutate(mean_effort = mean(mpa_perc),
         median_effort = median(mpa_perc),
         effort_gap_habitat = mean_effort - median_effort) %>%
  group_by(ISO_SOV1, habitats) %>% 
  mutate(effort_gap_country = mean_effort-mpa_perc) %>% 
  select(ISO_SOV1, habitats, GDP_perc, mpa_perc, mean_effort, median_effort, effort_gap_habitat, effort_gap_country) %>% 
  write.csv(., 'effort_gap.csv', row.names = F)


# Experimentation ---------------------------------------------------------

perc %>% 
  separate(habitats, c("habitats", "protection")) %>% 
  mutate(protection = replace_na(protection, replace = "total_area")) %>% 
  pivot_wider(UNION:habitats, names_from = "protection", values_from = "pixel_counts") %>% 
  group_by(ISO_SOV1, habitats) %>% 
  summarise_at(c("total_area", "allmpa", "managed", "notake"), sum, na.rm = TRUE) %>% 
  merge(., GDP, by = "ISO_SOV1", all.x = TRUE) %>% 
  filter(total_area > 0) %>% # Filtering ones with NO habitat
  ungroup() %>% 
  mutate( GDP_perc = round((GDP_last/sum(GDP_last, na.rm = T)*100), 6)) %>% 
  group_by(ISO_SOV1, habitats) %>%  #creating world stat
  mutate(mpa_perc = (allmpa/sum(total_area))*100) %>%
  group_by(habitats) %>% 
  mutate(mean_effort = mean(mpa_perc),
         median_effort = median(mpa_perc),
         effort_gap_habitat = mean_effort - median_effort) %>%
  group_by(ISO_SOV1, habitats) %>% 
  mutate(effort_gap_country = mean_effort-mpa_perc) %>% 
  select(ISO_SOV1, habitats, GDP_perc, mpa_perc, mean_effort, median_effort, effort_gap_habitat, effort_gap_country) %>% 
  mutate(increase = mpa_perc + effort_gap_country) %>% 
  ggplot(aes(x=habitats, y = increase, label = ISO_SOV1))+
  geom_point(aes(x=habitats, y = increase, size = GDP_perc), col = "gray80")+
  geom_point()+
  #geom_point(col = "gray50")+
  #geom_point(aes(x=habitats, y=mean_effort), col = "blue", size = 2)+
  #geom_point(aes(x=habitats, y=median_effort), col = "red", size = 2)+
  geom_hline(yintercept = 30)+
  coord_flip()+
  theme_bw()

perc %>% 
  separate(habitats, c("habitats", "protection")) %>% 
  mutate(protection = replace_na(protection, replace = "total_area")) %>% 
  pivot_wider(UNION:habitats, names_from = "protection", values_from = "pixel_counts") %>% 
  group_by(ISO_SOV1, habitats) %>% 
  summarise_at(c("total_area", "allmpa", "managed", "notake"), sum, na.rm = TRUE) %>% 
  merge(., GDP, by = "ISO_SOV1", all.x = TRUE) %>% 
  filter(total_area > 0) %>% # Filtering ones with NO habitat
  ungroup() %>% 
  mutate( GDP_perc = round((GDP_last/sum(GDP_last, na.rm = T)*100), 6)) %>% 
  group_by(habitats) %>%  #creating world stat
  mutate(world_habitat_percent = (total_area/sum(total_area))*100,
         mpa_rel_to_world = (allmpa/sum(total_area))*100) %>% 
  group_by(ISO_SOV1, habitats) %>% 
  mutate(mpa_perc = (allmpa/total_area)*100,
         managed_perc = (managed/total_area)*100,
         notake_perc = (notake/total_area)*100) %>% 
  mutate(importance_index = world_habitat_percent/mpa_perc) %>% 
  ggplot(aes(x = log1p(GDP_last), y = log1p(mpa_perc), label = ISO_SOV1, fill = ISO_SOV1)) +
  #geom_point() +
  geom_text(size = 1.5)+
  theme(legend.position = "") +
  #geom_hline(yintercept = 30) + 
  facet_wrap(~habitats) +
  NULL

perc %>% 
    separate(habitats, c("habitats", "protection")) %>% 
    mutate(protection = replace_na(protection, replace = "total_area")) %>% 
    pivot_wider(UNION:habitats, names_from = "protection", values_from = "pixel_counts") %>% 
    group_by(ISO_SOV1, habitats) %>% 
    summarise_at(c("total_area", "allmpa", "managed", "notake"), sum, na.rm = TRUE) %>% 
    merge(., GDP, by = "ISO_SOV1", all.x = TRUE) %>% 
    filter(total_area > 0) %>% # Filtering ones with NO habitat
    ungroup() %>% 
    mutate( GDP_perc = round((GDP_last/sum(GDP_last, na.rm = T)*100), 6)) %>% 
    group_by(habitats) %>%  #creating world stat
    mutate(world_habitat_percent = (total_area/sum(total_area))*100,
           mpa_rel_to_world = (allmpa/sum(total_area))*100) %>% 
    group_by(ISO_SOV1, habitats) %>% 
    mutate(mpa_perc = (allmpa/total_area)*100,
           managed_perc = (managed/total_area)*100,
           notake_perc = (notake/total_area)*100) %>% 
    mutate(importance_index = world_habitat_percent/mpa_perc) %>% 
    ggplot(aes(x = habitats, y = mpa_rel_to_world, fill = ISO_SOV1)) +
    geom_col() +
    theme(legend.position = "")



# END OF SCRIPT -----------------------------------------------------------


