*******************************************
* Stata coding for my Meta-Analysis paper, Asthma
* Babak Khamsehi, Univ of Toronto, Jan 31, 2016
*******************************************
* Updated on Sep 7, 2016, BK 
* Updated on Aug 10, 2017, BK
* Updated on Aug 26, 2017, BK

drop _all
set more off

cd "${path2}/babak_new/Review Paper/do files/Meta_Regression" // Changing directory to where the data is // 
insheet using "sbs_all.csv", comma clear 


*dummy coding for categorical variables
* for age group
gen agecat=.
replace agecat=2 if age=="Non Adult"
replace agecat=1 if age=="Adult"
replace agecat=3 if age=="Mixed"
replace agecat = . if missing(age)

tabulate agecat, gen(agecat) m

* for bacterial measure
//no muracmic, no camnea, instead, culture

gen bacteriacat=.
replace bacteriacat=2 if bacterialmeasure=="Endotoxin"
replace bacteriacat=1 if bacterialmeasure=="Culture"

tabulate bacteriacat, gen(bacteriacat)

* for builing types 

gen bldtypecat=.
replace bldtypecat=2 if bld_type=="R"
replace bldtypecat=3 if bld_type=="B"
replace bldtypecat=1 if bld_type=="E"

tabulate bldtypecat, gen(bldtypecat)

* for collection methods 
gen collectcat=.
replace collectcat=2 if collectmethod=="S"
replace collectcat=1 if collectmethod=="A"
replace collectcat=3 if collectmethod=="A, S"

tab collectcat, gen(collectcat)

* for Diagnosis methods 
gen diagcat=.
replace diagcat=1 if diag=="S"
replace diagcat=2 if diag=="P, S"
tab diagcat, gen(diagcat)


* for study designs  
gen studydescat=.
replace studydescat=1 if studydesign=="Cross-Sectional"
replace studydescat=2 if studydesign=="Case-Control"
replace studydescat=3 if studydesign=="Cohort"  //reference category // 
tab studydescat, gen(studydescat)


* we are dropping these two classes because we do NOT have enough to conduct meta-analyses on them
drop if class=="musculoskeletal" 
drop if class=="respiratory" 
sort class, stable // sorting by class

//Keeping investigations that are the most away from the null (null is odds ratio=1)

drop if _n==9 // Drooping one the Menzies 2003
drop if _n==9 // Drooping one the Vincent 1997
drop if _n==13 // Drooping one the Gyntelberg 1994
drop if _n==15 // Drooping one the Sahlberg 2013
drop if _n==17 // Drooping one the Menzies 2003
drop if _n==19 // Drooping one the Vincent 1997


* Computing lnor lnll lnul selnor, required for admetan, and metafunnel 
gen lnor= ln(or)
gen lnll=ln(ll)
gen lnul=ln(ul)

gen selnor= (lnul-lnll)/(2*1.96) //95% CIs



* generating quality classes based on the quality scores 
gen      qclass =  "A"  if   qualityscore >= 80
replace  qclass =  "B"  if   qualityscore < 80

gen qclasscat=.
replace qclasscat=1 if qclass=="A"  // reference group: A publications
replace qclasscat=2 if qclass=="B"
tab qclasscat, gen(qclasscat)

* Percentiles of the quality scores
graph box qualityscore
sum qualityscore, detail


save "sbs_all_m.dta", replace // sbs dataset including dummy variables, and computed variable // 


admetan lnor lnll lnul, study(investigation) eform(OR) // fixed effect pooled OR= 0.979
// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman and clustered by class

admetan lnor lnll lnul, study(investigation) eform(OR) by(class) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 1 3 6, force) xtick(0.25 1 3 6) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))   re(reml, hksj) nowarning 
 
//saving the gph, and exporting eps, and png graphic outputs
graph save   "${path2}/babak_new/Review Paper/graphs/FP_sbs_all_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_sbs_all_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_sbs_all_m.png",  width(1200) height(600) replace

metafunnel lnor selnor, eform xline(0.979) //0.979= Pooled OR of fixed model // 


metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_sbs_all_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_sbs_all_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_sbs_all_m.png",  width(800) height(600) replace

    
// Beggs and Egger's tests 
  
