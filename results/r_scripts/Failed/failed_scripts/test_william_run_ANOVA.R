

# get latest development version of the NeuroDecodeR
# devtools::install_github("emeyers/NeuroDecodeR")


# bin the data at 10 ms bins 10 ms intervals...


library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(NeuroDecodeR)


# Bin the data
#raster_dir_name <- "/home/em939/shared_projects/allen_data/R_EphysData/session_715093703/natural_scenes/"
#create_binned_data(raster_dir_name, "Allen_715093703", 10, 10)

# getting an error message when run with interval from -100 to 500  :(
#create_binned_data(raster_dir_name, "Allen_715093703", 10, 1, -100, 500)
#create_binned_data(raster_dir_name, "Allen_715093703", 10, 1, -50, 250)



source("/home/em939/research/Allen_ANOVA_analyses/run_ANOVA.R")


# binned_data_name <- "binned_data/Allen_715093703_10bins_10sampled.Rda"
#binned_data_name <- "binned_data/Allen_715093703_10bins_1sampled_start-100_end500.Rda"

binned_data_name <- "/home/em939/research/Allen_ANOVA_analyses/binned_data/Allen_715093703_10bins_1sampled_start-50_end250.Rda"


labels <- "natural_scene_stimulus_id"

tictoc::tic()
anova_results <- run_ANOVA(binned_data_name, labels)
tictoc::toc()

# save(anova_results, file = "anova_715093703_10bins_1sampled.Rda", compress = TRUE)


# should be able to speed up the ANOVA a lot by doing it in chunks
# it took 20 mins for the the 1 ms sample data (300 points) vs. 1 min for the
# 10 ms sampled data (100 points). The code is embarssingly parallel so there 
# shouldn't be much difference in time between these (i.e., should take the 
# 1 ms data 4 mins total, not 20 mins).




# plot the results...

significance_level <- .0001

anova_results |> 
  na.omit() |>   # hacky - should figure out why there are NAs but ok for quick and dirty
  mutate(stat_sig = p_val < significance_level) |> 
  group_by(time_period) |>
  summarize(percent_selective = 100 * mean(stat_sig)) |>
  mutate(Time  = NeuroDecodeR:::get_center_bin_time(time_period)) |>
  ggplot(aes(Time, percent_selective)) +
  geom_point() + 
  geom_line() + 
  ylab(paste("Percent of sites selective   (p < ", significance_level, ")")) +
  geom_hline(yintercept = 100 * significance_level, col = "red") +
  theme_bw()


# facet by brain area...
anova_results |> 
  na.omit() |>   # hacky - should figure out why there are NAs but ok for quick and dirty
  mutate(stat_sig = p_val < significance_level) |> 
  group_by(time_period, site_info.ephys_structure_acronym) |>
  summarize(percent_selective = 100 * mean(stat_sig), n = n()) |>
  mutate(Time  = NeuroDecodeR:::get_center_bin_time(time_period)) |>
  mutate(brain_region_name = paste0(site_info.ephys_structure_acronym, 
                                    " (", n ,")")) |>
  ggplot(aes(Time, percent_selective)) +
  geom_point() + 
  geom_line() + 
  ylab(paste("Percent of sites selective   (p < ", significance_level, ")")) +
  geom_hline(yintercept = 100 * significance_level, col = "red") +
  theme_bw() + 
  facet_wrap(~brain_region_name)



# overlapping colors by brain area
anova_results |> 
  na.omit() |>   # hacky - should figure out why there are NAs but ok for quick and dirty
  mutate(stat_sig = p_val < significance_level) |> 
  group_by(time_period, site_info.ephys_structure_acronym) |>
  summarize(percent_selective = 100 * mean(stat_sig), n = n()) |>
  mutate(Time  = NeuroDecodeR:::get_center_bin_time(time_period)) |>
  mutate(brain_region_name = paste0(site_info.ephys_structure_acronym, 
                                    " (", n ,")")) |>
  ggplot(aes(Time, percent_selective, col = brain_region_name)) +
  geom_point() + 
  geom_line() + 
  ylab(paste("Percent of sites selective   (p < ", significance_level, ")")) +
  geom_hline(yintercept = 100 * significance_level, col = "red") +
  theme_bw() 






