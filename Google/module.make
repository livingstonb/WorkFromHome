subdir = Google

objdirs = build stats

sources = clean_for_stata.do estimate.do

targets = build/output/state_time_series.mat

empty_targets = mobility_figures mobility_stats

include misc/includes.make

include Google/auxiliary.make