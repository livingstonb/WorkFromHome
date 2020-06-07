# Notes about the repository

## Structure

Each dataset, e.g. ACS, is associated with its own module.
Within each of these modules are directories, typically
*build* and/or *stats*, each of which contain code and/or other files related to the module. Each of these directories contains
a subdirectory for the code and may or may not contain
directories for the input, output, logs, and intermediate files.
See module readmes for more details--though some of these may be incomplete.

## The current working directory

Code in each module expects the current working directory to be the module directory. E.g. to run code in the ACS module, first cd into *WorkFromHome/ACS*.

## Running code for an individual module
Most modules have a do file with *main* in the filename, located in the main module directory, e.g. *WorkFromHome/ACS/main_acs.do*. For the most part, these scripts accept one or more arguments corresponding with different parts of the  module. The ACS main do-file, for example, can be passed arguments *build* or *stats* (or both) which will execute the code in the *build* directory and/or the *stats* directory independently. When no arguments are passed to these scripts, they execute as if all applicable arguments are passed. The main do-files can be used to run all the code or simply to ascertain the desired run order of the different scripts in subdirectories.

## Running all of the code
The *master.do* script in the main directory allows the user to run code for all of the modules sequentially, with the exceptions of the OpenTable and Google modules. Some of the modules depend on output from previous modules so the run order is sometimes important. The main scripts in the occupations and industries modules, for example, create crosswalks used by most of the other modules.

# Modules

## ACS

Estimates WFH share in each occupation from the American Community Survey.

## ATUS

Estimates WFH share in each occupation from the American Time Use Survey.

## BEA

Computates Tornquist indexes from BEA data dating back to 1963.

## CPS

Produces employment statistics at the occupation-year-month level using the Current Population Survey.

## CriticalInfrastructure

Estimates share of critical workers in each occupation.

## DingelNeiman

Aggregates an occupation-level measure of teleworkable and estimates industry-level teleworkable shares, using data provided by Dingel and Neiman.

## Google

Estimates the relationship between active COVID-19 cases and mobility using county-level Google data.

## industries

Produces industry code crosswalks.

## merges

Merges various datasets.

## occupations

Produces occupation code crosswalks and labels.

## OES

Estimates occupation-level employment and wage statistics from BLS data.

## OpenTable

Produces plots of OpenTable reservations vs. date.

## SHED

Estimates various occupation-level statistics related to hand-to-mouth.

## SIPP

Estimates wealth statistics by occupation from the Survey of Income and Program Participation.