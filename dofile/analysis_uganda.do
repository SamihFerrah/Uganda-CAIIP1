*********************************************
*** UGANDA ANALYSIS FOR WRITTING SAMPLES ****
*********************************************


clear
set more off 

global raw "/Users/Samih/Desktop/Work/Uganda/raw"
global temp "/Users/Samih/Desktop/Work/Uganda/temp"
global clean "/Users/Samih/Desktop/Work/Uganda/clean"
global output "/Users/Samih/Desktop/Work/Uganda/output"


u "$clean/cleandata_merge(notime).dta", clear 

********************************************************************************
/* 	  BALANCE TEST BETWEEN REGION FOR EACH YEAR ON THE BASIC COVARIATES       */
********************************************************************************

drop if region == 0 // Need to investigate this 

tab region year // High number of central HH in 2013
keep if age !=.

	// District concerned by the reform // 


g tmt =  1 if region == 1 | region == 2 
replace tmt = 0 if tmt  ==. 


		// Need to make the tmt more precise using the district concerned 
		

local covariates  "age sex edu_father edu_mother educ_level med_dist urban" 

foreach var of local covariates { 

eststo Balance`var' : reg `var' tmt,  vce(robust) 

}
