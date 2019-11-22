clear
set more off 

global raw "/Users/Samih/Desktop/Work/Uganda/raw"
global temp "/Users/Samih/Desktop/Work/Uganda/temp"
global clean "/Users/Samih/Desktop/Work/Uganda/clean"
global output "/Users/Samih/Desktop/Work/Uganda/output"
	
*************
*************
*   2005    *
*************
*************

	
	********************
	* HH localisation  *
	********************
	
use "$raw/2005/GSEC1.dta", clear
keep HHID comm region urban h1bq2a h1bq2b h1bq2c
rename comm ea_code_2005 // compound code 
rename h1bq2a day_int 
rename h1bq2b month_int // Can be important on the timing of time spent on the fields 
rename h1bq2c year_int 
destring HHID ea_code_2005 , replace 
gen year = 1
tempfile loc_2005 
save `loc_2005'

	***********************************
	*   Demographic socio variables   *
	***********************************

// Assess the basic variables of each group for the head of household
// Size of HH, Distance from the nearest big city, Educ, Age, Mean of HH age


use "$raw/2005/GSEC2.dta", clear
keep HHID PID h2q4 h2q5 h2q9 h2q13
rename h2q4 sex
rename h2q5 hh_link
rename h2q9 age 
rename h2q13 mover
merge 1:1 HHID PID using "$raw/2005/GSEC3.dta"

	*************************
	* 		AGRICULTURE 	*
	*************************
	
u "$raw/2005/AGSEC2A.dta", clear   //Current Land holding 
rename a2aq2 a3id
merge 1:m HHID a3id using "$raw/2005/AGSEC3.dta", keep(3)  // Agricultural and labor inputs first crop season
drop if a3id ==. 
drop _merge
rename a3id a4aid
merge 1:m HHID a4aid using "$raw/2005/AGSEC4A.dta", keep(3) // Agricultural type of crop  
drop _merge 
rename a4aid a5aid
merge 1:m HHID a5aid using "$raw/2005/AGSEC5A.dta", keep(3) // Agricultural outputs 
rename a5aid parcelID
g season = 1 
tempfile seasonA 
sa `seasonA' 

u "$raw/2005/AGSEC2B.dta", clear   //Current Land holding 
rename a2bq2 a3q1
merge 1:m HHID a3q1 using "$raw/2005/AGSEC3.dta"  // Agricultural and labor inputs first crop season
drop if a3id ==. 
drop _merge
rename a3id a4bid
merge 1:m HHID a4bid using "$raw/2005/AGSEC4B.dta", keep(3) // Agricultural type of crop  
drop _merge 
rename a4bid a5bid
merge 1:m HHID a5bid using "$raw/2005/AGSEC5B.dta", keep(3) // Agricultural outputs 
rename a5bid parcelID
g season = 2 
rename a?bq* a?aq*
append using `seasonA'

rename * *_b 
rename HHID_b HHID 
rename parcelID_b parcelID 
rename a5bq3_b plotID


****************
*     2013     *
****************

		***************
		* LOCALISATON *
		***************
		
use "$raw/2013/GSEC1.dta", clear
keep HHID HHID_old region urban regurb h1aq1a h1aq3a h1aq3b h1aq4a h1aq4b day year month
rename h1aq4a parish_code
rename h1aq4b parish_name
rename h1aq1a district_code
rename h1aq3a subcountry_code
rename h1aq3b subcountry_name
rename day day_int
rename month month_int // Can be important on the timing of time sped on the fields 
rename year year_int 

destring HHID, replace ignore (H-) 
keep if HHID_old !=.

preserve 
	keep HHID HHID_old 
	tempfile HHID_new_old
	cap save "$temp/2O13/HHID_new_old.dta"
restore 
	
	
rename HHID HHID_new 
rename HHID_old HHID 
replace HHID = HHID_new if HHID ==.
destring HHID day_int, ignore(H-) replace

gen year = 2013
/* regurb --> regionXUrban */
tempfile loc_2013
save `loc_2013', replace


		***********************************
		*   Demographic socio variables   *
		***********************************

// Assess the basic variables of each group for the head of household
// Size of HH, Distance from the nearest big city, Educ, Age, Mean of HH age

use "$raw/2013/GSEC2.dta", clear
keep HHID PID h2q3 h2q4 h2q8 
rename h2q3 sex
rename h2q4 hh_link
rename h2q8 age 

preserve
	use "$raw/2013/GSEC3.dta", clear
	save "$temp/2013/GSEC3_nodup", replace 
restore 


merge 1:1 PID HHID using "$temp/2013/GSEC3_nodup.dta"

	// If _merge ==1 people not usual or regular from the household not interviewed //
		// 2,222 people not regular or usual // 
			/// _merge ==2 --> Duplicates drop previously //
   
