subdir = SIPP

objdirs = build stats

sources = aggregate2annual.do \
	clean_monthly.do \
	combine_waves.do \
	stats_stata_alt.do
	# stats_excel.do

targets = stats/output/SIPP3d_person.dta \
	stats/output/SIPP3d_fam.dta \
	stats/output/SIPP3d_hh.dta \
	stats/output/SIPP5d_person.dta \
	stats/output/SIPP5d_fam.dta \
	stats/output/SIPP5d_hh.dta \

empty_targets =

include misc/includes.make