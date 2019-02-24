data churn;
infile '/folders/myfolders/HW4/Churn_telecom.csv' DLM = ',' firstobs = 2 dsd missover;
INPUT rev_Mean mou_Mean totmrc_Mean da_Mean ovrmou_Mean ovrrev_Mean vceovr_Mean datovr_Mean roam_Mean	rev_Range mou_Range	totmrc_Range da_Range ovrmou_Range	ovrrev_Range vceovr_Range datovr_Range	roam_Range	change_mou	change_rev	drop_vce_Mean	drop_dat_Mean	blck_vce_Mean	blck_dat_Mean	unan_vce_Mean	unan_dat_Mean	plcd_vce_Mean	plcd_dat_Mean	recv_vce_Mean	recv_sms_Mean	comp_vce_Mean	comp_dat_Mean	custcare_Mean	ccrndmou_Mean	cc_mou_Mean	inonemin_Mean	threeway_Mean	mou_cvce_Mean	mou_cdat_Mean	mou_rvce_Mean	owylis_vce_Mean	mouowylisv_Mean	iwylis_vce_Mean	mouiwylisv_Mean	peak_vce_Mean	peak_dat_Mean	mou_peav_Mean	mou_pead_Mean	opk_vce_Mean	opk_dat_Mean	mou_opkv_Mean	mou_opkd_Mean	drop_blk_Mean	attempt_Mean	complete_Mean	callfwdv_Mean	callwait_Mean	drop_vce_Range	drop_dat_Range	blck_vce_Range	blck_dat_Range	unan_vce_Range	unan_dat_Range	plcd_vce_Range	plcd_dat_Range	recv_vce_Range	recv_sms_Range	comp_vce_Range	comp_dat_Range	custcare_Range	ccrndmou_Range	cc_mou_Range	inonemin_Range	threeway_Range	mou_cvce_Range	mou_cdat_Range	mou_rvce_Range	owylis_vce_Range	mouowylisv_Range	iwylis_vce_Range	mouiwylisv_Range	peak_vce_Range	peak_dat_Range	mou_peav_Range	mou_pead_Range	opk_vce_Range	opk_dat_Range	mou_opkv_Range	mou_opkd_Range	drop_blk_Range	attempt_Range	complete_Range	callfwdv_Range	callwait_Range	churn	months	uniqsubs	actvsubs	crtcount	new_cell $	crclscod $	asl_flag $	rmcalls	rmmou	rmrev totcalls totmou	totrev	adjrev	adjmou	adjqty	avgrev	avgmou	avgqty	avg3mou	avg3qty	avg3rev	avg6mou	avg6qty	avg6rev	REF_QTY	tot_ret	tot_acpt prizm_social_one $	div_type $ csa $ area  $ dualband $ refurb_new $	hnd_price pre_hnd_price	phones	last_swap	models	hnd_webcap $ truck	mtrcycle rv	occu1 ownrent $ lor	dwlltype $ marital $ mailordr $ age1	age2	wrkwoman $ mailresp $ children $ adults	infobase $ income numbcars cartype	$ HHstatin $ mailflag $ solflag $ dwllsize $ forgntvl educ1	proptype $ pcowner $ ethnic $ 	kid0_2 $ kid3_5 $ kid6_10 $ kid11_15 $ kid16_17 $ creditcd $ car_buy $ retdays	eqpdays	Customer_ID;
FORMAT format last_swap date11.;
PROC PRINT DATA = churn (obs = 20);RUN;

PROC MEANS NMISS DATA = churn;RUN;

/*PROC FREQ data = churn; table car_buy new_cell crclscod asl_flag prizm_social_one div_type csa area dualband refurb_new hnd_webcap ownrent dwlltype marital mailordr wrkwoman mailresp children infobase cartype HHstatin mailflag solflag dwllsize proptype pcowner ethnic kid0_2 kid3_5 kid6_10 kid11_15 kid16_17 creditcd car_buy ;RUN;

PROC FREQ data = churn nlevels;RUN;
*/

/* Check the missing , not missing frequency for each column*/
PROC FORMAT;
	value $missfmt ' '='Missing' other='Not Missing';
RUN;

PROC FREQ DATA=churn;
FORMAT _CHAR_ $missfmt.;
TABLES _CHAR_ / missing missprint nocum nopercent;
RUN;

/* Drop columns where missing values are more than 60% */
data churn1;
set churn;
drop mailordr wrkwoman div_type proptype pcowner mailflag solflag mailresp cartype crtcount rmcalls children rmmou rmrev REF_QTY tot_ret tot_acpt pre_hnd_price last_swap occu1 numbcars educ1 retdays;
RUN;

/* delete rows with missing values for variables to be considered */
data churn2;
set churn1;
if change_mou = '.' then delete;
RUN; 

