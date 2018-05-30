/*Babak Khamsehi, Capstone with Dr. Marie Oneill, W15, Univ of Michigan*/
/* necessary line to access the dataset */ 
options nofmterr;

* My capstone permanent folder; 
libname Capstone "M:\Private\w15\Capstone\Babak\Results"; /* Adjust the folder to your need */ 

* Making a copy of luis's orginal dataset in my capstone permanent folder;
data capstone.capstone;
set Capstone.Luis_may2011;
run;
* Making another copy of luis's orginal dataset in the temporary work-folder;
data work.capstone;
set capstone.capstone;
run;
* Contents listing of the original(Luis's) dataset; 
proc contents data=capstone;
run;

proc means data=capstone n mean min max  nmiss p50;
var  folio age_m delivery_male MARITAL_STATUS school_t1 schoolp_t hrp_parity cigsdaypreg Mom_calf_1mopp;
run;

/* Importing the DBF cohort1 (Mother's ID and address)intersected with AGEB (census tract) into SAS */ 
PROC IMPORT OUT= capstone.cohort1
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\cohort1.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;

*BK: ^ 31 VARs x  597 rows for C1; 



/* Importing the DBF cohort2a(=Cohort2BI_ageb.dbf) interesected with AGEB into SAS */ 
PROC IMPORT OUT= capstone.cohort2a
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\cohort2a.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;

*BK: ^ 30 VARs x  363 rows for C2a; 
 
/* Importing the DBF cohort2b(=Cohort2PLD1_ageb.dbf) interesected with AGEB into SAS */ 
PROC IMPORT OUT= capstone.cohort2b
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\cohort2b.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;

*BK: ^ 34 VARs x 279 rows for C2b; 

/* Importing the DBF cohort2c(=Cohort2PLD2_ageb.dbf) interesected with AGEB into SAS */ 
PROC IMPORT OUT= capstone.cohort2c
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\cohort2c.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;

*BK: ^ 27 VARs x 85 rows for C2c; 

/* Importing the DBF cohort3(=Cohort3_ageb.dbf) interesected with AGEB into SAS */ 
PROC IMPORT OUT= capstone.cohort3
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\cohort3.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;

 *Stacking all of cohort 2;
data capstone.cohort2;
set capstone.cohort2a capstone.cohort2b capstone.cohort2c;
run;

*BK: ^ 30 VARs x 670 rows for C3;


*Creating copies in the work folder; 

 data work.cohort1;
 set capstone.cohort1;
 run;

 data work.cohort3;
 set capstone.cohort3;
 run;


data work.cohort2;
 set capstone.cohort2;
 run;




proc contents data=cohort1 ;
run;

proc contents data=cohort3 ;
run;

data capstone.cohort2;
set capstone.cohort2a capstone.cohort2b  capstone.cohort2c;
run;

 
data cohort2;
set capstone.cohort2;
run;

proc contents data=cohort2;
run;


/*BK: Lines 78-99 makes cohort1 compatible with other cohorts*/ 
*BK:STEP1 changing the format from numeric to character;
data cohort1;
set cohort1;
FOLIO2=PUT(FOLIO,8.);
run;

*BK:STEP2 Dropping the old variable;
data cohort1;
set cohort1;
drop FOLIO;
run;

proc contents data=cohort1 ;
run;

*BK:STEP3 Renaming;
data cohort1;
set cohort1 (rename=(FOLIO2=FOLIO)); 
run;


*Stacking Cohort 1 and Cohort3;

data cohort1_3;
set cohort1 cohort3;
run;

proc contents data=cohort1_3 varnum;
run;


/* BK: STACKING All cohorts */ 
data cohortall;
set cohort1_3 cohort2;
run;

proc contents data=cohortall varnum;
run;

/*BK: ^ cohortall has 1994 observations (all cohorts intersected with agebs) */ 
* NDVI File imports;


/*Importing the DBF NDVI for the selected cloud-free day in 1995 tables into SAS */ 
PROC IMPORT OUT= capstone.ndvi1995 
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\ndvi1995.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;
* ^ 4107 Observations, though the last one is probably not valid, 10 variables;


/* Importing the DBF NDVI for the selected cloud-free day in 1999 tables into SAS */ 
PROC IMPORT OUT= capstone.ndvi1999 
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\ndvi1999.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;
* ^ 4151 observationns and 10 variables;



/* Importing the DBF NDVI for the selected cloud-free day in 2003 tables into SAS */ 
PROC IMPORT OUT= capstone.ndvi2003 
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\ndvi2003.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;
* ^ 4173 observations and 10 variables;


* TxtValue is the common identifier between the agebs and NDVI;

*Making copies of NDVI datasets in the Work folder;

data NDVI1995;
	set capstone.ndvi1995;
	run;

data ndvi1999;
	set capstone.ndvi1999;
	run;

data ndvi2003;
	set capstone.ndvi2003;
	run;

/* Checking contents*/

proc contents data=ndvi1995;
run;

proc contents data=ndvi1999;
run;

proc contents data=ndvi2003;
run;


proc contents data=cohortall;
run;
* ^ The variable 'TxtValue' is character, not numeric, in 'cohortall' and the 'NDVI' datasets ;
 
/* BK: A copy in the permanent folder */ 
data capstone.cohortall;
set cohortall;
run;
* ^ Cohortall has 1994 observations and 44 variables ;

proc contents data=cohortall varnum;
run;


/*BK: Merging cohort 1 with NDVI1995 */ 
proc sort data=cohort1;
by txtvalue;
run;

proc sort data=ndvi1995;
by txtvalue;
run;


data cohort1_95;
merge cohort1 ndvi1995;
by txtvalue;
run;
* ^ 4355 observations and 40 variables; 

* ^  Note: some agebs do not have any study subjects living in them.  
Other agebs have more than one mother (subject) living in them.  
The TxtValues for those agebs will appear more than once in the dataset after this merge.  ;

data cohort1_95_Both;
merge cohort1(in=a) ndvi1995(in=b);
by txtvalue;
if a and b;
run;
* ^ 597 observations and 40 variables = 597 mothers;


/*BK: Merging cohort 2 with NDVI1999 */ 
proc sort data=cohort2;
by txtvalue;
run;

proc sort data=ndvi1999;
by txtvalue;
run;


data cohort2_99;
merge cohort1 ndvi1999;
by txtvalue;
run;

* ^ 4399 observations and 40 variables;

data cohort2_99_Both;
merge cohort2(in=a) ndvi1999(in=b);
by txtvalue;
if a and b;
run;
* ^ 725 observations and 49 variables = 725 mothers;


/*BK: Merging cohort 3 with NDVI2003 */ 
proc sort data=cohort3;
by txtvalue;
run;

proc sort data=ndvi2003;
by txtvalue;
run;


data cohort3_2003;
merge cohort3 ndvi2003;
by txtvalue;
run;

* ^ 4605 observations and 39 variables; 


data cohort3_2003_Both;
merge cohort3(in=a) ndvi2003(in=b);
by txtvalue;
if a and b;
run;
* ^ 669 observations and 39 variables = 669 mothers;





*Health Data - we need to add that in before using the following variables;
/*BK: there is no health-data in the cohort1_95_Both.. so we need to merge it with capstone(our health dataset)*/ 
/**/
/*proc means data=cohort1_95_Both;*/
/*var age_M marital_status school_T1 schoolp_t hrp_parity cigsdaypreg mom_calf_lmopp delivery_M mean;*/
/*run;*/

*'mean' = ndvi;

/* BK: STACKING All cohorts with NDVIs */ 
data cohortall_ndvi;
set cohort1_95_Both cohort2_99_Both cohort3_2003_Both;
run;
/* ^ BK:  COHORTALL_NDVI has  1991 observations and 53 variables 
(all mother's id intersected with ageb intersected with NDVI's)*/ 


/*BK: A copy to the permanet folder */ 

data capstone.cohortall_ndvi;
set cohortall_ndvi;
run;

* ^ 1991 observations and 53 variables;

proc print data=cohortall_ndvi;
var folio txtvalue;
run;

proc print data=capstone;
var folio folio2 folio2_old proyecto_ordered;
run;
* ^ YAY :) ; 

