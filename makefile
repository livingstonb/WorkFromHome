

.PHONY: clean

# ACS
acs = ACS/build
$(acs)/temp/acs_temp.dta: $(acs)/acs_raw.dta $(acs)/read_acs.do
	stata -b do $(acs)/read_acs