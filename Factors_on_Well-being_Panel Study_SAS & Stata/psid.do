clear
use "M:\PSID_WB.dta"
log using BIOS512.log, replace

/**************
Step 1: data management & descriptive graphics
**************/

/*Regression plot of mean(wb) and continuous BMI*/
by id: egen meanwb = mean(wb)
twoway scatter meanwb bmi
twoway lfit meanwb bmi

/*Generate BMI Categories for Descriptive Statistics*/
gen BMICat=.
replace BMICat=2 if bmi>19 & bmi<25
replace BMICat=1 if bmi<=19
replace BMICat=3 if bmi>=25
tab BMICat, m
label var BMICat "BMI Category"
label define BMICat 1 "underweight" 2 "normalweight" 3 "overweight"
label values BMICat BMICat

/*Descriptive Graphics*/
graph box wb, over(year)
graph box wb, over(year) by(sex) 
graph box wb, over(BMICat) 
graph box wb, over (race)

/*make a centered age variable to*/
/*make the intercept on this variable interpretable within the sample*/
gen centage = age-17
label var centage "Centered Age in Years"
sum centage

/*Centered Year*/
gen centyear = year-2005
label var centyear "Centered Year at 2005"
sum centyear

/*Get summary stats for variables in dataset*/
tabstat id year sex age vol volfreq health vigact lightact smoke alcohol spirit wb intuse race bmi, s(n mean sd min max) columns(s)
tabstat wb, by(year) s(n)

/**************
Step 2: How important is the time variable in this dataset?
**************/

/*generate sample for spaghetti plots, to look at relationship b/t time and 
well-being*/
save "M:\PSID_WB.dta", replace
bysort id: gen count=_n
tab count
drop if count==1
keep id
sample 50, count
gen sample=1
save "sampledata2.dta", replace

use "M:\PSID_WB.dta"
merge m:m id using "sampledata2.dta"
tab id if _merge==3
tab _merge

/*Generate spaghetti plots for sample data- look at relationship b/t time and 
well-being*/
xtmixed wb year if _merge==3 || id: , var cov(un) reml
xtline wb if _merge==3, t(year) i(id) overlay saving(graphF.gph,replace) legend(off)
/*Comment on spaghetti plots: no clear, distinguishable relationship between time
and well-being*/

/*Looking at time effects in the full model*/
xtmixed wb year || id: , var cov(un) reml
/*Year has a significant coefficient, but effect is small*/

/***Note: following model didn't converge:
xtmixed wb year || id: year , var cov(un) reml
Will not include random slope in model */

*****
/*Checking to see if age is a more valuable time-varying variable than year*/
xtmixed wb age if _merge==3 || id: , var cov(un) reml
xtline wb if _merge==3, t(age) i(id) overlay saving(graphF.gph,replace) legend(off)
xtmixed wb age || id: , var cov(un) reml
/*Nope! age is less significant than year*/

/*Checking correlation between age and year*/
corr age year
/*Because of high correlation, will just use year as time variable. Will create
baseline age as a level 2 time-invariant variable to test for any cohort effect*/
egen baseage = min(age), by(id)
/*Centering baseline age*/
gen centbaseage = baseage-17

*********************
/*Alternate way of checking significance of a time effect: LR Test*/
*********************

/*Re-running mixed model with and without a fixed effect for year, using ML*/
/*instead of REML so that I can do a likelihood ratio test*/
xtmixed wb year || id: , var cov(un) ml
estimates store yearcheck
xtmixed wb || id:, var cov(un) ml
lrtest yearcheck .

/**************
Step 3: Fitting the Model
**************/

/*Run everything: top-down approach*/
xtmixed wb vol ib1.health spirit smoke alcohol c.intuse ib6.vigact ib6.lightact year i.sex i.race i.BMICat baseage || id:, var cov(un) reml

/*decided to collapse light and vigorous exercise in to:
-do you do light exercise
-do you do vigorous exercise
-do you do both?
-do you do none?*/

gen exercise=.
sort id
replace exercise=0 if lightact==6 & vigact==6
replace exercise=1 if lightact<6 & vigact==6
replace exercise=2 if lightact==6 & vigact<6
replace exercise=3 if lightact<6 & vigact<6
tab exercise, m

label var exercise "Exercise"
label define exercise 0 "no exercise" 1 "light exercise" 2 "vigorous exercise" 3 "light&vigorous exercise"
label values exercise exercise
graph box wb, over(exercise)

corr exercise BMICat

**************
/*also decided to drop alcohol as a covariate*/


/*Model, take 2*/

xtmixed wb vol ib1.health spirit smoke c.intuse i.exercise year i.sex i.race i.BMICat || id:, var cov(un) reml
estat ic

/*Exercise is still insignificant. Replace exercise with a binary variable*/

gen exercise_binary=.
replace exercise_binary=0 if exercise==0
replace exercise_binary=1 if exercise>0 & exercise~=.

*****************
/*Null vs Level 1 vs Level 1 and Level 2*/
/*First, install program to calculate ICCs*/
ssc install xtmrho, replace

