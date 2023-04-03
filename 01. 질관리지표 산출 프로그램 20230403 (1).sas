libname inci 'E:\04.내부요청\박은혜T 요청\R shiny 웹통계 구성\03. ca DB에 변수추가 수정'; 

%let fyear='1999';
%let lyear='2020';

*  ASR National 계산시 ;
%let nyear='2020';


data cancer ; set inci.inci9920_sample ;

*if substr(icd_10,1,1)^='C' then delete;
 *if substr(icd_10,1,3)='C44' then delete;
if &fyear <= substr(fdx,1,4) <= &lyear;

ind=1;
fage=age*1;

t= substr(icd_10,1,3) ;
    
/* icd-10 코드 카테고리 생성 */
/* 암종군을 변경하려면 여기서 변경함
  여기서 암종군을 변경할 경우, 대장암 자료 생성, 암등록자료가 0인 자료를 
  만드는 곳을 수정해야한다. */
/* icd-10 코드 카테고리 생성 */
length tgroup $18.;

     if 'C00' <= t <= 'C14' then tgroup='01. C00-C14'; 
else if t='C15' then tgroup='02. C15';
else if t='C16' then tgroup='03. C16';             
else if 'C18' <= t <= 'C20' then tgroup='04. C18-C20';
else if t='C22' then tgroup='05. C22';    
else if 'C23' <= t <= 'C24' then tgroup='06. C23-C24';    
else if t='C25' then tgroup='07. C25';
else if t='C32' then tgroup='08. C32';             
else if 'C33' <= t <= 'C34' then tgroup='09. C33-C34';      
else if t='C50' then tgroup='10. C50';
else if t='C53' then tgroup='11. C53';            
else if t='C54' then tgroup='12. C54';
else if  t = 'C56' then tgroup='13. C56';
else if t='C61' then tgroup='14. C61';
else if t='C62' then tgroup='15. C62';  
else if t = 'C64' then tgroup='16. C64'; 
else if t='C67' then tgroup='17. C67';
else if 'C70' <= t <= 'C72' then tgroup='18. C70-C72';
else if t='C73' then tgroup='19. C73';            
else if t='C81' then tgroup='20. C81';            
else if 'C82' <= t <= 'C86' or t='C96' then tgroup='21. C82-C86,C96';
else if t='C90' then tgroup='22. C90';
else if 'C91' <= t <= 'C95' then tgroup='23. C91-C95';
else tgroup='24. All other ca';

* 초진년도;
year=substr(fdx,1,4)*1;

*** age;
     if 0 <=fage<= 4  then cage1=1;
else if 5 <=fage<= 9  then cage1=2;
else if 10<=fage<= 14 then cage1=3;
else if 15<=fage<= 19 then cage1=4;
else if 20<=fage<= 24 then cage1=5;
else if 25<=fage<= 29 then cage1=6;
else if 30<=fage<= 34 then cage1=7;
else if 35<=fage<= 39 then cage1=8;
else if 40<=fage<= 44 then cage1=9;
else if 45<=fage<= 49 then cage1=10;
else if 50<=fage<= 54 then cage1=11;
else if 55<=fage<= 59 then cage1=12;
else if 60<=fage<= 64 then cage1=13;
else if 65<=fage<= 69 then cage1=14;
else if 70<=fage<= 74 then cage1=15;
else if 75<=fage<= 79 then cage1=16;

*1993년 이전 연앙인구는  80세+ 이므로;
if year <= 1993 then do;
if fage>=80     then cage1=17;
end;

if year >= 1994 then do;
if 80<=fage<= 84 then cage1=17;
if 85 <= fage < 999      then cage1=18;
end;

* age missing이 있을때 보정하기 위해;
if cage1=.  then missage=1;else missage=0;

*지역;
length region $8.0;

        if substr(adrcode,1,2) ='01' then region='01서울';