drop if _merge ==2
rename _merge _mergeGSEC3
keep HHID PID h3q3 h3q4 h3q6 h3q7 sex hh_link age _mergeGSEC3
rename h3q3 edu_father 
rename h3q4 father_occup
rename h3q6 edu_mother 
rename h3q7 mother_occup

	
preserve
	use "$raw/2013/GSEC4.dta", clear
	save "$temp/2013/GSEC4_nodup", replace 
restore 

merge 1:1 HHID PID using "$temp/2013/GSEC4_nodup.dta"
	// Only people 5 years and above usual and regular // 
		// 4,967 children under 5 years or HH member not regular or usual //
		
drop if _merge ==2
rename _merge _mergeGSEC4

keep HHID PID h4q5 h4q6 h4q7 h4q8 h4q10 h4q13 h4q14 h4q15d sex hh_link age edu_father father_occup edu_mother mother_occup _mergeGSEC3 _mergeGSEC4
rename h4q5 educ_yes_no 
rename h4q6 educ_why_no 
rename h4q7 educ_level 
rename h4q8 educ_why_leave
rename h4q10 educ_current
rename h4q13 educ_distance
rename h4q14 educ_time
rename h4q15d educ_transport_cost 

label var educ_transport_cost "Cost to and from school 12 past year"

preserve
	use "$raw/2013/GSEC5.dta", clear
	destring HHID, ignore(H-) replace 
	save "$temp/2013/GSEC5_nodup", replace 
restore 

destring HHID, ignore(-H) replace

merge 1:1 PID HHID using "$temp/2013/GSEC5_nodup.dta"

	// Household level //
   
drop if _merge ==2
rename _merge _mergeGSEC5
rename h5q11 med_dist
rename h5q12 med_cost
rename h5q4 sick_yes_no
rename h5q9 no_consult_why 
rename h5q8 consult_yes_no
keep HHID PID educ_yes_no educ_why_no educ_level educ_why_leave educ_current /// 
educ_distance educ_time educ_transport_cost sex hh_link age edu_father father_occup ///
edu_mother mother_occup _mergeGSEC3 _mergeGSEC4 med_dist med_cost sick_yes_no ///
no_consult_why consult_yes_no _mergeGSEC5

preserve 
	 u "$raw/2013/GSEC8_1.dta", clear
	 destring HHID, ignore (H-) replace 
	 sa "$raw/2013/GSEC8_1_nodup.dta",replace
restore 

merge 1:1 HHID PID using "$raw/2013/GSEC8_1_nodup.dta"
   
drop if _merge ==2 
rename _merge merge_GSEC8_2013
rename h8q4 job_lw
label var job_lw "Did the respondent work for a salary last week ?" 
rename h8q5 job_lw_permanent 
label var job_lw_permanent "Did he practice this activity in the last 12 month"
rename h8q12 work_hh_farm_lw
rename h8q13 work_hh_farm_12 
rename h8q17 start_business_lm
label var start_business_lm "Did the respodent try to start a businness in the last month"
rename h8q19a job_lw_main_desc 
label var job_lw_main_desc " 
rename h8q19B job_lw_main_code


keep HHID PID educ_yes_no educ_why_no educ_level educ_why_leave ///
educ_current educ_distance educ_time educ_transport_cost sex hh_link age edu_father ///
father_occup edu_mother mother_occup _mergeGSEC3 _mergeGSEC4 med_dist med_cost sick_yes_no ///
 no_consult_why consult_yes_no _mergeGSEC5 merge_GSEC8_2013 job_lw job_lw_permanent ///
 work_hh_farm_lw work_hh_farm_12 start_business_lm job_lw_main_desc job_lw_main_code

rename * *_e 
rename HHID_e HHID 
rename PID_e PID 
gen year = 2013

save "$temp/2013/socio_basic_13.dta", replace 

		*********************
		* 	AGRICULTURE 	*
		*********************
		
u "$raw/2013/AGSEC2A.dta", clear   //Current Land holding 
merge 1:m HHID parcelID using "$raw/2013/AGSEC3A.dta", keep(3)  // Agricultural and labor inputs first crop season
drop if parcelID ==. 
drop _merge
merge 1:m HHID parcelID plotID using "$raw/2013/AGSEC4A.dta", keep(3) // Agricultural type of crop  
drop _merge 
merge 1:m HHID parcelID plotID cropID using "$raw/2013/AGSEC5A.dta", keep(3) // Agricultural outputs 
g season = 1 
tempfile seasonA 
sa `seasonA' 

u "$raw/2013/AGSEC2B.dta", clear   //Current land holding 
merge 1:m HHID parcelID using "$raw/2013/AGSEC3B.dta", keep(3)  // Agricultural and labor inputs first crop season
drop if parcelID ==. 
drop _merge
merge 1:m HHID parcelID plotID using "$raw/2013/AGSEC4B.dta", keep(3) // Agricultural type of crop  
drop _merge 
merge 1:m HHID parcelID plotID cropID using "$raw/2013/AGSEC5B.dta", keep(3) // Agricultural outputs 
g season = 2 
rename a?bq* a?aq*
append using `seasonA'

