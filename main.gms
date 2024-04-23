Set
plants      /hydro, water, coal/
t           /t1*t4/
;

Parameter
powerCapacities(plants)     /hydro 50, water 100, coal 50/
powerDemand(t)              /t1 50, t2 100, t3 200, t4 100/
varCosts(plants)            /hydro 5, water 1, coal 5/
;

Variable
powerGeneration(t, plants)
costs
;

Equations
totalCosts
powerBalance
outputConstraint1
outputConstraint2
;


powerBalance(t)..          powerDemand(t) =e= sum((plants), powerGeneration(t, plants));
totalCosts..               costs =e= sum((t, plants), powerGeneration(t, plants) * varCosts(plants));

outputConstraint1(t, plants)..           powerGeneration(t, plants) =g= 0;
outputConstraint2(t, plants)..           powerGeneration(t, plants) =l= powerCapacities(plants);


Model caseStudies/all/;

Solve caseStudies using LP minimising costs;

Display powerGeneration.l;