
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

insheet using "asthma_all.csv", comma clear
*insheet using "asthma_all2.csv", comma clear

*insheet using "asthma_all3.csv", comma clear


*dummy coding for categorical variables
* for age group
gen agecat=.
replace agecat=2 if age=="Non Adult"
replace agecat=1 if age=="Mixed"

tabulate agecat, gen(agecat)


* for bacterial measure
gen bacteriacat=.
replace bacteriacat=2 if bacterialmeasure=="Endotoxin"
replace bacteriacat=1 if bacterialmeasure=="CAMNEA"
replace bacteriacat=3 if bacterialmeasure=="Muramic"

tabulate bacteriacat, gen(bacteriacat)


* for builing types 
gen bldtypecat=.
replace bldtypecat=2 if bld_type=="R"
replace bldtypecat=3 if bld_type=="B"
replace bldtypecat=1 if bld_type=="E"

tabulate bldtypecat, gen(bldtypecat)


* for collection methods 
gen collectcat=.
replace collectcat=2 if collectionmethod=="S"
replace collectcat=1 if collectionmethod=="A"
replace collectcat=3 if collectionmethod=="A, S"

tab collectcat, gen(collectcat)


* for Diagnosis methods 
gen diagcat=.
replace diagcat=1 if diagnosis=="S"
replace diagcat=2 if diagnosis=="P, S"
tab diagcat, gen(diagcat)


* for study designs  
gen studydescat=.
replace studydescat=1 if studydesign=="Cross-Sectional"
replace studydescat=2 if studydesign=="Case-Control"
replace studydescat=3 if studydesign=="Cohort"  //reference category // 
tab studydescat, gen(studydescat)


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



save "asthma_all_m.dta", replace // Asthma dataset including dummy variables and the computed variables // 


admetan lnor lnll lnul, study(investigation) eform(OR) /// Pooled OR-fixed=1.015

// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,

admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 1.25 1.5, force) xtick(0.25 0.5 1 1.25 1.5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 

graph save   "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m.png",  width(800) height(600) replace


metafunnel lnor selnor, eform xline(1.015) // xline at pooled OR_fixed=1.015

// metafunnel centered at the mean OR of fixed model // 

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 


//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_plot_new_as_all.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_asthma_all_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_asthma_all_m.png",  width(800) height(600) replace


  
 // Beggs and Egger's tests 
metabias lnor selnor
 
 
 
 ********Heterogenity assesment *************************
 ********Meta-regression and subgroup analysis **********
 
* Since we do not have enough observation, results of multiple meta-regression could be spurious
* Univariable meta-regression analysis, 
* knapphartung modification: knapphartungoption 



metareg lnor agecat2 , wsse(selnor)   knapphartung                       //ref group: mixed//
metareg lnor bacteriacat2 bacteriacat3, wsse(selnor)  knapphartung      //ref group: CAMNEA//
metareg lnor bldtypecat2 bldtypecat3, wsse(selnor) knapphartung         //ref group: E blgs//
metareg lnor collectcat2 collectcat3, wsse(selnor)  knapphartung       //ref group: A     //
metareg lnor diagcat2, wsse(selnor)    knapphartung                 //ref group: S     //

metareg lnor studydescat2 studydescat3, wsse(selnor)knapphartung    //ref group: Cross-Sectional study design


//clustering based on study design

admetan lnor lnll lnul, study(investigation) eform(OR)by(studydesign)   re(reml, hksj) nowarning  forestplot(favours(Protective effect #Harmuful effect) astext(60)  plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))

*****************************IMPORTANT**************************************
* When two articles are there 95% CI of the pooled OR is incorrect      
* So, we include only cross-sectional designs for the subgroup analysis  
****************************************************************************
use "asthma_all_m.dta",clear 
keep if studydesign=="Cross-Sectional" 
save "asthma_all_m_cs.dta", replace
use "asthma_all_m_cs.dta",clear 

admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.35 0.5 1 1.25 1.5, force) xtick(0.35 0.5 1 1.25 1.5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


  
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m_cs.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m_cs.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m_cs.png",  width(800) height(600) replace



// metafunnel centered at the mean OR of fixed model // 

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 


//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_asthma_all_m_cs.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_asthma_all_m_cs.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_asthma_all_m_cs.png",  width(800) height(600) replace


 
 // Beggs and Egger's tests 
metabias lnor selnor
 
    /* Sensitivity Analysis */ 
	
	* Finding outlier investigations
	
	sum(or), detail
	graph box or
	
	***IMPORTANT: no outlier among OR's 
	
	****IMPORTABT: outlier among SE(LN(OR))'s
	sum(selnor), detail
	graph box selnor
	
		*** no outlier among SE(LN(OR))'s 

	  *drop if _n==11 // Droping one the Smedge 2000

	*graph box or, alsize(5) capsize (0)
	 *cwhiskers, lines(line_options), alsize(#), and capsize(#) specify the look of the whiskers.
	 *are alsize(67) and capsize(0).
	/*  
	 *pctile q1 = or, nq(10)
    *List the resulting data
      . list pct in 1/10
    Setup
        . drop pct
    Create variable pct containing the deciles of mpg, and create variable percent containing the percentages
        . pctile pct = mpg, nq(10) genp(percent)
 pctile or=q,  p(25, 75), replace 
	 */

	
	/*
	
// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,

admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 1.25 1.5, force) xtick(0.25 0.5 1 1.25 1.5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_asthma_all_m_sa.png",  width(800) height(600) replace

// metafunnel centered at the mean OR of fixed model // 

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_asthma_all_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_asthma_all_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_asthma_all_m_sa.png",  width(800) height(600) replace

*/ 
	
 	
  
  
  
  
  
  
