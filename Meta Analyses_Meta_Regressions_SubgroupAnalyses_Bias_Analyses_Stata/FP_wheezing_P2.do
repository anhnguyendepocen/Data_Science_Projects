
*******************************************
* Stata coding for my Meta-Analysis paper, wheezing
* Babak Khamsehi, Univ of Toronto, Jan 31, 2016
*******************************************
* Updated on Sep 7, 2016, BK 
* Updated on Aug 9, 2017, BK
* updated on Aug 22, 2017, BK
* Updated on Aug 26, 2017, BK

* To do list
  
  * 1) Important: Interpretation of Stata
  * 2) use recode for better dummy coding
  * 3) Convert the do file to ado file for future use
 
  
  
drop _all
set more off

cd "${path2}/babak_new/Review Paper/do files/Meta_Regression" // Changing directory to where the data is // 
 
insheet using "wheezing_all.csv", comma clear	

* dropping unnessary variables   
drop remarks


*dummy coding for categorical variables, potential effect modifiers
* for age group
gen agecat=.
replace agecat=2 if age=="Non adult"
replace agecat=1 if age=="Adult"
replace agecat=3 if age=="Mixed"

tabulate agecat, gen(agecat)

/* testing recode command
replace agecat=.
recode agecat 2 (age = Non adult)  ///
       agecat=1 (age =Adult)
	   agecat=3 (age =Mixed)

recode x (1 = 2), gen(nx)
recode agecat 0/119=0 120/max=1, generate highbp
*/

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
*replace collectcat=1 if collectionmethod=="A" //no A only //
replace collectcat=1 if collectionmethod=="A, S"

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


save "wheezing_all_m.dta", replace // wheezing dataset including dummy variables and the computed variables // 


admetan lnor lnll lnul, study(investigation) eform(OR) // fixed effect forest plot

// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,

admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 1.25 1.5, force) xtick(0.25 0.5 1 1.25 1.5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_wheezing_all_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_wheezing_all_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_wheezing_all_m.png",  width(800) height(600) replace

metafunnel lnor selnor, eform xline(0.974) //0.974= Pooled OR of fixed model // 


// metafunnel centered at the mean OR of fixed model // 

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m.png",  width(800) height(600) replace


// Beggs and Egger's tests 
  
metabias lnor selnor
  
  
 
 
* Since we do not have enough observation, results of multiple meta-regression could be spurious

* Univariable meta-regression analysis, 
* knapphartung modification: knapphartung option 
 metareg lnor agecat2 agecat3, wsse(selnor) knapphartung                //ref group: adult //
 metareg lnor bacteriacat2 bacteriacat3, wsse(selnor)knapphartung     //ref group: CAMNEA //
 metareg lnor bldtypecat2 bldtypecat3, wsse(selnor)knapphartung       //ref group: E blgs //
 metareg lnor collectcat1, wsse(selnor)  knapphartung                //ref group: A      //
 metareg lnor diagcat2, wsse(selnor)    knapphartung               //ref group: S      // 
 metareg lnor studydescat1 studydescat2,wsse(selnor) knapphartung  // study design     //
 metareg lnor qclasscat2 ,wsse(selnor) knapphartung             // quality calss    //


 ***IMPORTANT: Based on the meta-regressions above, none of the parameters 
 ***are significant predictors for het of ORs for wheezing outcomes, therefore
 *** we are not clustering wheezing investigations based on any of those. 
 
 /* 
//clustering based on building type
*admetan lnor lnll lnul, study(investigation) eform(OR)by(bld_type)   re(reml, hksj) nowarning  forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.1 0.5 1 8, force) xtick(0.1 0.5 1 8)   plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))
 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m_bld_type.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m_bld_type.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m_bld_type.png",  width(800) height(600) replace


*/ 
    /* Sensitivity Analysis */ 
	
	* Finding outlier investigations
	
	* outlier among ORs
	sum(or), detail
	
	
	* q1=0.73, iqr=0.78, q3=1.25, outliers should be less than -0.05(impossible) or greater than 2.03
		//results show that Vedanthan 2006 with  or =2 is the outlier investigation
	
	graph box or
	* outlier among SE(LN(OR))'s
	sum(selnor), detail
	
	* q1=0.73, iqr=0.78, q3=1.25, outliers should be less than -0.05(impossible) or greater than 2.03
		//results show that Vedanthan 2006 with  or =2 is the outlier investigation
	
	
	
	graph box selnor
	
	

	*** IMPORATNT: no outlier investigation among wheezing investigations. 
	*** but it is an outlier based on the SE(LN(OR))'s 
	
	
	
	drop if _n==10 // Droping one the Vedanthan 2006 as the outlier for funnel plots

	
// hksj suboption: tau-squared estimator with Hartung-Knapp-Sidik-Jonkman,

admetan lnor lnll lnul, study(investigation) eform(OR) forestplot(favours(Protective effect #Harmuful effect) astext(60) xlabel(0.25 0.5 1 1.25 1.5, force) xtick(0.25 0.5 1 1.25 1.5) plotregion(fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)))     re(reml, hksj) nowarning 


graph save   "${path2}/babak_new/Review Paper/graphs/FP_wheezing_all_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_wheezing_all_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/FP_wheezing_all_m_sa.png",  width(800) height(600) replace

// metafunnel centered at the mean OR of fixed model // 

metafunnel lnor selnor, eform  subtitle(" ") xtitle("Logarithm (Odds Ratio)") ytitle("Standard Error of the Log (Odds Ratio)") yla(, format(%9.1f) tp(c) angle(horizontal) nogrid)  plotregion( fcolor(white) lcolor(black) lwidth(medium) margin(medium) lpattern(solid) ifcolor(none) ilcolor(none) ilwidth(none) ilpattern(solid)) graphregion(color(white)) 

 
//saving the gph, and exporting eps, and png graphic outputs

graph save   "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m_sa.gph", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m_sa.eps", replace
graph export "${path2}/babak_new/Review Paper/graphs/Funnel_wheezing_all_m_sa.png",  width(800) height(600) replace


	
 	
  
  
  
  
  
  
