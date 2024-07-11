* ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- *
* ELTRAMOD_stud v1.0.0
* for Classroom Modelling, July 2021
*
* Hannes Hobbie, Constantin Dierstein, Matthew Schmidt,
* Dominik M�st
*
* TU Dresden, Chair of Energy Economics
* ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- *


* -- DECLARATION OF ENTITIES -- *

Sets
t             /t1 *t2/ 
r             /quick, base/
f             /oil, coal, battery/
map_rf        mapping technology-to-fuel
s(r)          /battery/
th(r)         /oil, coal/
scen          /s1*s2/
scen_(scen)   subset of scenario
;


Parameters
tech_char(r,*)        technology characteristics
time_char(t,*)        time characteristics
fuel_price(f)         fuel prices
d_res(t)              residual demand
rescap(scen,*)        RES capacity
a(r)                  annuity
co_var(r)             variable cost
R_(*)                 results
Rfuel(f,*)            fuel dependent results
Rtech(r,*)            technology dependent results
Rtechtime(t,*,r)      technology and time dependent results
;

loop(r,
    tech_char(r,*)     = 1;   
time_char(t,*)         = 1;
fuel_price(f)          = 1;
d_res(t)               = 1;
rescap(scen,*)         = 1;
a(r)                   = 1;
co_var(r)              = 1;
R_(*)                 = 1;
Rfuel(f,*)             = 1;
Rtech(r,*)             = 1;
Rtechtime(t,*,r)   = 1;
);
Scalars
PowerEnergyRatio        power-to-energy ratio
eta         storage efficiency
co_curt     penalty for curtailment
sc          scaling factor
;


Positive Variables
CC          Total curtailment costs
CG          Total generation costs
CI          Total investments
C(r)        aggregated capacity
G(t,r)      aggregated generation
SL(t,r)     aggregated storage level
P(t,r)      aggregated pump operation
CU(t)       aggregated RES curtailment
;


Variables
TC       total system cost
;


Equations
objective_function        target function
investment_cost           investment expenses
dispatch_cost             generation expenses
curtailment_cost          curtailment expenses
energy_balance            market clearing
generation_constraint     maximal generation
storage_level             current storage level
storage_constraint        maximal storage level
storage_start             boundary condition t1
storage_end               boundary condition t2
pump_constraint           maximal pump operation
;



* -- DEFINITION OF ENTITIES -- *

* data import
$onecho >INPUTDATA\temp.tmp
set=t             rng=timeseries!A4       rdim=1 cdim=0
set=r             rng=plants!A4           rdim=1 cdim=0
set=f             rng=fuels!A3            rdim=0 cdim=1
set=map_rf        rng=plants!A4           rdim=2 cdim=0
set=scen          rng=scenarios!A4        rdim=1 cdim=0
par=tech_char     rng=plants!A3           rdim=1 cdim=1
par=time_char     rng=timeseries!A3       rdim=1 cdim=1
par=fuel_price    rng=fuels!A3            rdim=0 cdim=1
par=rescap        rng=scenarios!A3        rdim=1 cdim=1
$offecho

$onUNDF
$call "gdxxrw INPUTDATA\INPUTDATA.xlsx O=INPUTDATA\INPUTDATA.gdx SQ=N SE=10 cmerge=1 @INPUTDATA\temp.tmp"
$gdxin INPUTDATA\INPUTDATA
$load t r f map_rf tech_char time_char fuel_price scen rescap
$gdxin
$offUNDF

* subset definition
s('psp') = yes ;
th(r) = yes ;
th('psp') = no ;

* scenario definition
scen_('scen3') = yes ;

* scalar definition
PowerEnergyRatio = 6 ;
co_curt = 100 ;
eta = sum(s, tech_char(s,'efficiency')) ;
sc = 1/1e6 ;

* residual demand definition
d_res(t) = time_char(t,'demand') - time_char(t,'cfsolar') * sum(scen_, rescap(scen_,'solar')) - time_char(t,'cfwind') * sum(scen_, rescap(scen_,'wind')) ;

