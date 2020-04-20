# Notes about the repository

## Structure
Each dataset, e.g. ACS, is associated with its own module.
Within each of these modules are directories, typically
*build* and/or *stats*, each of which contain code and/or other files related to the module. Each of these directories contains
a subdirectory for the code and may or may not contain
directories for the input, output, logs, and intermediate files.

## Make

### Interdependencies
Since there are interdependencies between the datasets, I rely heavily on GNU make to manage the code. If you would like to run the Stata code without the use of make, you can account for these dependencies by looking in the *misc/procedures/* directory, which provides for each dataset a potential order in which the code can be run without missing any dependencies. The *all.txt* file contains a suggested order of commands if you would like to run code for all of the datasets.

### A note about how I use make
In most Stata do-files, I include commands which have no effect in Stata but can be parsed by python to keep track of dependencies and targets. The keywords *#PREREQ* and *#TARGET*,
when found in a given line, will tell python to look for a filename enclosed in double quotes on the same line. These filenames are then used to create a .mk file corresponding with the do-file which contains rules for make. I create these files dynamically and include them in the makefile.

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

### Crosswalks
