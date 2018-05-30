/*PSID*/

OPTIONS FORMCHAR="|----|+|---+=|-/\<>*";
ods listing;
title;
options pageno=1;

/*Import the data*/
OPTIONS nofmterr;
libname b512 "C:\Users\yichizh\Downloads";
data PSID;
  set b512.psid_wb;
run;

/**************
Step 1: data management & descriptive graphics
**************/

proc sort data=PSID;
  by id;
run;

/*avg is the average wb for each id*/
data PSID5;
  set PSID;
  by id;
  if first.id;
  keep id age volfreq health exercise vigact lightact intuse BMI avg_wb; /*the level 2 variables*/
  avg_wb=mean(of wb);
run;

/*Regression plot of mean(wb) and continuous BMI*/
ods html style=SasWeb; 
proc sgplot data=PSID5;  
	reg y=avg_wb x=BMI;
run; 
quit;

/*Do the same stuff as above on intuse/volfreq/...*/
ods html style=SasWeb; 
proc sgplot data=PSID5;  
	reg y=avg_wb x=intuse;
run; 
quit;

ods html style=SasWeb; 
proc sgplot data=PSID5;  
	reg y=avg_wb x=volfreq;
run; 
quit;

ods html style=SasWeb; 
proc sgplot data=PSID5;  
	reg y=avg_wb x=health;
run;
quit;

/*count freq by id*/
/*Generated BMI Category*/
/*Generated centered base age*/
/*Add centered age and year to make the intercept on this variable interpretable within the sample*/

/*We decided to collapse light and vigorous exercise in to:
-do you do light exercise
-do you do vigorous exercise
-do you do both?
-do you do none?*/
data PSID2; 
  set PSID;
  count + 1;
  by id;
  if first.id then count = 1;

  centyear=year-2005;
  centage=age-17;
  label centyear="Centered Year at 2005";
  label centage="Centered Age in Years";

  BMICat=.;
  if bmi^=. and bmi>19 and bmi<25 then BMICat=2;
  if bmi^=. and bmi<=19 then BMICat=1;
  if bmi^=. and bmi>=25 then BMICat=3;
  label BMICat="BMI Category";

  exercise=.;
  if lightact=6 and vigact=6 then exercise=0;
  if lightact^=. and lightact<6 and vigact=6 then exercise=1;
  if vigact^=. and lightact=6 and vigact<6 then exercise=2;
  if lightact^=. and lightact<6 and vigact^=. and vigact<6 then exercise=3;
  label exercise="Exercise";

  exercise_binary=.;
  if exercise^=. and exercise=0 then exercise_binary=0;
  if exercise^=. and exercise^=0 then exercise_binary=1;
  label exercise_binary="Exercise or Not";
 
run;

title "Descriptive Centered Age";
proc means data=PSID2;
var centage;
run;

title "Descriptive Centered Year";
proc means data=PSID2;
var centyear;
run;

/*Labeling*/
proc format;
  value sex 2="Female"
            1="Male";
  value vol 0="no"
            1="yes";
  value volfreq 0="not at all"
            1="less than once a month"
			2="at least once a month"
			3="once a week"
			4="several times a week"
			5="almost every day"
			6="every day";
  value health 1="excellent"
            2="very good"
			3="good"
            4="fair"
            5="poor";
  value vigact 1="several times a week"
			2="about once a week"
			3="several times a month"
			4="about once a month"
			5="less than once a month"
			6="never";
  value lightact 1="several times a week"
			2="about once a week"
			3="several times a month"
			4="about once a month"
			5="less than once a month"
			6="never";
  value smoke 0="no"
            1="yes";
  value alcohol 0="no"
            1="yes";
  value smoke 0="no"
            1="yes";
  value spirit 0="no"
            1="yes";
  value race 1="White"
			2="Black"
			3="Other";
  value BMIcat 1="underweight"
			2="normalweight"
			3="overweight";
  value exercise_binary 0="no"
  			1="yes";
  value exercise 0="no exercise"
  			1="light exercise"
			2="vigorous exercise"
			3="light&vigorous exercise";