metabias lnor selnor
  
 
// subsetting the datasets for the discussion // 
* sbs dermal dataset
use "sbs_all_m.dta",clear 
keep if class=="dermal"
save "sbs_all_m_dermal.dta", replace
use "sbs_all_m_dermal.dta"


*  forest plot for SBS dermal
admetan lnor lnll lnul, study(investigation) eform(OR) re(reml, hksj) nowarning  forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.6 1 2, force) xtick(0.6 1 2)   plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))

graph save   "${path2}/babak_new/Review Paper/graphs/FP_SBS_dermal_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_dermal_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_dermal_m.png",  width(800) height(600) replace

*  funnel plot for SBS dermal

metafunnel lnor selnor, eform xline(1.008) //1.008= Pooled OR of fixed model // 
metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

//saving the gph, and exporting eps, and png graphic outputs
graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_sbs_dermal_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_sbs_dermal_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_sbs_dermal_m.png",  width(800) height(600) replace


/* Sensitivity Analysis */ 

	* Finding outlier investigations
	sum(or), detail
	graph box or
drop if _n==4 // Droping  outlier publication of Teew 1994

	
// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,
admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 1.25 1.5, force) xtick(0.25 0.5 1 1.25 1.5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_SBS_dermal_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_asthma_dermal_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_asthma_dermal_m_sa.png",  width(800) height(600) replace

// metafunnel centered at the mean OR of fixed model // 

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_dermal_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_dermal_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_dermal_m_sa.png",  width(800) height(600) replace

	
drop if _n==4 // Droping  outlier publication of Fisk 1993

// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,
admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 1.25 1.5, force) xtick(0.25 0.5 1 1.25 1.5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_SBS_dermal_m_sa2.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_dermal_m_sa2.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_dermal_m_sa2.png",  width(800) height(600) replace


// metafunnel centered at the mean OR of fixed model // 

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_dermal_m_sa2.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_dermal_m_sa2.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_dermal_m_sa2.png",  width(800) height(600) replace
	
 	
  
use "sbs_all_m.dta", replace

// subsetting the  general SBS dataset from all SBS
keep if class=="general"
save "sbs_all_m_general.dta", replace
use "sbs_all_m_general.dta"

	admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 1 3 6, force) xtick(0.25 1 3 6) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))   re(reml, hksj) nowarning 


 ********Heterogenity assesment *************************
 ********Meta-regression and subgroup analysis **********
 
* Since we do not have enough observation, results of multiple meta-regression could be spurious

* Univariable meta-regression analysis, 
* knapphartung modification:  knapphartung  option 	
metareg lnor agecat2 agecat3 , wsse(selnor)   knapphartung                   //ref group: adult //
metareg lnor  bacteriacat1   , wsse(selnor) knapphartung                  //ref group: Endotoxin //
metareg lnor  bldtypecat2 bldtypecat3 , wsse(selnor)  knapphartung       //ref group: E blgs//
metareg lnor  collectcat2 collectcat3, wsse(selnor)  knapphartung       //ref group: A collection method//
metareg lnor  diagcat2, wsse(selnor) knapphartung                     //ref group: S diagnosis method//
metareg lnor  studydescat1 studydescat2,wsse(selnor) knapphartung     //ref group: cohort group     //
 metareg lnor qclasscat2 ,wsse(selnor) knapphartung                 // quality calss    //

 *** IMPORTANT: no significant predictor of het of OR 
* clustering SBS general based on bacterial measure

admetan lnor lnll lnul, study(investigation) eform(OR)by(bacterialmeasure)   re(reml, hksj) nowarning  forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.9 1 2, force) xtick(0.9 1 2)   plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))

//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_all_m_bact.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_all_m_bact.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_all_m_bact.png",  width(800) height(600) replace

* clustering SBS general based on collection method

admetan lnor lnll lnul, study(investigation) eform(OR)by(collectmethod)  re(reml, hksj) nowarning forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.8 1 2, force) xtick(0.8 1 2)   plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_all_m_collect.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_all_m_collect.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_all_m_collecct.png",  width(800) height(600) replace


// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,

admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.1 1 2 5, force) xtick(0.1 1 2 5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_SBS_general_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_general_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_general_m.png",  width(800) height(600) replace

// metafunnel centered at the mean OR of fixed model // 
admetan lnor lnll lnul, study(investigation) eform(OR) // OR=0.985
metafunnel lnor selnor, eform xline(0.985) // OR=0.976
metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_m_.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_m.png",  width(800) height(600) replace


/* Sensitivity Analysis */ 

	* Finding outlier investigations
	sum(or), detail
	graph box or 
	drop if _n==6 // Droping  outlier publication of Gyntelberg 1994

// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,
admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 2, force) xtick(0.25 0.5 1 2) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_SBS_general_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_general_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_general_m_sa.png",  width(800) height(600) replace

	
	
// metafunnel centered at the mean OR of fixed model // 
admetan lnor lnll lnul, study(investigation) eform(OR) // OR=0.982


metafunnel lnor selnor, eform xline(0.982) // OR=0.982 is the fixed  summary OR
metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 


//saving the gph, and exporting eps, and png graphic outputs
graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_general_m_sa.png",  width(800) height(600) replace


* outlier among SE(LN(OR))'s
	sum(selnor), detail
	 graph box selnor

	 *** Important: no outlier with respect to funnel plots 
	 
use "sbs_all_m.dta"


keep if class=="mucosal"
save "sbs_all_m_mucosal.dta", replace
use "sbs_all_m_mucosal.dta"


	
// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,

admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.1 0.2  1 2 5, force) xtick(0.1 0.2  1 2 5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 

graph save   "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m.png",  width(800) height(600) replace

// metafunnel centered at the mean OR of fixed model // 
admetan lnor lnll lnul, study(investigation) eform(OR) // OR=0.969
metafunnel lnor selnor, eform xline(0.969)
metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m_.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m.png",  width(800) height(600) replace



/* Sensitivity Analysis */ 

	* Finding outlier investigations
	sum(or), detail
	graph box or 
	
	
	drop if _n==7   // Droping  outlier publication of Teeuw 1994

	
// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,
admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 3 5, force) xtick(0.25 0.5 1 3 5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m_sa.png",  width(800) height(600) replace

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m_sa.png",  width(800) height(600) replace


drop if _n==8  // Droping  outlier publication of Fisk 1993
	
// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,
admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 3 5, force) xtick(0.25 0.5 1 3 5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m_sa2.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m_sa2.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_SBS_mucosal_m_sa2.png",  width(800) height(600) replace

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m_sa2.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m_sa2.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_SBS_mucosal_m_sa2.png",  width(800) height(600) replace



 ********Heterogenity assesment *************************
 ********Meta-regression and subgroup analysis **********
 
* Since we do not have enough observation, results of multiple meta-regression could be spurious

* Univariable meta-regression analysis, 
* knapphartung modification:  knapphartung  option 	
metareg lnor agecat2 agecat3 , wsse(selnor)   knapphartung                   //ref group: adult //
metareg lnor  bacteriacat1   , wsse(selnor) knapphartung                  //ref group: Endotoxin //
metareg lnor  bldtypecat2 bldtypecat3 , wsse(selnor)  knapphartung       //ref group: E blgs//
metareg lnor  collectcat2 collectcat3, wsse(selnor)  knapphartung       //ref group: A collection method//
metareg lnor  diagcat2, wsse(selnor) knapphartung                     //ref group: S diagnosis method//
metareg lnor  studydescat1 studydescat2,wsse(selnor) knapphartung     //ref group: cohort group     //
 metareg lnor qclasscat2 ,wsse(selnor) knapphartung                // quality calss    //

 *** IMPORTANT: no significant predictor of het of OR 

 
 





 
/* 

    /* IMPORTANT THIS NEEED ADJUSTMENT FOR SBSSensitivity Analysis */ 
	
  drop if _n==10 // Drooping one the Vedanthan 2006
    drop if _n==4 // Drooping one the Gehring 2006

      drop if _n==10 // Drooping one the Van Strien 2004

save "wheezing_all_m2.dta", replace // this is a good dataset // 



admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 1.25 1.5, force) xtick(0.25 0.5 1 1.25 1.5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 
graph export "${path2}/babak_new/Review Paper/graphs/FP_wheezing_all_m2.png",  width(800) height(600) replace



metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m2.png",  width(800) height(600) replace

*/  
