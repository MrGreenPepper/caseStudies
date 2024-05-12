Set
plants      /hydro, solar, coal/
;

$include testData
*$include realData

Variables
powerGeneration(t, plants)
newBuildPlants(plants)
summedPlantCapacity(plants)
summedVariableCosts
summedFixedCosts
summedCosts
;



Equations
*model logic
powerBalance
totalPlantCapacities

*constraints
generationConstraint_lowerBound
generationConstraint_upperBound

*costs
totalVariableCosts
totalFixedCosts
totalCosts
;

*model logic
powerBalance(t)..          								PowerDemand(t) =e= sum((plants), powerGeneration(t, plants));
totalPlantCapacities(plants)..							summedPlantCapacity(plants) =e= BuiltPlantCapacities(plants) + newBuildPlants(plants); 

*constraints
generationConstraint_lowerBound(t, plants)..           	powerGeneration(t, plants) =g= 0;
generationConstraint_upperBound(t, plants)..           	powerGeneration(t, plants) =l= summedPlantCapacity(plants);

*costs
totalVariableCosts..									summedVariableCosts =e= sum((plants, t), powerGeneration(t,plants) * VariablePlantsCosts(plants));			
totalFixedCosts..									    summedFixedCosts =e= sum((plants, t), summedPlantCapacity(plants) * MaintainPlantsCosts(plants) + newBuildPlants(plants) * InvestmentCosts(plants));
totalCosts.. 										    summedCosts =e= summedVariableCosts + summedFixedCosts;





Model caseStudies/all/;

Solve caseStudies using LP minimising summedCosts;

Display powerGeneration.l;