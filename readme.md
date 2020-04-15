# Work From Home by Occupation

## Repository structure
Each dataset is associated with its own directory.
Within each of these directories are subdirectories, typically
*build* and/or *stats*. Each of these subdirectories contains
a directory for the code and may or may not contain
directories for the input, output, logs, and intermediate files.

## Make

### Interdependencies
Since there are interdependencies between the datasets, I rely heavily on GNU make to manage the code. If you would like to run the Stata code without the use of make, you can account for these dependencies by looking in the *misc/procedures/* directory, which provides for each dataset a potential order in which the code can be run without missing any dependencies. The *all.txt* file contains a suggested order of commands if you would like to run code for all of the datasets.

### A note about how I use make
In most Stata do-files, I include commands which have no effect in Stata but can be parsed by python to keep track of dependencies and targets. The keywords *#PREREQ* and *#TARGET*,
when found in a given line, will tell python to look for a filename enclosed in double quotes on the same line. These filenames are then used to create a .mk file corresponding with the do-file which contains rules for make. I create these files dynamically and include them in the makefile.

## ACS

### Preparing the raw data
ACS data can be pulled from IPUMS. To view the variables needed from IPUMS,
see the variables listed under the `keep` command in *ACS/build/code/read_acs.do*.
The raw data is expected to be a single Stata file: *ACS/build/input/acs_raw.dta*.

## ATUS

### Preparing the raw data
ATUS data can be downloaded from BLS. You should be able to download all the files used
in *ATUS/build/code/read_atus.do* and place them directly in *ATUS/build/input*, after
changing the import lines in the downloaded do-files.

## industries

### Preparing the data
This module requires OES data, which can be downloaded from the BLS. I rename the cross-ownership employment-by-industry files as *nat#d####*, where the first
\# symbol is the digit at which industries are aggregated and the four symbols
at the end represent year.

### Crosswalks
