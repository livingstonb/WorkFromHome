/******************************************************************************/
*FINAL CODE FOR 5-DIGIT SOC
/******************************************************************************/
clear all
set more off
gl MainDir = "build/input"
gl OutDir = "build/output"

* Option to format wide
local format_wide = 1

/******************************************************************************/
*READ DATASET
/******************************************************************************/
use 	$OutDir/merged_cps, clear
save    $OutDir/cps_output_temp, replace

/******************************************************************************/
*RENAME VARIABLES
/******************************************************************************/
/*
Legend for sector:
s0  C sector
s1  S sector
s2  Aggregate
*/

rename soc3d2010 		 occ
rename soc2d2010 		 occ2

rename *_s0 	 *_C 
rename *_s1 	 *_S
rename employed empshare

/******************************************************************************/
*DROP SOME OBSERVATIONS WITH MISSING OES VALUES
/******************************************************************************/

drop if (employment_C == . & employment_S == .)
replace employment_C = 0 if employment_C == .
replace employment_S = 0 if employment_S == .
  
save $OutDir/cps_output_temp, replace

/******************************************************************************/
* EARNINGS
/******************************************************************************/

* usual hourly wage for those employed in an occupation 
gen usual_hourlywage  = earnweek/uhrsworkt
* weekly earnings for an occupation including zeros for nonemployed
gen weeklyearn        = (usual_hourlywage*ahrsworkt)*empshare + 0*(1-empshare)


* Define employment variable to aggregate
gen employment       = employment_C + employment_S
correl employment wgt*
*replace employment = wgt_ahrsworkt
* replace employment = wgt_employed
replace employment = wgt_earnweek

* Labor share
gen  wagebill_C      = employment_C*meanwage_C
egen totwagebill_C   = sum(wagebill_C) 
gen labshare_C       = wagebill_C/totwagebill_C 

gen  wagebill_S      = employment_S*meanwage_S
egen totwagebill_S   = sum(wagebill_S) 
gen labshare_S       = wagebill_S/totwagebill_S

*Average hourly wage 
sort year month
by year month: egen temp_Ausual_hourlywagebill = sum(usual_hourlywage * employment)
by year month: egen Aemployment = sum(employment)
gen Ausual_hourlywage = temp_Ausual_hourlywagebill / Aemployment

* Total hours
by year month: egen Atothours = sum(ahrsworkt * employment)
by year month: egen Aremotehours = sum(remote_ahrsworkt * employment)
by year month: egen Aonsitehours = sum(onsite_ahrsworkt * employment)

save $OutDir/cps_output_temp, replace


/******************************************************************************/
*ESSENTIAL OCCUPATIONS AS ONLY THE RIGID ONES - DINGEL-NEIMAN
/******************************************************************************/

/* Total wage bill, employment and wage*/
gen Eweight = essential*(1-teleworkable)

sort year month
by year month: egen Ewagebill = sum(weeklyearn * Eweight * employment)
by year month: egen Etotempl = sum(Eweight * employment)
gen Eweeklywage = Ewagebill / Etotempl

by year month: egen Etothours = sum(Eweight * ahrsworkt * employment)
by year month: egen Eremotehours = sum(Eweight * remote_ahrsworkt * employment)
by year month: egen Eonsitehours = sum(Eweight * onsite_ahrsworkt * employment)

save $OutDir/cps_output_temp, replace

/******************************************************************************/
*C INTENSIVE AND S INTENSIVE OCCUPATIONS
/******************************************************************************/

/* Determine sector intensity */
gen ratio_labshare  = labshare_C/labshare_S
gen C_intensive     = 0
gen ratio_labshare_thresh = 1.0
replace C_intensive  = 1 if ratio_labshare > ratio_labshare_thresh

gen S_intensive = (C_intensive == 0)


/******************************************************************************/
*NON ESSENTIAL OCCUPATIONS DINGEL-NEIMAN
/******************************************************************************/
/* Weights */
gen Fweight = (1-essential)*teleworkable + essential*teleworkable
gen Rweight = (1-essential)*(1-teleworkable)

sort year month

/* Total wage bill, employment, wage, hours */	
by year month: egen CIFwagebill = sum(weeklyearn*Fweight*employment*C_intensive)
by year month: egen CIFtotempl = sum(Fweight*employment*C_intensive)
by year month: egen CIFtothours = sum(Fweight*ahrsworkt*employment*C_intensive)
by year month: egen CIFremotehours = sum(Fweight*remote_ahrsworkt*employment*C_intensive)
by year month: egen CIFonsitehours = sum(Fweight*onsite_ahrsworkt*employment*C_intensive)
gen CIFweeklywage = CIFwagebill / CIFtotempl

by year month: egen CIRwagebill = sum(weeklyearn*Rweight*employment*C_intensive)
by year month: egen CIRtotempl = sum(Rweight*employment*C_intensive)
by year month: egen CIRtothours = sum(Rweight*ahrsworkt*employment*C_intensive)
by year month: egen CIRremotehours = sum(Rweight*remote_ahrsworkt*employment*C_intensive)
by year month: egen CIRonsitehours = sum(Rweight*onsite_ahrsworkt*employment*C_intensive)
gen CIRweeklywage = CIRwagebill / CIRtotempl

by year month: egen SIFwagebill = sum(weeklyearn*Fweight*employment*S_intensive)
by year month: egen SIFtotempl = sum(Fweight*employment*S_intensive)
by year month: egen SIFtothours = sum(Fweight*ahrsworkt*employment*S_intensive)
by year month: egen SIFremotehours = sum(Fweight*remote_ahrsworkt*employment*S_intensive)
by year month: egen SIFonsitehours = sum(Fweight*onsite_ahrsworkt*employment*S_intensive)
gen SIFweeklywage = SIFwagebill / SIFtotempl

by year month: egen SIRwagebill = sum(weeklyearn*Rweight*employment*S_intensive)
by year month: egen SIRtotempl = sum(Rweight*employment*S_intensive)
by year month: egen SIRtothours = sum(Rweight*ahrsworkt*employment*S_intensive)
by year month: egen SIRremotehours = sum(Rweight*remote_ahrsworkt*employment*S_intensive)
by year month: egen SIRonsitehours = sum(Rweight*onsite_ahrsworkt*employment*S_intensive)
gen SIRweeklywage = SIRwagebill / SIRtotempl

save $OutDir/cps_output_temp, replace

/******************************************************************************/
*REDUCE
/******************************************************************************/
duplicates drop year month, force

keep year month Ausual_hourlywage *hours *weeklywage Ewagebill CIFwagebill CIRwagebill SIFwagebill SIRwagebill

if "`format_wide'" == "1" {
	gen dtag = 100 * month + year - 2000
	tostring dtag, replace
	replace dtag = "_0" + dtag
	drop year month
	
	gen ii = 1
	reshape wide A* E* CI* SI*, i(ii) j(dtag) string
	drop ii *_0418
}

drop *remotehours_*19
drop *remotehours_0220
drop *remotehours_0320
drop *remotehours_0420
drop *onsitehours_0220
drop *onsitehours_0320
drop *onsitehours_0420
drop *onsitehours_*19

save $OutDir/cps_output_summary, replace
