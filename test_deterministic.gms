
Set

plants   /base, quick/
t           /t1 * t4/
;



Parameter
VC(plants)          /base 1, quick 3/
FC(plants)          /base 10, quick 3/
PD                  /t1 10, t2 10, t3 20, t4 40/
;

Positive Variable
generation(t, plants)

plant_capacities(plants)
;
Variable
TC;
Equations


cap_con
bal_con
totalCosts
;


bal_con(t)..                                    PD(t) =e= sum(plants, generation(t, plants));
                            
cap_con(t, plants)..                            plant_capacities(plants) - generation(t, plants) =g= 0;

totalCosts..                                    TC =e= sum((plants,t), generation(t, plants)*VC(plants)) + sum(plants, plant_capacities(plants) * FC(plants));

  
Model detter /
bal_con,
cap_con,
totalCosts
/;


 Solve detter using LP minimizing TC;