run;


title "Tab BMICat";
proc means data=PSID2;
  class BMICat;
  var id;
run;

title "Tab exercise";
proc means data=PSID2;
  class exercise;
  var id;
run;

/*Descriptive Graphics*/
proc sgpanel data=PSID2;
  panelby sex / novarname;
  vbox wb / category=centyear;
  format sex sex.;
run;

proc sgpanel data=PSID2;
  panelby centyear / novarname columns=4;
  vbox wb;
run;

proc sgpanel data=PSID2;
  panelby BMICat / novarname columns=3;
  vbox wb / category=centyear;
run;

proc sgpanel data=PSID2;
  panelby race / novarname columns=3;
  vbox wb / category=centyear;
  format race race.;
run;


/*Get summary stats for variables in dataset*/
PROC MEANS DATA=PSID2;
RUN;

PROC FREQ DATA=PSID2;
RUN;

title "Tab wellbeing";
PROC MEANS DATA=PSID2;
  class year;
  var wb;
RUN;


/**************
Step 2: How important is the time variable in this dataset?
**************/

/*generate sample for spaghetti plots, to look at relationship b/t time and well-being*/
/*Below is the data manipulation for getting random 50 people who had at least two time points*/

/*get the study attening freq by id*/
proc means data=PSID2 noprint max nway missing; 
   class id;
   var count;
   output out=sample_max (drop=_type_ _freq_) max=;
run;

/*drop those have only 1 time point*/
data sample_max2;
   set sample_max;
   if count = 1 then delete;
run;

/*random get 50 ids*/
proc surveyselect data=sample_max2
   method=srs n=50 out=SampleSRS;
run;

/*merge data*/
data PSID3;
   merge SampleSRS PSID;
   by id;
run;

/*drop missing count data*/
/*finally get all obersavations under each id for 50 random ids*/
data PSID4;
   set PSID3;
   if count = . then delete;
run;

title "Tab Year";
proc means data=PSID4;
  class id;
  var year;
run;

/*sample dataset*/
proc mixed data=PSID4 covtest cl;
  class id;
  model wb = year / solution;
  random intercept / subject = id;
run;

/*spaghetti plots for the 50 ids identified in the ‘sample’ data*/
proc sgplot data=PSID4 noautolegend;
  series x=year y=wb / group=id;
run;
proc sgplot data=PSID4 noautolegend;
  series x=age y=wb / group=id;
run;
/*Comment on spaghetti plots: no clear, distinguishable relationship between time
and well-being*/

/*whole dataset*//*Looking at time effects in the full model*/
proc mixed data=PSID2 covtest cl;
  class id;
  model wb = year / solution;
  random intercept / subject = id;
run;
/*Year has a significant coefficient, but effect is small*/

/** After adding the random slope(year), the model did not converge at all. **/

/*Checking to see if age is a more valuable time-varying variable than year*/
/*sample dataset*/
proc mixed data=PSID4 covtest cl;
  class id;
  model wb = age / solution;
  random intercept / subject = id;
run;

/*whole dataset*/
proc mixed data=PSID2 covtest cl;
  class id;
  model wb = age / solution;
  random intercept / subject = id;
run;
/*Nope! age is less significant than year*/

/*Checking correlation between age and year*/
proc corr data=PSID2 sscp cov plots;
   var  age year;
run;


/*********************/
/*Alternate way of checking significance of a time effect: LR Test*/
/*********************/

/*Re-running mixed model with and without a fixed effect for year, using ML*/
/*instead of REML so that we can do a likelihood ratio test*/
/*with year*/
proc mixed data=PSID2 method=ml;
  class id;
  model wb = year/ solution; /*fixed part*/
  random intercept / subject = id solution type=un g gcorr ; /*random part*//*g: gcorr: correlation*/
  ods exclude solutionR;
  ods output solutionR=solutionRdat;
