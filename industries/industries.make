subdir = industries
objdirs = build
sources = essential_industries1.do \
	essential_industries2.do \
	industry_crosswalk1.do \
	industry_crosswalk2.do \
	industry_crosswalk3.do \
	industry_crosswalk4.do

targets = naicsindex2017.dta \
	industryindex2012.dta \
	industryindex2017.dta \
	industry2017crosswalk.dta \
	bea_value_added_sector.dta \
	essential_industries_cleaned.dta \
	essential_workers.dta
targets := $(addprefix build/output/, $(targets))

include misc/includes.make