PROC MEANS NMISS DATA = churn2;RUN;

PROC PRINT data = churn2 (obs = 20);RUN;

PROC MEANS data = churn2; class churn;OUTPUT OUT=churnmeans2;RUN;
PROC PRINT data = churnmeans2;RUN;
proc export data = churnmeans2 outfile="/folders/myfolders/HW4/means2.csv" dbms=dlm replace;
delimiter= ',';
run;

PROC CORR data = churn2; Var roam_Mean roam_Range change_mou change_rev drop_dat_Mean blck_dat_Mean custcare_Mean threeway_Mean mou_opkd_Mean callfwdv_Mean blck_dat_Range;RUN;

##PROC FREQ data = churn2; table churn*new_cell churn*crclscod churn*asl_flag churn*prizm_social_one churn*csa churn*area churn*dualband churn*refurb_new churn*hnd_webcap churn*ownrent churn*dwlltype churn*marital churn*infobase churn*HHstatin churn*dwllsize churn*ethnic churn*kid0_2 churn*kid3_5 churn*kid6_10 churn*kid11_15 churn*kid16_17 churn*creditcd churn*car_buy / chisq;RUN;

PROC FREQ data = churn2; table area;RUN;
PROC FREQ data = churn2; table ethnic;RUN;
PROC Means data = churn2; var age1;RUN;
PROC FREQ data = churn2; table age1;RUN;
PROC FREQ data = churn2; table income;RUN;
PROC FREQ data = churn2; table asl_flag;RUN;

data churn3;
set churn2;
/* Reference is asl_flag = N */
if asl_flag = 'Y' then aslY = 1; else aslY = 0;

/*imputing mean value for the missing values */
if age1 = '.' then age1 = 31;
/* Refernece is income = 6 */
if income = '.' then income = 'UNK';
if income = 'UNK' then inUNK = 1;else inUNK = 0;
if income = 1 then inc1 = 1;else inc1 = 0;
if income = 2 then inc2 = 1;else inc2 = 0;
if income = 3 then inc3 = 1;else inc3 = 0;
if income = 4 then inc4 = 1;else inc4 = 0;
if income = 5 then inc5 = 1;else inc5 = 0;
if income = 7 then inc7 = 1;else inc7 = 0;
if income = 8 then inc8 = 1;else inc8 = 0;
if income = 9 then inc9 = 1;else inc9 = 0;
/* Reference is ethic = N*/
if ethnic = '.' then ethic = 'UNK';
if ethic = 'B' then et_B = 1; else et_B = 0;
if ethic = 'C' then et_C = 1;else et_C = 0;
if ethic = 'D' then et_A = 1; else et_D = 0;
if ethic = 'F' then et_F = 1; else et_F = 0;
if ethic = 'G' then et_G = 1; else et_G = 0;
if ethic = 'H' then et_H = 1; else et_H = 0;
if ethic = 'I' then et_I = 1; else et_I = 0;
if ethic = 'J' then et_J = 1; else et_J = 0;
if ethic = 'M' then et_M = 1; else et_M = 0;
if ethic = 'O' then et_O = 1; else et_O = 0;
if ethic = 'P' then et_P = 1; else et_P = 0;
if ethic = 'R' then et_R = 1; else et_R = 0;
if ethic = 'S' then et_S = 1; else et_S = 0;
if ethic = 'U' then et_U = 1; else et_U = 0;
if ethic = 'X' then et_X = 1; else et_X = 0;
if ethic = 'Z' then et_E = 1; else et_Z = 0;
if ethic = 'UNK' then et_UNK = 1; else et_UNK = 0;
/* Reference is area = New York */
if area = '.' then area = 'UNK';
if area = 'UNK' then ar_UNK = 1; else ar_UNK = 0;
if area = 'ATLANTIC' then ar_AT = 1; else ar_AT = 0;
if area = 'CALIFORN' then ar_CA = 1; else ar_CA = 0;
if area = 'CENTRAL/' then ar_CE = 1; else ar_CE = 0;
if area = 'CHICAGO' then ar_CH = 1; else ar_CH = 0;
if area = 'DALLAS A' then ar_DA = 1; else ar_DA = 0;
if area = 'DC/MARYL' then ar_DC = 1; else ar_DC = 0;
if area = 'GREAT LA' then ar_GR = 1; else ar_GR = 0;
if area = 'HOUSTON' then ar_HO = 1; else ar_HO = 0;
if area = 'LOS ANGE' then ar_LA = 1; else ar_LA = 0;
if area = 'MIDWEST' then ar_MW = 1; else ar_MW = 0;
if area = 'NEW ENGL' then ar_NE = 1; else ar_NE = 0;
if area = 'NORTH FL' then ar_NFL = 1; else ar_NFL = 0;
if area = 'NORTHWES' then ar_NW = 1; else ar_NW = 0;
if area = 'OHIO ARE' then ar_OH = 1; else ar_OH = 0;
if area = 'PHILADEL' then ar_PH = 1; else ar_PH = 0;
if area = 'SOUTH FL' then ar_SFL = 1; else ar_SFL = 0;
if area = 'SOUTHWES' then ar_SW = 1; else ar_SW = 0;
if area = 'TENNESSE' then ar_TN = 1; else ar_TN = 0;
PROC PRINT data = churn3 (obs = 10);RUN; 


