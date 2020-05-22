# Notes about the repository

## Structure

Each dataset, e.g. ACS, is associated with its own module.
Within each of these modules are directories, typically
*build* and/or *stats*, each of which contain code and/or other files related to the module. Each of these directories contains
a subdirectory for the code and may or may not contain
directories for the input, output, logs, and intermediate files.

## The current working directory

Code in each module expects the current working directory to be the module directory. E.g. to run code in the ACS module, first cd into *WorkFromHome/ACS*.

## Running code for an individual module
Most modules have a do file with *main* in the filename, located in the main module directory, e.g. *WorkFromHome/ACS/main_acs.do*. For the most part, these scripts accept one or more arguments corresponding with different parts of the  module. The ACS main do-file, for example, can be passed arguments *build* or *stats* (or both) which will execute the code in the *build* directory and/or the *stats* directory independently. When no arguments are passed to these scripts, they execute as if all applicable arguments are passed. The main do-files can be used to run all the code or simply to ascertain the desired run order of the different scripts in subdirectories.

## Running all of the code
The *master.do* script in the main directory allows the user to run code for all of the modules sequentially, with the exceptions of the OpenTable and Google modules. Some of the modules depend on output from previous modules so the run order is sometimes important. The main scripts in the occupations and industries modules, for example, create crosswalks used by most of the other modules.

# Modules

## ACS

### Required inputs

The raw ACS dataset, downloaded from IPUMS. To view the variables needed from IPUMS, see the variables listed under the `keep` command in *ACS/build/code/read_acs.do*.

* *build/input/acs_raw.dta*

## ATUS

### Required inputs

All ATUS data can be downloaded from the BLS website. Make sure to change the import lines in the downloaded do-files to point to the data file--use the relative filepath starting with *build/input/*.

* *build/input/atuscps_2017.dat*
* *build/input/atuscps_2017.do*
* *build/input/atuscps_2018.dat*
* *build/input/atuscps_2018.do*
* *build/input/atusresp_2017.dat*
* *build/input/atusresp_2017.do*
* *build/input/atusresp_2018.dat*
* *build/input/atusresp_2018.do*
* *build/input/atusrost_2017.dat*
* *build/input/atusrost_2017.do*
* *build/input/atusrost_2018.dat*
* *build/input/atusrost_2018.do*
* *build/input/atussum_2017.dat*
* *build/input/atussum_2017.do*
* *build/input/atussum_2018.dat*
* *build/input/atussum_2018.do*
* *build/input/lvresp_1718.dat*
* *build/input/lvresp_1718.do*

## OES

### Required inputs

To run *stats/code/stats2017.do*, only the following is necessary:

* *build/input/nat3d2017.xlsx*

Otherwise, various other years are required, which can be downloaded from the BLS. I rename the cross-ownership employment-by-industry files as *nat#d####*, followed by the original extension, where the first \# symbol is the digit at which industries are aggregated and the four symbols at the end represent the year.

* *build/input/nat2d1999.xls*
* *build/input/nat2d2000.xls*
* *build/input/nat2d2001.xls*
* *build/input/nat4d2002.xls*
* *build/input/nat3d2003.xls*
* *build/input/nat2d2004.xls*
* *build/input/nat2d2005.xls*
* *build/input/nat2d2006.xls*
* *build/input/nat2d2007.xls*
* *build/input/nat2d2008.xls*
* *build/input/nat2d2009.xls*
* *build/input/nat2d2010.xls*
* *build/input/nat2d2011.xls*
* *build/input/nat2d2012.xls*
* *build/input/nat2d2013.xls*
* *build/input/nat2d2014.xlsx*
* *build/input/nat2d2015.xlsx*
* *build/input/nat2d2016.xlsx*
* *build/input/nat2d2017.xlsx*
* *build/input/nat2d2018.xlsx*
* *build/input/nat2d2019.xlsx*

## SIPP

### Required inputs

We use waves 1-4 of the 2014 SIPP. These are large files named *pu2014w#.dta*, which can be split into chunks and compressed with the *build/code/read_sipp.do* do-file. This do-file should be passed the wave number of the raw dataset to be processed, e.g. `do "build/code/do/read_sipp.do" 2` for wave 2.

* *build/input/pu2014w1.dta*
* *build/input/pu2014w2.dta*
* *build/input/pu2014w3.dta*
* *build/input/pu2014w4.dta*

The raw datasets can then be deleted and one can use the following files, produced with the command described above:

* *build/input/sipp_raw_w1.dta*
* *build/input/sipp_raw_w2.dta*
* *build/input/sipp_raw_w3.dta*
* *build/input/sipp_raw_w4.dta*

## BEA

### Required inputs

Value added by industry and price indexes by industry downloaded from BEA.

* *build/input/price_indexes_1947_1997.xls*
* *build/input/price_indexes_1998_2019.xls*
* *build/input/value_added_1947_1997.xls*
* *build/input/value_added_1998_2019.xls*

## Dingel-Neiman

We use datasets provided by Jonathan Dingel and Brent Nieman to construct a teleworkable indicator by occupation and sector (<https://github.com/jdingel/DingelNeiman-workathome>).

### Required inputs

* *build/input/occupations_workathome.csv*

A dataset with an O\*NET teleworkable score for each occupation.

* *build/input/teleworkable_opinion_edited.csv*

A modified version of Dingel and Neiman's manual (opinion) teleworkable scores by occupation, where we recoded teleworkable to zero or one in the cases that it took the value of 0.5, using our own judgment. The original dataset from Dingel and Neiman was *Teleworkable_BNJDopinion.csv*.


## OpenTable

### Required inputs

We use a dataset provided by OpenTable, downloaded from <https://www.opentable.com/state-of-industry>.

* *build/input/state_of_industry.csv*

To rank cities by population, we use 2018 estimates produced by the Census, downloaded from
<https://www.census.gov/data/tables/time-series/demo/popest/2010s-total-cities-and-towns.html>.
Population ranks were then coded into *city_data.csv*, along with the approximate dates at which city or state dine-in bans went into effect.

* *build/input/city_data.csv*

## Google

### Required inputs

* *build/input/Global_Mobility_Report.csv*

Google mobility data, downloaded from <https://www.google.com/covid19/mobility/>.

* *build/input/covid_counties.csv*

County-level data on cases and deaths related to covid-19, from the New York Times. Downloaded from <https://github.com/nytimes/covid-19-data>.

* *build/input/county_populations.csv*

County population estimates for 2019, from the Census.


<!-- * *build/input/PctUrbanRural_County.xls* -->

<!-- A Census dataset providing land area by county. Downloaded from <https://www.census.gov/programs-surveys/geography/technical-documentation/records-layout/2010-urban-lists-record-layout.html> -->


## Occupation crosswalks

### Required inputs

We use various crosswalks, mostly provided by the BLS. Our occupation classification consists of three-digit 2010 SOC (aka major) categories. Most of our datasets use 2010 Census occupation codes, and for this we rely on a crosswalk provided by the BLS. One occupation code in the 2014 SIPP occupation variables doesn't line up with this crosswalk and is manually adjusted in the SIPP code we use.

* *build/input/yr2010_census_to_soc.csv*