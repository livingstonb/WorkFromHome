subdir = merges

objdirs = build

sources = merge_wfh_3d.do \
	make_wide_3d.do \
	merge_wfh_5d.do \
	append_sipp5d_all_samplingunits.do \
	n_observations_3d.do

targets = build/output/wfh_merged_wide.dta \
	build/output/merged5d_final.dta \
	build/output/n_observations.dta

empty_targets =

include misc/includes.make