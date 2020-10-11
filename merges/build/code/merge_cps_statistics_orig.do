/******************************************************************************/
*FINAL CODE FOR 5-DIGIT SOC
/******************************************************************************/
clear all
set more off
gl MainDir = "build/input"
gl OutDir = "build/output"

/******************************************************************************/
*READ DATASET
/******************************************************************************/
use 	$OutDir/merged_cps_6_19_20, clear
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
egen Ausual_hourlywagebill_0419 = sum(usual_hourlywage*employment)       if month == 4 & year == 2019
egen Aemployment_0419           = sum(employment)                        if month == 4 & year == 2019
gen Ausual_hourlywage_0419      = Ausual_hourlywagebill_0419/Aemployment_0419      if month == 4 & year == 2019
egen Ausual_hourlywagebill_0320 = sum(usual_hourlywage*employment)       if month == 3 & year == 2020
egen Aemployment_0320           = sum(employment)                        if month == 3 & year == 2020
gen Ausual_hourlywage_0320      = Ausual_hourlywagebill_0320/Aemployment_0320     if month == 3 & year == 2020
egen Ausual_hourlywagebill_0420 = sum(usual_hourlywage*employment)       if month == 4 & year == 2020
egen Aemployment_0420           = sum(employment)                        if month == 4 & year == 2020
gen Ausual_hourlywage_0420      = Ausual_hourlywagebill_0420/Aemployment_0420     if month == 4 & year == 2020
egen Ausual_hourlywagebill_0520 = sum(usual_hourlywage*employment)       if month == 5 & year == 2020
egen Aemployment_0520           = sum(employment)                        if month == 5 & year == 2020
gen Ausual_hourlywage_0520      = Ausual_hourlywagebill_0520/Aemployment_0520     if month == 5 & year == 2020

save $OutDir/cps_output_temp, replace


/******************************************************************************/
*ESSENTIAL OCCUPATIONS AS ONLY THE RIGID ONES - DINGEL-NEIMAN
/******************************************************************************/

/* Total wage bill, employment and wage*/
gen Eweight              = essential*(1-teleworkable)
egen Ewagebill_0419      = sum(weeklyearn*Eweight*employment) if month == 4 & year == 2019
egen Ewagebill_0320      = sum(weeklyearn*Eweight*employment) if month == 3 & year == 2020
egen Ewagebill_0420      = sum(weeklyearn*Eweight*employment) if month == 4 & year == 2020
egen Ewagebill_0520      = sum(weeklyearn*Eweight*employment) if month == 5 & year == 2020
egen Etotempl_0419       = sum(Eweight*employment) if month == 4 & year == 2019
egen Etotempl_0320       = sum(Eweight*employment) if month == 3 & year == 2020
egen Etotempl_0420       = sum(Eweight*employment) if month == 4 & year == 2020
egen Etotempl_0520       = sum(Eweight*employment) if month == 5 & year == 2020
gen Eweeklywage_0419     = Ewagebill_0419/Etotempl_0419
gen Eweeklywage_0320     = Ewagebill_0320/Etotempl_0320
gen Eweeklywage_0420     = Ewagebill_0420/Etotempl_0420
gen Eweeklywage_0520     = Ewagebill_0520/Etotempl_0520

save $OutDir/cps_output_temp, replace

/******************************************************************************/
*C INTENSIVE AND S INTENSIVE OCCUPATIONS
/******************************************************************************/

/* Determine sector intensity */
gen ratio_labshare  = labshare_C/labshare_S
gen C_intensive     = 0
gen ratio_labshare_thresh = 1.0
replace C_intensive  = 1 if ratio_labshare > ratio_labshare_thresh


/******************************************************************************/
*NON ESSENTIAL OCCUPATIONS DINGEL-NEIMAN
/******************************************************************************/
/* Weights */
gen Fweight = (1-essential)*teleworkable + essential*teleworkable
gen Rweight = (1-essential)*(1-teleworkable)

/* Total wage bill, employment and wage*/	
egen CIFwagebill_0419     = sum(weeklyearn*Fweight*employment) if C_intensive == 1 & month == 4 & year == 2019
egen CIFwagebill_0320     = sum(weeklyearn*Fweight*employment) if C_intensive == 1 & month == 3 & year == 2020
egen CIFwagebill_0420     = sum(weeklyearn*Fweight*employment) if C_intensive == 1 & month == 4 & year == 2020
egen CIFwagebill_0520     = sum(weeklyearn*Fweight*employment) if C_intensive == 1 & month == 5 & year == 2020
egen CIFtotempl_0419      = sum(Fweight*employment) 				if C_intensive == 1 & month == 4 & year == 2019
egen CIFtotempl_0320      = sum(Fweight*employment) 				if C_intensive == 1 & month == 3 & year == 2020
egen CIFtotempl_0420      = sum(Fweight*employment) 				if C_intensive == 1 & month == 4 & year == 2020
egen CIFtotempl_0520      = sum(Fweight*employment) 				if C_intensive == 1 & month == 5 & year == 2020
gen CIFweeklywage_0419    = CIFwagebill_0419/CIFtotempl_0419
gen CIFweeklywage_0320    = CIFwagebill_0320/CIFtotempl_0320
gen CIFweeklywage_0420    = CIFwagebill_0420/CIFtotempl_0420
gen CIFweeklywage_0520    = CIFwagebill_0520/CIFtotempl_0520

