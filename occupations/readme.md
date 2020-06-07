# Occupation crosswalks

## Required inputs

We use various crosswalks, mostly provided by the BLS. Our occupation classification consists of three-digit 2010 SOC (aka major) categories. Most of our datasets use 2010 Census occupation codes, and for this we rely on a crosswalk provided by the BLS. One occupation code in the 2014 SIPP occupation variables doesn't line up with this crosswalk and is manually adjusted in the SIPP code we use.

* *build/input/yr2010_census_to_soc.csv*