subdir = industries

objdirs = build

sources = compute_essential_by_occupation.do \
	produce_essential_industry_list.do \
	crosswalk_census2012_to_sector.do

targets = essential_industries_table.dta \
	essential_share_by_occ.dta \
	cwalk_census2012_to_sector.dta
targets := $(addprefix build/output/, $(targets))

include misc/includes.make