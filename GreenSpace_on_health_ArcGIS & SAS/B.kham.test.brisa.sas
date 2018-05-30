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
proc contents data=capstone.cohortall_NDVI2;
run;


data work.cohortall_NDVI2; 
set capstone.cohortall_NDVI2;
Proyecto=substr(folior,1,2);
folio_num=1*substr(folior,3,6);
folio2=cats(of Proyecto folio_num);
ndvi_mean=mean;
ndvi_std=std;
if folio_num=. then delete ; *this deletest the row with PL0223_b, will need to figure out what _b means;
keep folio2 ndvi_mean ndvi_std updated txtvalue;
run;

proc sort data=work.cohortall_NDVI2;
by folio2 descending updated;
run;

data cohortall_ndvi2_nodups capstone.repeats;
set cohortall_ndvi2;
where TxtValue ne "";
by folio2;
if first.folio2 then output cohortall_ndvi2_nodups ;
if ~first.folio2 then output capstone.repeats;  *kicks out repeated addresses, will need to figure out later why there are repeated addresses;
run;

  

proc sort data=capstone; by folio2;run;
 

proc sort data= cohortall_ndvi2_nodups; by folio2;run;

  
/* BK: So, it turns out that there are some 606 IDs which are in the capstone 
(Luis's dataset)but not in the intersected Mother's IS+with AGEB with NDVI (cohortall_NDVI2) 
and  they are listed in the cohortall_NDVIf2 and there are
713 which are in capstone but not in the cohortall_NDVI2 
they are listed in the cohortall_NDVIf3 */ 

/* Importing the road density into SAS
PROC IMPORT OUT= work.roaddens
            DATAFILE= "M:\Private\w15\Capstone\Babak\Results\final datasets\roads_sum.xlsx" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN; */ 

data capstone.roaddens;
set work.roaddens;
run;

data capstone.educagebdata;
set educagebdata;
run;

data cohortall;
set capstone.cohortall;
proyecto=substr(folio,1,2); *takes the first two letters;
folio_num=1*substr(folio,3,8); *takes letters starting from the 3rd to the 8th;
if proyecto=" " then proyecto="C1";
folio2=cats(of Proyecto folio_num);
run;

proc sort data=  cohortall;
by agebid;
run;

proc sort data=roaddens;
by agebid;
run;

data cohortall_dens;
merge  cohortall (in=a  keep= folio2 agebid TxtValue updated) roaddens (keep=agebid ageb_area road_density);
by agebid;
if a;
run;
proc means data=cohortall_dens;
var road_density;
run;


proc sort data=cohortall_dens;
by folio2 descending updated;
run;

data cohortall_dens_nodups capstone.repeats_dens;
set cohortall_dens;
by folio2;
if first.folio2 then output cohortall_dens_nodups ;
if ~first.folio2 then output capstone.repeats_dens;  *kicks out repeated addresses, will need to figure out later why there are repeated addresses;
run;

proc sort data=  cohortall_dens_nodups;
by txtvalue;
run;

proc sort data=capstone.educagebdata;
by txtvalue;
run;
proc sort data=cohortall_ndvi2_nodups;
by txtvalue;
run;

data cohortall_dens_educ_ndvi ;
merge cohortall_dens_nodups(in=a) capstone.educagebdata(in=b drop = f6 f7 f8)
      cohortall_ndvi2_nodups(in=c)  ;
by txtvalue;
if a  or c; 
 run;
 

proc sort data=cohortall_dens_educ_ndvi ;
by folio2;
run;

data cohortall_dens_educ_ndvi_nodups;
set  cohortall_dens_educ_ndvi ;
by folio2;
if ~first.folio2 then delete;
run;
proc sort data=cohortall_dens_educ_ndvi_nodups;
by folio2;
run;

proc sort data=capstone;
by folio2;
run;
  
data capstone.Clin_dens_educ_ndvi_nodups_final;
merge cohortall_dens_educ_ndvi_nodups (in=a ) capstone(in=b );
by folio2;
if a and b;
run;
* IN cohort (GIS) data all but not in capstone (clinical data), N=5;
data  Clin_dens_educ_ndvi_nodups_2;
merge cohortall_dens_educ_ndvi_nodups (in=a ) capstone(in=b );
by folio2;
if a and  not b;
run;

* In capstone(clinical) but not in cohortall (GIS), N=189;
data Clin_dens_educ_ndvi_nodups_3;
merge cohortall_dens_educ_ndvi_nodups (in=a ) capstone(in=b );
by folio2;
if b and  not a;
run;
 
data capstone.final;
set capstone.Clin_dens_educ_ndvi_nodups_final;
run;

proc means data=capstone.Clin_dens_educ_ndvi_nodups_final;
run;