g year = 2013 

sa "$temp/panel/agri2013.dta", replace





	// 2005 

	



sa "$temp/panel/agri2005.dta", replace
destring HHID, replace force
append using "$temp/panel/agri2013.dta"
cap drop _merge 

sa "$temp/panel/agri.dta", replace 

merge m:1 HHID year using "$temp/panel/socio_loc_merge.dta"
cap drop _merge 
sa "$temp/panel/socio_loc_agri_merge.dta", replace 

********************************************************************************
************************* CONSUMPTION DATASET **********************************
********************************************************************************

		// 2013 
		
use "$raw/2013/GSEC15B.dta", clear

/* PLANTAINS + SWEET POTATOES + CASAVA + RICE + MAIZE FLOUR 
BEANS SORGHUM GROUNDUTS */

g staples = 0
replace staples = 1 if inlist(itmcd,101,105,107,110,122,116,144,140)

g mrkt_st = h15bq5 if staples == 1 
g own_st = h15bq9 if staples == 1 

g mrkt_ot = h15bq5 if staples == 0 
g own_ot = h15bq9 if staples == 0 

egen staples_spend = rowtotal(h15bq5 h15bq9) 
replace staples_spend = 0 if staples == 0 

egen ot_spend = rowtotal(h15bq5 h15bq9) 
replace ot_spend = 0 if staples == 1

collapse (sum) mrkt_* own* h15bq5 h15bq9 *_spend, by(HHID) 

rename (h15bq5 h15bq9) (mrkt own)

g year = 5 
sa "$temp/panel/consumption2013.dta", replace 


		// 2005 
		
use "$raw/2005/GSEC14A.dta", clear 

g staples = 0
replace staples = 1 if inlist(h14aq2,101,105,107,110,122,116,144,140)

g mrkt_st = h14aq5 if staples == 1 
g own_st = h14aq9 if staples == 1 

g mrkt_ot = h14aq5 if staples == 0 
g own_ot = h14aq9 if staples == 0 

egen staples_spend = rowtotal(h14aq5 h14aq9) 
replace staples_spend = 0 if staples == 0 

egen ot_spend = rowtotal(h14aq5 h14aq9) 
replace ot_spend = 0 if staples == 1


collapse (sum) mrkt_* own* h14aq5 h14aq9 *_spend, by(HHID) 

rename (h14aq5 h14aq9) (mrkt own)

g year = 1 
sa "$temp/panel/consumption2005.dta", replace 


append using "$temp/panel/consumption2013.dta"

gen food_budget = mrkt + own

g st_share_tot = staples_spend/food_budget
label var st_share_tot "Part of budget dedicated to staples"
g ot_share_tot = ot_spend/food_budget
label var ot_share_tot "Part of budget dedicated to others"

g st_share_own = own_st/food_budget
label var st_share_own "Part of staples consumption coming from home production"
g ot_share_own = own_ot/food_budget
label var ot_share_own "Part of others consumption coming from home production"

g st_share_mrkt = mrkt_st/food_budget
label var st_share_mrkt "Part of staples consumption coming from market"
g ot_share_mrkt = mrkt_ot/food_budget
label var ot_share_mrkt "Part of others consumption coming from market"

g own_share = own/food_budget 
label var own "Share of consumption coming from home production"
g mrkt_share = mrkt/food_budget
label var own "Share of consumption coming from market"

sa "$temp/panel/consumption.dta", replace 
destring HHID, ignore(H-) replace 
merge 1:m HHID year using "$temp/panel/socio_loc_agri_merge.dta", keep(3)


sa "$clean/cleandata_merge(notime).dta", replace

********************************************************************************
************************* TIME USED DATASET ************************************
********************************************************************************
/*
		// 2005 
/*		
u "$raw/2005/GSEC7.dta", clear 
keep HHID PID hh7q??a 
drop hh7q17 desc
collapse (sum) hh7*, by(HHID) 
g year = 1 
sa "$temp/time_used2005.dta", replace
*/
	// 2013



use "$raw/2013/GSEC8_1.dta", clear 
 keep HHID PID h8q59-h8q67
collapse (sum) h8*, by(HHID) 
g year = 5

rename (h8q59-h8q67) (time_woods time_water ///
time_construct time_repairs time_milling ///
time_crafts time_agri time_hunting ///
time_domestic) 

sa "$temp/time_used2013.dta", replace

*/