run;

/*without year*/
proc mixed data=PSID2 method=ml;
  class id;
  model wb = / solution; /*fixed part*/
  random intercept / subject = id solution type=un g gcorr ; /*random part*//*g: gcorr: correlation*/
  ods exclude solutionR;
  ods output solutionR=solutionRdat;
run;

data test;
  LLFull=46971.4;
  LLRed =46993.4;
  Chi_square=llred-llfull;
  pvalue=(1-probchi(chi_square/2,1));
  format pvalue 10.8;
run;
proc print data=test;
run;

/**************
Step 3: Fitting the Model
**************/

proc corr data=PSID2 sscp cov plots;
   var exercise BMICat;
run;

proc sgpanel data=PSID2;
  panelby exercise / novarname columns=4;
  vbox wb;
run;
/**************/
/*also decided to drop alcohol as a covariate*/

/*Creating baseline age as a level 2 (time-invariant) variable*/
proc means data=PSID2 noprint min nway missing; 
   class id;
   var age;
   output out=sample_min (drop=_type_ _freq_) min=;
run;

/*merge data*/
data PSID6;
   merge PSID2 sample_min(rename=(age=baseage));
   by id;
run;

/*Centering baseline age*/
data PSID7;
  set PSID6;
  centbaseage=baseage-17;
run;


/*Top model*/
proc mixed data=PSID7 covtest cl;
  class id health (ref="excellent") exercise sex race BMICat;
  model wb = vol health spirit smoke alcohol intuse exercise year sex race BMICat centbaseage / solution;
  random intercept / subject = id;
run;
/*Exercise is still insignificant. Replace exercise with a binary variable in the future*/

 
/********** Model Fitting *********/
/*Null Model with random intercepts*/
proc mixed data=PSID2 covtest cl;
  class id;
  model wb = / solution;
  random intercept / subject = id;
run;

/*Calculate ICC*/
ods output CovParms = covp;
proc mixed data = PSID2;
   class id;
   model wb = / solution;
   random intercept /subject = id;
run;

data icc;
  set covp end=last;
  retain bvar;
  if subject~="" then bvar = estimate;
  if last then icc = bvar/(bvar+estimate);
run;
proc print data = icc;
run;

/*Add Level1 Model with random intercepts*/
proc mixed data=PSID7 covtest cl order=internal;
  class id health;
  model wb = vol health spirit smoke intuse exercise_binary centyear/ solution ddfm=sat;
  random intercept / subject = id;
run;

/*Add Level2 Model with random intercepts*/
proc mixed data=PSID7 covtest cl order=internal;
  class id health (ref="excellent") race BMICat(ref="1") sex;
  model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution ddfm=sat;
  random intercept / subject = id;
run;

/*Calculate Adjusted ICC*/
ods output CovParms = covp;
proc mixed data = PSID7;
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution ddfm=sat;
   random intercept /subject = id;
run;

data icc;
  set covp end=last;
  retain bvar;
  if subject~="" then bvar = estimate;
  if last then icc = bvar/(bvar+estimate);
run;
proc print data = icc;
run;

/*Tried a random slope for year*/
proc mixed data=PSID7 covtest cl order=internal;
  class id health (ref="excellent") race BMICat(ref="1") sex;
  model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution ddfm=sat;
  random intercept centyear / subject = id;
run;
/*bad result still*/

/**********************
Step 4: Final Model
**********************/

/*Refit the final model and check model diagnostics*/
ods graphics on;
ods trace on;
title "Final Model";
proc mixed data = PSID7 PLOTS(MAXPOINTS=100000);
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution RESIDUAL;
   random intercept /subject=id solution;
   ods output solutionR = solutionRdat;
run;
ods trace off;
ods graphics off;
/*in final model above, we have year as the time variable, and centbase age to test time-invariant cohort effect*/

