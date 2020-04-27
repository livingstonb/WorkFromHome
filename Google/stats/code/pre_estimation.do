
foreach var of varlist retail_and_recreation workplaces {
	* Initial values (baseline)
	if "`var'" == "retail_and_recreation" {
		local tb1 = date("02/29/2020", "MDY")
		local tb2 = date("03/07/2020", "MDY")
		local name retail
	}
	else if "`var'" == "workplaces" {
		local tb1 = date("02/22/2020", "MDY")
		local tb2 = date("03/07/2020", "MDY")
		local name work
	}

	gen baseline_period = inrange(date, `tb1', `tb2') & !weekend
	bysort state: egen tmp_baseline_mobility = mean(`var') if baseline_period
	by state: egen baseline_mobility = max(tmp_baseline_mobility)

	* Terminal values (after stay-at-home)
	gen terminal_date = stay_at_home + 1
	gen terminal_period = (date >= terminal_date) & !weekend & !missing(stay_at_home)
	bysort state: egen tmp_terminal_mobility = mean(`var') if terminal_period
// 	by state: egen terminal_mobility = max(tmp_terminal_mobility)
	gen terminal_mobility = `var' if (date == terminal_date)

	* Dependent variable
	gen mobility_`name' = `var' if inrange(date, `tb2', terminal_date)
	replace mobility_`name' = baseline_mobility if (date == `tb2')
	replace mobility_`name' = terminal_mobility if (date == terminal_date)
	replace mobility_`name' = mobility_`name' - baseline_mobility
	replace mobility_`name' = . if missing(stay_at_home)
	gen total_change_`name' = terminal_mobility - baseline_mobility
	
	label variable mobility_`name' "Mobility`variable'"
	rename `var' raw_`name'
	
	* Time variable
	bysort state: egen days_`name' = count(mobility_`name')

	* Cleanup
	drop *baseline* *terminal*
}

* Labels
label variable mobility_retail "Mobility, retail and rec"
label variable mobility_work "Mobility, workplaces"

* Date dummies
gen d_sunday = (day_of_week == 0)
gen d_monday = (day_of_week == 1)
gen d_saturday = (day_of_week == 6)

label variable d_sunday "Sunday"
label variable d_monday "Monday"
label variable d_saturday "Saturday"

* Intervention dummies
gen d_stay_at_home = (date == stay_at_home)
gen d_school_closure = (date == school_closure)
gen d_dine_in_ban = (date == dine_in_ban)
gen d_business_closure = (date == business_closure)

* Encode state
encode state, gen(stateid)
rename state statename

label variable d_stay_at_home "Stay-at-home order"
label variable d_school_closure "School closure"
label variable d_dine_in_ban "Restaurant dine-in ban"
label variable d_business_closure "Non-essential business closure"