/* BK: folio2 in capstone is the same varible as folio in cohortall_ndvi. 
However, observations 1:597 do not have the prefix added to them. in the following code we 
are adding the prefix and then merge both datasets */ 


proc contents data=capstone;
run;

proc contents data=cohort1; 
run; 

proc print data=cohort1;
var folio;
run;

*Sorting;
proc sort data=cohortall_ndvi; by folio;run;
proc print data=cohortall_ndvi; var folio; run;

proc sort data=capstone; by folio2;run;
proc print data=capstone; var folio2; run;

/* BK: Importing prefix.csv */ 


proc print data=prefix; run;
* sorting to merge; 
*PLZ DO NOT DO THE SORT: IT IS EXTREMELY IMPORTANT;
/*proc sort data=cohortall_NDVI; by folio; run;*/
/*proc sort data=prefix; by folio; run;*/


 proc print data=cohortall_NDVI; var folior folio; run;
data prefix;
set prefix; 
folior = strip(var1)||strip(var2); ; /*BK: Combining variables*/  
run; 



proc print data=prefix; run;
* sorting to merge; 
*PLZ DO NOT DO THE SORT: IT IS EXTREMELY IMPORTANT;
proc sort data=cohortall_NDVI; by folio; run;
proc sort data=prefix; by folior; run;


 
data prefix;
set prefix; 
folior = strip(var1)||strip(var2); ; /*BK: Combining variables*/  
run; 

/*BK: very important: Removing spaces and after the folio ID variable */ 
data cohortall_NDVI;
set cohortall_NDVI;
folio = strip(folio);
run;

proc contents data=cohortall_NDVI; run; 
proc print data=cohortall_NDVI; var folio folio1 fid_1 fid_cohort; run;
proc print data=prefix; var var2 folior; run;

/*BK: renaming var2 to folio3 to be the unique common identifier between prefix and cohortall_ndvi*/ 
data prefix;
set prefix (rename=(var2=folio));
run;

