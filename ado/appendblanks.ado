/*
Appends categories from the using dataset to the current dataset, for categories
not found in the current dataset. For example, if the categories are occupations
and the occupation variable in the using dataset is occvar, then any entries in
occvar in the using dataset which do not show up at all in the current dataset
are appended as new rows, with all other variables taking missing values by default.

If the variable in the current dataset has a different name than in the using
dataset, the rename option should be passed the name of the variable in the current
dataset, which will rename the variable in the using dataset before anything else
is done.

The categories may be associated with subcategories, or groups, i.e. each occupation
may be associated with multiple sectors, and the user might require that each
occupation category in the using dataset shows up in the current dataset with
one row for each sector. If sector takes the values of 0 and 1, then the user
can use the over1 and values1 options as follows:

appendblanks occvar, over1(sector) values1(0 1)

A second subcategory variable can be used via the over2 and values2 options.
Options are also available to generate variables that take the values one or zero
for all of the new observations generated, for convenience. The desired variables
to be set to zero or one can be passed to the zeros or ones options, e.g.

appendblanks occvar, ones(indicator)

This program generates a new variable called blankobs. This variable takes the value
of 0 for all original observations and 1 for all added observations.
*/

program appendblanks
	#delimit ;
	syntax namelist using/
		, [ZEROS(string) ONES(string) OVER1(name) OVER2(name)
		VALUES1(string) VALUES2(string) RENAME(namelist)];
	#delimit cr

	preserve
	clear

	tempfile blanks
	save `blanks', emptyok

	* Create macros to loop over
	local loop1 = cond("`over1'" != "", "`values1'", "NONE")
	local loop2 = cond("`over2'" != "", "`values2'", "NONE")
	
	local main_variable `namelist'

	* Loop over all subcategories
	foreach val1 of local loop1 {
	foreach val2 of local loop2 {
		use `namelist' using "`using'", clear

		if "`rename'" != "" {
			* Rename the main category variable
			local i = 0
			foreach new_name of local rename {
				local ++i
				local varname: word `i' of `namelist'
				rename `varname' `new_name'
				
				* Use new name for main variable
				if (`i' == 1) {
					local main_variable `new_name'
				}
			}
		}

		* Set the subcategories to the desired values
		capture gen `over1' = `val1'
		capture gen `over2' = `val2'
		
		* Generate the desired zero or one variables
		foreach var of local zeros {
			gen `var' = 0
		}
		foreach var of local ones {
			gen `var' = 1
		}

		* Indicator for whether the row was originall present, or added
		gen blankobs = 1

		append using `blanks'
		save `blanks', replace
	}
	}
	
	restore

	gen blankobs = 0
	label define blankobs_lbl 0 "Not missing" 1 "Missing"
	label values blankobs blankobs_lbl
	label variable blankobs "Indicator for missing category"

	append using `blanks'
	
	* Drop any new observations for category-subcategory combinations that
	* were already present in the current dataset
	tempvar ismissing
	bysort `main_variable' `over1' `over2': egen `ismissing' = min(blankobs)
	drop if blankobs & !`ismissing'
end
