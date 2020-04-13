subdir = SIPP

objdirs = build stats

sources = clean_annual.do clean_monthly.do \
	combine_waves.do stats.do

targets = build/output/sipp_cleaned.dta \
	stats/output/SIPPwfh.dta

include misc/includes.make