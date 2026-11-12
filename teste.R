


# Boxplot
obs_final %>%
  group_by(year = year(observation_date),
           month = month(observation_date,label=T)) %>%
  summarize(avg_count = median(observation_count,na.rm = T),.groups = 'drop') %>%
  filter(avg_count > 40)

# Grouping by date
obs_final %>%
  group_by(observation_date) %>% 
  summarize(avg_count = mean(observation_count,na.rm = T),.groups = 'drop') %>%
  filter(avg_count > 40)


  ggplot(aes(x=observation_date,y=avg_count))+geom_point()
