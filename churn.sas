data churn;
infile 'H:\Homework4-group assignment\Churn_telecom.csv' DLM = ',' firstobs = 2 dsd missover;
INPUT rev_Mean mou_Mean totmrc_Mean da_Mean ovrmou_Mean ovrrev_Mean vceovr_Mean datovr_Mean roam_Mean rev_Range mou_Range totmrc_Range da_Range ovrmou_Range ovrrev_Range vceovr_Range datovr_Range roam_Range change_mou change_rev drop_vce_Mean drop_dat_Mean blck_vce_Mean blck_dat_Mean unan_vce_Mean unan_dat_Mean plcd_vce_Mean plcd_dat_Mean recv_vce_Mean recv_sms_Mean comp_vce_Mean comp_dat_Mean custcare_Mean ccrndmou_Mean cc_mou_Mean inonemin_Mean threeway_Mean mou_cvce_Mean mou_cdat_Mean mou_rvce_Mean owylis_vce_Mean mouowylisv_Mean iwylis_vce_Mean mouiwylisv_Mean peak_vce_Mean peak_dat_Mean mou_peav_Mean mou_pead_Mean opk_vce_Mean opk_dat_Mean mou_opkv_Mean mou_opkd_Mean drop_blk_Mean attempt_Mean complete_Mean callfwdv_Mean callwait_Mean drop_vce_Range drop_dat_Range blck_vce_Range  blck_dat_Range unan_vce_Range unan_dat_Range plcd_vce_Range plcd_dat_Range recv_vce_Range recv_sms_Range comp_vce_Range comp_dat_Range custcare_Range ccrndmou_Range cc_mou_Range inonemin_Range threeway_Range mou_cvce_Range mou_cdat_Range mou_rvce_Range owylis_vce_Range mouowylisv_Range iwylis_vce_Range mouiwylisv_Range peak_vce_Range peak_dat_Range mou_peav_Range mou_pead_Range opk_vce_Range opk_dat_Range mou_opkv_Range mou_opkd_Range drop_blk_Range attempt_Range complete_Range callfwdv_Range callwait_Range churn months uniqsubs actvsubs crtcount new_cell $ crclscod $ asl_flag $ rmcalls rmmou rmrev totcalls totmou totrev adjrev adjmou adjqty  avgrev avgmou avgqty avg3mou avg3qty avg3rev avg6mou avg6qty avg6rev REF_QTY tot_ret tot_acpt prizm_social_one $ div_type $ csa $ area $ dualband $ refurb_new $ hnd_price pre_hnd_price phones last_swap models hnd_webcap $ truck mtrcycle rv occu1 ownrent $ lor dwlltype $ marital $ mailordr $ age1 age2 wrkwoman $ mailresp $ children $ adults infobase $ income numbcars cartype $ HHstatin $ mailflag $ solflag $ dwllsize $ forgntvl educ1 proptype $ pcowner $ ethnic $ kid0_2 $ kid3_5 $ kid6_10 $ kid11_15 $ kid16_17 $ creditcd $ car_buy $ retdays eqpdays Customer_ID;
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


PROC MEANS data = churn1; class churn;OUTPUT OUT=churnmeans;RUN;
PROC PRINT data = churnmeans;RUN;
proc export data = churnmeans outfile="/folders/myfolders/HW4/means1.csv" dbms=dlm replace;
delimiter= ',';
run;

PROC CORR data = churn1; Var roam_Mean roam_Range change_mou change_rev drop_dat_Mean blck_dat_Mean custcare_Mean threeway_Mean mou_cdat_Mean mou_opkd_Mean callfwdv_Mean blck_dat_Range;RUN;

PROC SURVEYSELECT data=churn1
method=srs n=50000 out=churnSRS;
run;

Proc logistic data=churnSRS;
model churn = roam_Mean change_rev drop_dat_Mean blck_dat_Mean custcare_Mean threeway_Mean mou_cdat_Mean callfwdv_Mean;
run;