egen CIRwagebill_0419     = sum(weeklyearn*Rweight*employment) if C_intensive == 1 & month == 4 & year == 2019
egen CIRwagebill_0320     = sum(weeklyearn*Rweight*employment) if C_intensive == 1 & month == 3 & year == 2020
egen CIRwagebill_0420     = sum(weeklyearn*Rweight*employment) if C_intensive == 1 & month == 4 & year == 2020
egen CIRwagebill_0520     = sum(weeklyearn*Rweight*employment) if C_intensive == 1 & month == 5 & year == 2020
egen CIRtotempl_0419      = sum(Rweight*employment) if C_intensive == 1 & month == 4 & year == 2019
egen CIRtotempl_0320      = sum(Rweight*employment) if C_intensive == 1 & month == 3 & year == 2020
egen CIRtotempl_0420      = sum(Rweight*employment) if C_intensive == 1 & month == 4 & year == 2020
egen CIRtotempl_0520      = sum(Rweight*employment) if C_intensive == 1 & month == 5 & year == 2020
gen CIRweeklywage_0419    = CIRwagebill_0419/CIRtotempl_0419
gen CIRweeklywage_0320    = CIRwagebill_0320/CIRtotempl_0320
gen CIRweeklywage_0420    = CIRwagebill_0420/CIRtotempl_0420
gen CIRweeklywage_0520    = CIRwagebill_0520/CIRtotempl_0520

egen SIFwagebill_0419     = sum(weeklyearn*Fweight*employment) if C_intensive == 0 & month == 4 & year == 2019
egen SIFwagebill_0320     = sum(weeklyearn*Fweight*employment) if C_intensive == 0 & month == 3 & year == 2020
egen SIFwagebill_0420     = sum(weeklyearn*Fweight*employment) if C_intensive == 0 & month == 4 & year == 2020
egen SIFwagebill_0520     = sum(weeklyearn*Fweight*employment) if C_intensive == 0 & month == 5 & year == 2020
egen SIFtotempl_0419      = sum(Fweight*employment) if C_intensive == 0 & month == 4 & year == 2019
egen SIFtotempl_0320      = sum(Fweight*employment) if C_intensive == 0 & month == 3 & year == 2020
egen SIFtotempl_0420      = sum(Fweight*employment) if C_intensive == 0 & month == 4 & year == 2020
egen SIFtotempl_0520      = sum(Fweight*employment) if C_intensive == 0 & month == 5 & year == 2020
gen SIFweeklywage_0419    = SIFwagebill_0419/SIFtotempl_0419
gen SIFweeklywage_0320    = SIFwagebill_0320/SIFtotempl_0320
gen SIFweeklywage_0420    = SIFwagebill_0420/SIFtotempl_0420
gen SIFweeklywage_0520    = SIFwagebill_0520/SIFtotempl_0520

egen SIRwagebill_0419     = sum(weeklyearn*Rweight*employment) if C_intensive == 0 & month == 4 & year == 2019
egen SIRwagebill_0320     = sum(weeklyearn*Rweight*employment) if C_intensive == 0 & month == 3 & year == 2020
egen SIRwagebill_0420     = sum(weeklyearn*Rweight*employment) if C_intensive == 0 & month == 4 & year == 2020
egen SIRwagebill_0520     = sum(weeklyearn*Rweight*employment) if C_intensive == 0 & month == 5 & year == 2020
egen SIRtotempl_0419      = sum(Rweight*employment) if C_intensive == 0 & month == 4 & year == 2019
egen SIRtotempl_0320      = sum(Rweight*employment) if C_intensive == 0 & month == 3 & year == 2020
egen SIRtotempl_0420      = sum(Rweight*employment) if C_intensive == 0 & month == 4 & year == 2020
egen SIRtotempl_0520      = sum(Rweight*employment) if C_intensive == 0 & month == 5 & year == 2020
gen SIRweeklywage_0419    = SIRwagebill_0419/SIRtotempl_0419
gen SIRweeklywage_0320    = SIRwagebill_0320/SIRtotempl_0320
gen SIRweeklywage_0420    = SIRwagebill_0420/SIRtotempl_0420
gen SIRweeklywage_0520    = SIRwagebill_0520/SIRtotempl_0520


save $OutDir/cps_output_temp, replace

// preserve
/*Collect stats */
	collapse (mean) Ausual_hourlywage_0419 Ausual_hourlywage_0320 ///
	          Eweeklywage_0419 Eweeklywage_0320 Eweeklywage_0420 Eweeklywage_0520  ///
              CIFweeklywage_0419 CIFweeklywage_0320 CIFweeklywage_0420  CIFweeklywage_0520 ///
              CIRweeklywage_0419 CIRweeklywage_0320 CIRweeklywage_0420  CIRweeklywage_0520 ///
 			  SIFweeklywage_0419 SIFweeklywage_0320 SIFweeklywage_0420  SIFweeklywage_0520   ///
 			  SIRweeklywage_0419 SIRweeklywage_0320 SIRweeklywage_0420  SIRweeklywage_0520 ///
 			  Ewagebill_0419 Ewagebill_0320 Ewagebill_0420 Ewagebill_0520  ///
              CIFwagebill_0419 CIFwagebill_0320 CIFwagebill_0420  CIFwagebill_0520 ///
              CIRwagebill_0419 CIRwagebill_0320 CIRwagebill_0420  CIRwagebill_0520 ///
 			  SIFwagebill_0419 SIFwagebill_0320 SIFwagebill_0420  SIFwagebill_0520   ///
 			  SIRwagebill_0419 SIRwagebill_0320 SIRwagebill_0420  SIRwagebill_0520
 	save $OutDir/cps_output_summary_correct, replace
//  restore
