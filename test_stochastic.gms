
Set
scenario            /s1*s3/
plants              /base, quick/
t                   /t1 * t4/
scenarioProperty    /propability, factor/
;



Parameter
VC(plants)          /base 1, quick 3/
FC(plants)          /base 10, quick 3/
PD                  /t1 10, t2 10, t3 10, t4 10/
;

Parameter Table
scenarioData(scenario, scenarioProperty)
        propability         factor
s1      0.25                2
s2      0.25                4
s3      0.75                1
;

Positive Variable
generation(scenario, t, plants)
plant_capacities(plants)
;
Variable
TC;


Equations
bal_stochastic

cap_con_stoch

totalCosts_stoch
;


bal_stochastic(scenario, t)..                       scenarioData(scenario, 'factor') * PD(t) =e= sum(plants, generation(scenario, t, plants));

cap_con_stoch(scenario, t,  plants)..               plant_capacities(plants) - generation(scenario, t, plants) =g= 0;

totalCosts_stoch..                                  TC =e= sum(scenario, scenarioData(scenario, 'propability') * (sum((plants,t), generation(scenario, t, plants)*VC(plants)))) + sum(plants, plant_capacities(plants) * FC(plants));



Model stochastic /
bal_stochastic,
cap_con_stoch,
totalCosts_stoch
/;



Solve stochastic using LP minimizing TC;