else if substr(adrcode,1,2) ='02' then region='02부산';
else if substr(adrcode,1,2) ='03' then region='03대구';
else if substr(adrcode,1,2) ='04' then region='04인천';
else if substr(adrcode,1,2) ='16' then region='05광주';
else if substr(adrcode,1,2) ='17' then region='06대전';
else if substr(adrcode,1,2) ='18' then region='07울산';
else if substr(adrcode,1,2) ='19' then region='08세종';
else if substr(adrcode,1,2) ='05' then region='09경기';
else if substr(adrcode,1,2) ='06' then region='10강원';
else if substr(adrcode,1,2) ='07' then region='11충북';
else if substr(adrcode,1,2) ='08' then region='12충남';
else if substr(adrcode,1,2) ='09' then region='13전북';
else if substr(adrcode,1,2) ='10' then region='14전남';
else if substr(adrcode,1,2) ='11' then region='15경북';
else if substr(adrcode,1,2) ='12' then region='16경남';
else if substr(adrcode,1,2) ='13' then region='17제주';
else region='18모름';

if method ='0' then dco=1 ; else dco=0 ; 
if method >='5' then mv =1 ; else mv =0 ; 

if substr(tcode,1,3) in ('C26', 'C39', 'C48', 'C76', 'C80' ) then psu='1' ; else psu='0'; 
if age ='' then age_unk ='1' ; else age_unk='0'; 

run ; 


data  cancer1 ; set cancer ; if substr(Fdx,1,4) ='2020' ; run; 


* 원발암종 불명률 (psu) ;
proc freq data=cancer1 ; tables psu*sex /nopercent norow nocol  ; run; 
/*
psu			1				  2			  합계 
0 	  	     314         286	      600 
1				       2 		         3 		        5  
합계	     316         289          605 
 */

* 연령 미상률 (age_unk) ;
proc freq data=cancer1 ; tables age_unk*sex /nopercent norow nocol  ; run; 
/*
age_unk			1				 2			  합계 
0 	       	         316        289	          605 
1                         -              -                 -
합계	             316        289           605 
 */

* 사망진단서에서만 암으로 확인 가능한 환자의 분율 (dco); 
proc freq data=cancer1 ; tables dco*sex /nopercent norow nocol  ; run; 
/*
dco			1				  2			  합계 
0 	  	     313         285	      698 
1				       3 		         4 		        7  
합계	     316         289          605 
*/

*현미경적 확진율 (mv) ;
proc freq data=cancer1 ; tables mv*sex /nopercent norow nocol  ; run; 
/*
mv 			1			  2		  합계 
0 	  	     26         20	         46
1		      290 	 269		  559
합계	  316      289        605 
  */



* 현미경적 확진율 세부암종별 (hv) ; 
proc summary data=cancer1;
var ind;
class year  sex  tgroup mv ; 
output out=hv (drop=_type_ _freq_) sum(ind)=count;run; 
data hv ; set hv ;
if sex ='' then sex='0' ; 
if mv=. then mv =9; 
if tgroup ='' then tgroup ='00. All cancer' ; 
if year ='' then delete ; 
run; 

data hv_0 ; set hv ; if mv =0 ; hv_0 = count ; drop count  mv ; run; 
data hv_1 ; set hv ; if mv =1 ; hv_1 = count ; drop count  mv ; run; 
data hv_t ; set hv ;  if mv =9 ; hv_t = count ; drop count  mv ; run; 
proc sort data = hv_0 ; by year sex tgroup ; run; 
proc sort data = hv_1 ; by year sex tgroup ; run; 
proc sort data = hv_t ; by year sex tgroup ; run; 

data hv ; merge hv_0 hv_1 hv_t; by sex tgroup ; run; 
data hv ; set hv ; hv_p = hv_1 /hv_t * 100 ; 
hv_p = round(hv_p, 0.1) ;
run;
proc sql ;
create table hv as 
select year, sex, tgroup, hv_0 , hv_1, hv_t, hv_p  from hv 
order by sex,  tgroup ;
quit ; 

proc print data=hv ; run; 



