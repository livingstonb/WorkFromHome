subdir = merges

objdirs = build

sources = merge_wfh.do make_wide.do n_observations.do

targets = build/output/wfh_merged_wide.dta \
	build/output/n_observations.dta

empty_targets =

include misc/includes.make