/* Variables to be considered for logit : roam_Mean change_mou drop_dat_Mean blck_dat_Mean custcare_Mean threeway_Mean mou_opkd_Mean callfwdv_Mean*/

PROC surveyselect data = churn3
method = SRS seed = 1001 outall OUT = all samprate= 0.5; RUN;

/*PROC PRINT data = all(obs = 20); RUN; */

data trainset;
set all;
if selected = 1 then delete;RUN;
/*PROC PRINT data = trainset;RUN;*/

data testset;
set all;
if selected = 0 then delete;RUN;

PROC CORR data = churn3; var attempt_Mean	complete_Mean
;RUN;

PROC LOGISTIC data = trainset DESCENDING;
model churn = roam_Mean change_mou drop_dat_Mean blck_dat_Range custcare_Mean threeway_Mean mou_opkd_Mean callfwdv_Mean; RUN;


PROC LOGISTIC data = trainset DESCENDING;
model churn = totmrc_Mean roam_Mean ovrrev_Mean eqpdays complete_Mean change_mou drop_vce_Mean months uniqsubs custcare_Mean uniqsubs*custcare_Mean threeway_Mean mou_opkd_Mean; 
score out = telecom_train_score outroc = roc;RUN;


PROC LOGISTIC data = testset DESCENDING;
model churn = inc1 inc7 age1 ar_DC	ar_HO ar_MW	ar_NW ar_OH ar_SFL ar_TN totmrc_Mean roam_Mean ovrrev_Mean eqpdays complete_Mean change_mou drop_vce_Mean months uniqsubs actvsubs custcare_Mean uniqsubs*custcare_Mean threeway_Mean mou_opkd_Mean;
score out = telecom_test_score outroc = roc;RUN;


PROC LOGISTIC data = trainset DESCENDING;
model churn = age1 ar_DC ar_MW	ar_NW ar_OH ar_SFL totmrc_Mean roam_Mean ovrrev_Mean eqpdays complete_Mean change_mou drop_vce_Mean months uniqsubs actvsubs custcare_Mean uniqsubs*custcare_Mean threeway_Mean;
/*score out = telecom_test_score outroc = roc */;RUN;

/*Final Model*/
PROC LOGISTIC data = trainset DESCENDING OUTmodel=model_1 plots(only)=(roc(id=obs) effect) ;
model churn = aslY age1 ar_DC ar_MW ar_NW ar_OH ar_SFL totmrc_Mean roam_Mean ovrrev_Mean eqpdays complete_Mean change_mou drop_vce_Mean months uniqsubs actvsubs custcare_Mean uniqsubs*custcare_Mean threeway_Mean;
output out = prediction p=new_prediction;RUN;

PROC PRINT data = roc (obs = 10);RUN;

PROC PRINT data=prediction (obs=100);
run;


data trainset_eval;
set prediction;
if new_prediction > 0.5 then pred_churn=1;
if new_prediction <= 0.5 then pred_churn=0;
keep churn new_prediction pred_churn;
run;

data trainset_results;
set trainset_eval;
count_00=0; count_01=0; count_11=0; count_10=0;
if churn = 0 and pred_churn = 0 then count_00 = count_00 + 1;
if churn = 1 and pred_churn = 1 then count_11 = count_11 + 1;
if churn = 0 and pred_churn = 1 then count_01 = count_01 + 1;
if churn = 1 and pred_churn = 0 then count_10 = count_10 + 1;
run;

proc export data = trainset_results outfile="/folders/myfolders/HW4/results1.csv" dbms=dlm replace;
delimiter= ',';
run;

proc logistic descending INmodel=model_1;
score data= testset out= testset_eval;
run;

PROC SGPLOT data = roc;
scatter y = _sensit_ x = _1MSPEC_;
run;
/*
proc rank data  = telecom_test_score out = decile groups = 10 ties = mean;
var P_1;
ranks decile;
run;

proc sort data = decile;
by descending P_1;
run;

proc means n data = decile;
class decile;
var decile;
run;
proc means n data = decile;
class decile;
var churn;
where churn = 1;
run;

*/