* DCO ; 
proc summary data=cancer1;
var ind;
class year  sex  tgroup dco ; 
output out=dco (drop=_type_ _freq_) sum(ind)=count;run; 
data dco ; set dco ;
if sex ='' then sex='0' ; 
if dco=. then dco =9; 
if tgroup ='' then tgroup ='00. All cancer' ; 
if year ='' then delete ; 
run; 

data dco_0 ; set dco ; if dco =0 ; dco_0 = count ; drop count  dco ; run; 
data dco_1 ; set dco ; if dco =1 ; dco_1 = count ; drop count  dco ; run; 
data dco_t ; set dco ;  if dco =9 ; dco_t = count ; drop count  dco ; run; 
proc sort data = dco_0 ; by year sex tgroup ; run; 
proc sort data = dco_1 ; by year sex tgroup ; run; 
proc sort data = dco_t ; by year sex tgroup ; run; 

data dco ; merge dco_0 dco_1 dco_t; by sex tgroup ; run; 
data dco ; set dco ; dco_p = dco_1 /dco_t * 100 ; 
dco_p = round(dco_p, 0.1) ;
run;
proc sql ;
create table dco as 
select year, sex, tgroup, dco_0 , dco_1, dco_t, dco_p  from dco 
order by sex,  tgroup ;
quit ; 

proc print data=dco ; run; 



* 질관리 지표  M/I%;
libname death 'E:\04.내부요청\박은혜T 요청\R shiny 웹통계 구성\03. ca DB에 변수추가 수정';
* 1) 사망자수 구하기; 
data death ;
set death.death_sample ;
 fdx =dregdate ; 
 ind=1 ;
if  substr(fdx,1,4) = '2020' ;
* 사망주소지가 외국인 자료 삭제; 
if substr(dadr,1,1) in ('8','0')  then delete;
if (substr(sain,1,1)='C' or substr(sain,1,3) in ('D45', 'D46')  or sain in ('D471', 'D473', 'D474','D475','D477') )  ;
 icd_10 =icd10 ;
if sex in ('1','2') ;

year =substr(Fdx,1,4) *1; 
t= substr(icd_10,1,3) ;
    
/* icd-10 코드 카테고리 생성 */
/* 암종군을 변경하려면 여기서 변경함
  여기서 암종군을 변경할 경우, 대장암 자료 생성, 암등록자료가 0인 자료를 
  만드는 곳을 수정해야한다. */
/* icd-10 코드 카테고리 생성 */
length tgroup $18.;

     if 'C00' <= t <= 'C14' then tgroup='01. C00-C14'; 
else if t='C15' then tgroup='02. C15';
else if t='C16' then tgroup='03. C16';             
else if 'C18' <= t <= 'C20' then tgroup='04. C18-C20';
else if t='C22' then tgroup='05. C22';    
else if 'C23' <= t <= 'C24' then tgroup='06. C23-C24';    
else if t='C25' then tgroup='07. C25';
else if t='C32' then tgroup='08. C32';             
else if 'C33' <= t <= 'C34' then tgroup='09. C33-C34';      
else if t='C50' then tgroup='10. C50';
else if t='C53' then tgroup='11. C53';            
else if t='C54' then tgroup='12. C54';
else if  t = 'C56' then tgroup='13. C56';
else if t='C61' then tgroup='14. C61';
else if t='C62' then tgroup='15. C62';  
else if t = 'C64' then tgroup='16. C64'; 
else if t='C67' then tgroup='17. C67';
else if 'C70' <= t <= 'C72' then tgroup='18. C70-C72';
else if t='C73' then tgroup='19. C73';            
else if t='C81' then tgroup='20. C81';            
else if 'C82' <= t <= 'C86' or t='C96' then tgroup='21. C82-C86,C96';
else if t='C90' then tgroup='22. C90';
else if 'C91' <= t <= 'C95' then tgroup='23. C91-C95';
else tgroup='24. All other ca';

        if substr(adrcode,1,2) ='01' then region='01서울';
