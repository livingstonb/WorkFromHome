subdir = BEA

objdirs = build

sources = value_added_long.do \
	price_indexes_long.do \
	tornquist.do

targets = build/output/tornquist_series.dta

include misc/includes.make