* cost factors
a(r) = tech_char(r,'annuity') + tech_char(r,'maintenance') + tech_char(r,'staff') + tech_char(r,'insurance') ;

co_var(r) = 1/tech_char(r,'efficiency') * sum(f$map_rf(r,f), fuel_price(f)) +
            1/tech_char(r,'efficiency') * tech_char(r,'emission') * fuel_price('carbon') +
            tech_char(r,'operation') + tech_char(r,'reserves') + tech_char(r,'disposal') ;



* -- DEFINITION OF EQUATIONS -- *

* costs and related definitions

objective_function..
TC  =e=  CI + CG + CC ;


investment_cost..
CI  =e=  sum(r, C(r) * a(r)) * sc ;


dispatch_cost..
CG  =e=  sum((t,r), G(t,r) * co_var(r)) * sc;


curtailment_cost..
CC   =e=   sum(t, CU(t) * co_curt) * sc ;


* power market clearing

energy_balance(t)..
sum(r, G(t,r)) - CU(t) - sum(s, P(t,s))   =e=   d_res(t) ;


CU.up(t) = time_char(t,'cfsolar') * sum(scen_, rescap(scen_,'solar')) + time_char(t,'cfwind') * sum(scen_, rescap(scen_,'wind')) ;


* generation and storage restrictions

generation_constraint(t,r)..
G(t,r)  =l=  C(r) ;


pump_constraint(t,s)..
P(t,s)  =l=  C(s) ;


storage_level(t,s) $ (ord(t)>1)..
SL(t,s)  =e=  SL(t-1,s) - G(t,s) + P(t,s) * eta ;


storage_constraint(t,s)..
SL(t,s)  =l=  C(s) * PowerEnergyRatio ;


storage_start(t,s) $ (ord(t)=1)..
SL(t,s) =e= 0.5 * C(s) * PowerEnergyRatio - G(t,s) + P(t,s) * eta ;


storage_end(t,s) $ (ord(t)=8760)..
SL(t,s) =e= 0.5 * C(s) ;



* -- MODEL BUILDING AND SOLVING -- *

C.up(s) = 15000 ;
*C.fx(s) = 0 ;

model ELTRAMOD_stud / all / ;
solve ELTRAMOD_stud using lp minimising TC ;




* -- RESULT PROCESSING -- *

* result definitions
R_('01_COST') = TC.l ;

Rfuel(f,'01_GENERATION') = sum((t,r) $ map_rf(r,f), G.l(t,r)) ;

Rtech(r,'01_GENERATION') = sum(t, G.l(t,r)) ;
Rtech(r,'02_CAP') = C.l(r) ;
Rtech(r,'03_FLH') $ C.l(r) = sum(t, G.l(t,r)) / C.l(r) ;
Rtech(r,'04_CARBONEMISSION') = sum(t, G.l(t,r)) / tech_char(r,'efficiency') * tech_char(r,'emission') ;

Rtechtime(t,'01_GENERATION',r) = G.l(t,r) ;
Rtechtime(t,'02_PUMP',s) = P.l(t,s) ;
Rtechtime(t,'02_PUMP',s) $ (Rtechtime(t,'02_PUMP',s)=0) = eps ;


* gdx export
execute_unload 'RESULTS\results_all.gdx' ;
execute_unload 'RESULTS\results.gdx' R_, Rfuel, Rtech, Rtechtime ;

* XLS export
execute 'gdxxrw.exe RESULTS\results.gdx O=RESULTS\RESULTS.xlsx epsout=0 par=R_ rng=R_!a1' ;
execute 'gdxxrw.exe RESULTS\results.gdx O=RESULTS\RESULTS.xlsx epsout=0 par=Rfuel rng=Rfuel!a1' ;
execute 'gdxxrw.exe RESULTS\results.gdx O=RESULTS\RESULTS.xlsx epsout=0 par=Rtech rng=Rtech!a1' ;
execute 'gdxxrw.exe RESULTS\results.gdx O=RESULTS\RESULTS.xlsx epsout=0 par=Rtechtime rng=Rtechtime!a1 rdim=1 cdim=2' ;