else if substr(adrcode,1,2) ='02' then region='02부산';
else if substr(adrcode,1,2) ='03' then region='03대구';
else if substr(adrcode,1,2) ='04' then region='04인천';
else if substr(adrcode,1,2) ='16' then region='05광주';
else if substr(adrcode,1,2) ='17' then region='06대전';
else if substr(adrcode,1,2) ='18' then region='07울산';
else if substr(adrcode,1,2) ='19' then region='08세종';
else if substr(adrcode,1,2) ='05' then region='09경기';
else if substr(adrcode,1,2) ='06' then region='10강원';
else if substr(adrcode,1,2) ='07' then region='11충북';
else if substr(adrcode,1,2) ='08' then region='12충남';
else if substr(adrcode,1,2) ='09' then region='13전북';
else if substr(adrcode,1,2) ='10' then region='14전남';
else if substr(adrcode,1,2) ='11' then region='15경북';
else if substr(adrcode,1,2) ='12' then region='16경남';
else if substr(adrcode,1,2) ='13' then region='17제주';
else region='18모름';
  ; run; 
  
*2) 사망/발생비;
proc freq data=death ; tables tgroup* sex/nopercent nocol norow ; run ; 
*			1     	 2 	   합계 
      515    317       832
  ;
 
proc freq data=cancer1 ; tables tgroup* sex/nopercent nocol norow ; run ; 
*			1     	 2 	   합계 
      631    579      1210
  ;

* 발생자료  ; 
proc summary data=cancer1;
var ind;
class year  sex  tgroup ; 
output out=regi  (drop=_type_ _freq_) sum(ind)=regi;run; 
data regi ; set regi ;
if sex ='' then sex='0' ; 
if tgroup ='' then tgroup ='00. All cancer' ; 
if year ='' then delete ; 
run; 

* 사망자료   ; 
proc summary data=death;
var ind;
class year  sex  tgroup ; 
output out=dcn  (drop=_type_ _freq_) sum(ind)=dcn;run; 
data dcn ; set dcn ;
if sex ='' then sex='0' ; 
if tgroup ='' then tgroup ='00. All cancer' ; 
if year ='' then delete ; 
run; 

proc sort data=regi ; by year sex tgroup ; run; 
proc sort data=dcn ; by year sex tgroup ; run; 

data mi ; merge dcn regi ; by year sex tgroup ; run; 
data mi ; set mi ; mi = dcn / regi * 100 ; 
mi = round(mi, 0.1) ;run; 


proc sort data=mi ; by year sex tgroup ; run; 
proc sort data=dco ; by year sex tgroup ; run; 
proc sort data=hv  ; by year sex tgroup ; run; 

data total ; merge  dco hv mi ; by year sex tgroup ; run; 
data temp ; 
length tgroup $20.;
 do tgroup='01. C00-C14','02. C15','03. C16','04. C18-C20','05. C22','06. C23-C24','07. C25','08. C32','09. C33-C34','10. C50'
				,'11. C53','12. C54','13. C56','14. C61','15. C62','16. C64', '17. C67','18. C70-C72','19. C73','20. C81'
				,'21. C82-C86,C96','22. C90','23. C91-C95','24. All other ca','00. All cancer';
 do sex='0','1','2';
 do year = &lyear  *1 ;  
 output;
end;end;end;
run; 

proc sort data=total; by year sex tgroup;
proc sort data=temp; by year sex tgroup;

data total;
merge temp(in=a) total(in=b);
by year sex tgroup;
if a=1;
run;
proc sort data=total ; by year sex tgroup dco_0 dco_1 dco_t dco_p hv_0 hv_1 hv_t hv_p dcn regi mi; run;  


x 'cd E:\04.내부요청\박은혜T 요청\R shiny 웹통계 구성\03. ca DB에 변수추가 수정'; 

proc export data=total  outfile ='result_질관리지표_all.xls' dbms=excel5 replace ; run; 

data total2; set total; drop dco_0 dco_1 dco_t hv_0 hv_1 hv_t dcn regi; run;
proc export data=total2  outfile ='result_질관리지표.xls' dbms=excel5 replace ; run; 
