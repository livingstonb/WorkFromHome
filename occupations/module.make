subdir = occupations

objdirs = build

sources = census_to_soc2010.do \
	census_soc_labels.do \
	oes99_to_soc3d2010.do \
	soc98_to_soc3d2010.do \
	soc2000_to_soc3d2010.do \
	occ2010_to_soc3d2010.do \

targets = build/output/census2010_to_soc2010.dta \
	build/output/census2018_to_soc2010.dta

empty_targets =

include misc/includes.make