proc sort data=cohortall_NDVI;by folio;run; 
proc sort data=prefix;;by folio;run; 

data cohortall_NDVI2;
merge cohortall_NDVI prefix;
by folio;
run;


* A permanent copy; 
data capstone.cohortall_NDVI2;
set  cohortall_NDVI2;
run;
/* 1991 Ready to merge with capstone(health data) */ 

proc print data=cohortall_NDVI2; var folior; run;
proc contents data=capstone;  run; 

proc print data=capstone; var folio6; run;

data capstone;
set capstone;
folio6 = folio2;
run;

data checkmissing; set capstone; folio5=strip(folio2); keep folio5 folio2; run;

data cohortall_NDVI2;
set cohortall_NDVI2;
folio6 = folior;
run;

proc print data=capstone; var folio5; run;

data cohortall_NDVI2;
set cohortall_NDVI2;
folio5 = strip(folio5);
run;


***;


data capstone1; set capstone; rename FOLIO=FileID; run;
data capstone2; set capstone1; rename folio2=FOLIO; run;

proc sort data=capstone2; by folio;run;
proc sort data=cohortall_NDVI2; by folio;run;


data merge_data;
 merge capstone2(in=a) cohortall_NDVI2(in=b);
 by folio;
 if a and b;
run;


****;






proc sort data=capstone; by folio6;run;
proc sort data=cohortall_NDVI2; by folio6;run;


proc print data=capstone; var folio5;run;
proc print  data=cohortall_NDVI2; var folio5;run;

data cohortall_NDVIf;
merge cohortall_NDVI2(in=a) capstone(in=b);
by folio6;
if a and b;
run;
* IN cohort all but not in capstone;
data cohortall_NDVIf2;
merge cohortall_NDVI2(in=a) capstone(in=b);
by folior;
if a and  not b;
run;

* In capstone but not in cohortall;
data cohortall_NDVIf3;
merge cohortall_NDVI2(in=a) capstone(in=b);
by folior;
if b and  not a;
run;

proc print data=capstone; where folior="BI0014"; run;

/* BK: So, it turns out that there are some 606 IDs which are in the capstone 
(Luis's dataset)but not in the intersected Mother's IS+with AGEB with NDVI (cohortall_NDVI2) 
and  they are listed in the cohortall_NDVIf2 and there are
713 which are in capstone but not in the cohortall_NDVI2 
they are listed in the cohortall_NDVIf3 */ 




























/*BK: very important: Removing spaces and after the folio ID variable */ 
data cohortall_NDVI;
set cohortall_NDVI;
folior = strip(folio);
run;

proc contents data=cohortall_NDVI; run; 
proc print data=cohortall_NDVI; var folio folio1 fid_1 fid_cohort; run;
proc print data=prefix; var var2 folior; run;

/*BK: renaming var2 to folio3 to be the unique common identifier between prefix and cohortall_ndvi*/ 
data prefix;
set prefix (rename=(var2=folio));
run;


data cohortall_NDVI2;
merge cohortall_NDVI prefix;
by folio;
run;
* A permanent copy; 
data capstone.cohortall_NDVI2;
set  cohortall_NDVI2;
run;
/* 1991 Ready to merge with capstone(health data) */ 

proc print data=cohortall_NDVI2; var folio; run;
proc contents data=capstone;  run; 


data cohortall_NDVI2;
capstone.cohortall_NDVI2;
run; 

proc contents data=capstone1;run;
proc contents data=cohortall_NDVI2;run;


data capstone1;
set capstone;
folio_new = strip(folio2);
run;

data cohortall_NDVI3;
set cohortall_NDVI2;
folio_new = strip(folio);
run;

proc sort data=capstone1; by folio_new;run;
proc sort data=cohortall_NDVI3; by folio_new;run;


proc print data=capstone; var folior;run;
proc print  data=cohortall_NDVI2; var folior;run;


proc sort data=capstone; by folio2;run;
proc sort data=cohortall_NDVI2; by folio;run;

data cohortall_NDVIf;
merge cohortall_NDVI2(in=a rename=(folio=folio2)) capstone(in=b);
by folio2;
if a and b;
run;

data cohortall_NDVIf1;
merge cohortall_NDVI2(in=a rename=(folio=folio2)) capstone(in=b);
by folio2;
if a and not b;
run;



* IN cohort all but not in capstone;
data cohortall_NDVIf2;
merge cohortall_NDVI2(in=a) capstone(in=b);
by folior;
if a and  not b;
run;

* In capstone but not in cohortall;
data cohortall_NDVIf3;
merge cohortall_NDVI2(in=a) capstone(in=b);
by folior;
if b and  not a;
run;

proc print data=capstone; where folior="BI0014"; run;

/* BK: So, it turns out that there are some 606 IDs which are in the capstone 
(Luis's dataset)but not in the intersected Mother's IS+with AGEB with NDVI (cohortall_NDVI2) 
and  they are listed in the cohortall_NDVIf2 and there are
713 which are in capstone but not in the cohortall_NDVI2 
they are listed in the cohortall_NDVIf3 */ 