title "Distribution of Random Intercepts";
proc univariate data=solutionRdat;
  var estimate;
  histogram / normal;
  qqplot / normal(mu=est sigma=est);
  where effect="Intercept";
run;

/**********************/
/*Testing some of the non-significant variables and sets of dummy variables*/

/*re-running final model as a maximum likelihood model in order to test fixed effects with a likelihood ratio test*/
/*
AIC (smaller is better) 15720.6 
BIC (smaller is better) 15825.8 
*/
title "Final Model ML";
proc mixed data = PSID7 method=ml;
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
   random intercept /subject=id;
run;

/*testing with null model lacking exercise_binary*/
/*
AIC (smaller is better) 22926.9 
BIC (smaller is better) 23029.0 
*/
proc mixed data = PSID7 method=ml;
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = vol health spirit smoke intuse sex race BMICat centbaseage centyear / solution;
   random intercept /subject=id;
run;

/*testing with null model lacking BMICat*/
/*
AIC (smaller is better) 15764.1
BIC (smaller is better) 15858.3 
*/
proc mixed data = PSID7 method=ml;
   class id health (ref="excellent") race sex;
   model wb = vol health spirit smoke intuse sex race exercise_binary centbaseage centyear / solution;
   random intercept /subject=id;
run;

/**********************
Step 5: Testing Marginal vs. Mixed Linear Models
*********************/

/*Marginal Model- worse AIC/BIC values than LMM*/
/*Unstructured*/
title1 "Marginal Model";
title2 "Unstructured Cov Matrix";
proc mixed data=PSID7;
  class id health (ref="excellent") race BMICat(ref="1") sex centyear;
  model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
  repeated centyear  / subject=id type=un r rcorr;
run;

/*other R matrix structures*/
/*Compound symmetry*/
title1 "Marginal Model";
title2 "Compound Symmetric Cov Matrix";
proc mixed data=PSID7;
  class id health (ref="excellent") race BMICat(ref="1") sex year;
  model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
  repeated year  / subject=id type=cs r rcorr;
run;

/*Toeplitz*/
title1 "Marginal Model";
title2 "Toeplitz Cov Matrix";
proc mixed data=PSID7;
  class id health (ref="excellent") race BMICat(ref="1") sex centyear;
  model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
  repeated centyear  / subject=id type=toep(1) r rcorr;
run;

/*Autoregressive (lag 1)*/
title1 "Marginal Model";
title2 "Autoregressive Cov Matrix";
proc mixed data=PSID7;
  class id health (ref="excellent") race BMICat(ref="1") sex centyear;
  model wb = vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
  repeated centyear  / subject=id type=ar(1) r rcorr;
run;
/*Compound Symmetric AIC is the smallest one in these marginal models*/

/**********************
Step 6 (Appendix): Test of different Possible Interaction terms (none were significant)
*********************/

/*Baseline age with smoking*/
proc mixed data = PSID7;
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = centbaseage*smoke vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
   random intercept /subject=id;
run;
/*non-significant interaction term*/

/*Centered age interacted with spirituality*/
proc mixed data = PSID7;
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = centage*spirit vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
   random intercept /subject=id;
run;
/*non-significant interaction term*/

/*BMICat interacted with binary exercise variable*/
proc mixed data = PSID7;
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = BMICat*exercise_binary vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
   random intercept /subject=id;
run;
/*non-significant interaction term*/

/*Centered age interacted with smoking*/
proc mixed data = PSID7;
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = centage*smoke vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
   random intercept /subject=id;
run;
/*non-significant interaction term*/

/*Volunteerism intersected with health*/
proc mixed data = PSID7;
   class id health (ref="excellent") race BMICat(ref="1") sex;
   model wb = vol*health vol health spirit smoke intuse exercise_binary sex race BMICat centbaseage centyear / solution;
   random intercept /subject=id;
run;
/*overall not very significant interaction term*/