/*Null Model*/
xtmixed wb || id:, var cov(un) reml
/*
sigma^2 between: 3.44
sigma^2 within: 2.94
*/

/*Level 1 Predictors Only*/
xtmixed wb vol ib1.health spirit smoke exercise_binary c.intuse centyear  || id:, var cov(un) reml
xtmrho
/*
sigma^2 between: 2.67
sigma^2 within: 2.8338
*/

/*Level 1 R^2*/
di (2.94-2.83)/2.94
/*Note: values in SAS and STATA don't match exactly*/

/*Add in Level 2 Predictors*/
xtmixed wb vol ib1.health spirit smoke exercise_binary c.intuse i.sex i.race i.BMICat centyear centbaseage || id:, var cov(un) reml
xtmrho
/*
sigma^2 between: 2.64
sigma^2 within: 2.8334
*/

/*Level 2 R^2*: Based on these results- addl R^2 with Level 2 predictors=0*/
di (2.8338-2.8334)/2.83
*/

/**********************
Step 4: Final Model
**********************/

xtmixed wb vol ib1.health spirit smoke c.intuse i.sex i.race i.exercise_binary centyear i.BMICat centbaseage || id:, var cov(un) reml
estat ic

/*in final model above, we have year as the time variable, and centbase age to test time-invariant cohort effect*/

/*Model Diagnostics*/
predict eblup*, reffects
bysort id: gen count=_n
histogram eblup if count==1

predict resid, rstandard
predict fitted, fitted

qnorm resid
scatter resid fitted

**********************

/*Testing some of the non-significant variables and sets of dummy variables*/

/*re-running final model as a maximum likelihood model in order to test fixed effects with a likelihood ratio test*/
qui xtmixed wb vol ib1.health spirit smoke c.intuse i.sex i.race i.exercise_binary centyear i.BMICat centbaseage || id:, var cov(un) ml
estimates store final

/*testing with null model lacking BMICat*/
qui xtmixed wb vol ib1.health spirit smoke c.intuse i.sex i.race i.exercise_binary centyear centbaseage || id:, var cov(un) ml
lrtest final .

/*testing significance of all self-rated health dummies at once with a Wald test*/
qui xtmixed wb vol ib1.health spirit smoke c.intuse i.sex i.race i.exercise_binary centyear i.BMICat centbaseage || id:, var cov(un) reml
test 1.health 2.health 3.health 4.health 5.health

/**********************
Step 5: Testing Marginal vs. Mixed Linear Models
*********************/

/*Marginal Model- worse AIC/BIC values than LMM*/

/*unstructured*/
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex age i.race centyear centbaseage || id:, nocons var residuals(un, t(year)) reml
estat ic

/*other R matrix structures*/

/*compound symmetric- same AIC/BIC values as unstructured*/
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex i.race centyear centbaseage || id:, nocons var residuals(exc) reml
estat ic

/*Toeplitz- does not converge*/
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex age i.race centyear centbaseage || id:, nocons var residuals(toeplitz 1, t(year)) reml
estat ic
/*AR 1 - does not converge*/
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex age i.race centyear centbaseage || id:, nocons var residuals(ar 1, t(year)) reml
estat ic

/**********************
Step 6 (Appendix): Test of different Possible Interaction terms (none were significant)
*********************/

/*Baseline age with smoking*/
gen smokebaseage = smoke*centbaseage
xtmixed wb vol ib1.health spirit smoke c.intuse i.sex i.race i.exercise_binary centyear i.BMICat centbaseage smokebaseage || id:, var cov(un) reml

/*Centered age interacted with spirituality*/
gen centagespirit = centage*spirit
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex centage centagespirit i.race || id:, var cov(un) reml
/*non-significant interaction term*/

/*BMICat interacted with binary exercise variable*/
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat##exercise_binary sex centage i.race || id:, var cov(un) reml
/*non-significant interaction term*/

/*Centered age interacted with smoking*/
gen centagesmoke = centage*smoke
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex centage centagesmoke i.race || id:, var cov(un) reml
/*non-significant interaction term*/

/*Volunteerism intersected with health*/
gen volhealth = vol*health
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex year volhealth i.race || id:, var cov(un) reml
/*non-significant interaction term*/

twoway lfit meanwb health, by(vol)

/*Spirituality interected with health*/
gen spirithealth = spirit*health
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex year spirithealth i.race || id:, var cov(un) reml
/*no*/

/*Spirituality and sex*/
gen sexspi = sex*spirit
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex year sexspi i.race || id:, var cov(un) reml
/*Marginal significance at p=0.073*/

twoway lfit meanwb spirit, by(sex)

/*Volunteerism and sex*/
gen sexvol = sex*vol
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex year sexvol i.race || id:, var cov(un) reml
/*not significant*/

/*Year and sex*/
gen yearsex = year*sex
xtmixed wb vol ib1.health spirit smoke c.intuse i.BMICat sex year yearsex i.race || id:, var cov(un) reml
/*not significant*/

log close

