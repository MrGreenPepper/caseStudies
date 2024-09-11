Scalars
calcEmissionScenarios       /1/
shortages                   /1/
CurrentStageOneScenario
CurrentStageTwoScenario
std                         /1/
mean                        /1/
propFactor
propability
e                           /2.718281828459/    
;


*for a fast code check:  $include loadTestData and "comment out" the rest 

$include loadFinalData
*$include loadTestData

$include scenarioData

Set
scenarioProp /probability, factor/
;

Parameter Table
ScenarioData(scenario, scenarioProp)
        probability     factor
s1      0.2             1.5
s2      0.5             1
s3      0.3             2
;
;

*EUR/tCO2    Sandbag (2019)
Parameter
CO2Price            /15.92/
stageOneInvestments(scenario, plants)
CurrentStageOneDecision(plants)


;

Variables
TC total cost
pumpOperation(t, storages)                  *pump operation
;



Positive Variable
totalCPCosts
totalInvestmentCosts
savedEnergy
buildCapacities(plants)
powerGeneration(scenario, t, plants)             generation per Technology (MW)
storageLoading(scenario, t, storages)
storageGen(scenario, t, storages)
storageLevel(scenario, t, storages)
export(scenario, t)
import(scenario, t)
carbonEmission(plants)
carbonEmissionCosts(plants)
overallLoad(plants)
addInvestCosts
;


Equations
*PropabilityDis
*TrimodalEquation
***     basic constraints
energy_balance


***     powerGeneration constraints
generation_constraint_Plants
generation_constraint_rePlants
storage_genConstraint_capacity

***     baseload plants ramping up/down 
ramping_upper_constraint
ramping_bottom_constraint

$onText
***     non negativity constraints
non_negativity_constraint_power
non_negativity_constraint_reg(t,renewablePlants)               
non_negativity_constraint_storage(t,storages)  
non_negativity_constraint_capacities
$offText

***     storage handle constraints
handleStorage
non_negativity_constraint_storagesLevel
storage_loadingConstraint_performance    
storage_levelConstraint_maxCapacity

***     carbon Emissions
*totalEmissionCap_EQ
*carbonEmission_EQ(plants)
*carbonEmissionCosts_EQ(plants)..

***     investment costs
capacityCosts

***     water power constraint
waterConstraint

***     for some analysis
overallLoad_EQ



***     total costs - to be minimized
total_cost
;



*PropabilityDis..                                                               propability =e= 1/(std* sqrt(2*pi)) * e**((-1/2*((propFactor)-mean))/std**2);
*TrimodalEquation..                                                 
***     basic constraints
*energy_balance(scenario, t)..                                                  sum((plants),powerGeneration(scenario, t, plants)) + import(scenario, t)  =e= (PowerDemand(t) * ScenarioData(scenario, 'factor')) + export(scenario, t);
energy_balance(scenario, t)..                                                   sum((plants),powerGeneration(scenario, t, plants)) =e= (PowerDemand(t)) * ScenarioData(scenario, "factor") + sum((storages), storageLoading(scenario, t, storages));

***     powerGeneration constraints
generation_constraint_Plants(scenario,t, plants)..                              powerGeneration(scenario, t, plants) =l= (Plants_capacities(plants) + buildCapacities(plants) + StageOneInvestmentsDecision(plants)) * Plants_availability(plants);
generation_constraint_rePlants(scenario, t, renewablePlants)..                  powerGeneration(scenario,t, renewablePlants) =l= (Plants_capacities(renewablePlants) + buildCapacities(renewablePlants)) * CapacityFactor(t, renewablePlants);
storage_genConstraint_capacity(scenario,t, storages)..                          powerGeneration(scenario,t, storages) =l= storageLevel(scenario, t, storages);


***     baseload plants ramping up/down 
ramping_upper_constraint(scenario,t, baseLoadPlants)..                          powerGeneration(scenario, t, baseLoadPlants) =l= powerGeneration(scenario,t-1, baseLoadPlants) + ((Plants_capacities(baseLoadPlants) + buildCapacities(baseLoadPlants)) * (0.18));
ramping_bottom_constraint(scenario,t, baseLoadPlants)..                         powerGeneration(scenario, t, baseLoadPlants) =g= powerGeneration(scenario,t-1, baseLoadPlants) - ((Plants_capacities(baseLoadPlants) + buildCapacities(baseLoadPlants)) * (0.18));

$onText
***     non negativity constraints
non_negativity_constraint_power(t,plants)..                                     powerGeneration(scenario, t, plants)=g=0;
non_negativity_constraint_reg(t,renewablePlants)..                              powerGeneration(t, renewablePlants)=g=0;
non_negativity_constraint_storage(t,storages)..                                 powerGeneration(t, storages)=g=0;
non_negativity_constraint_capacities(plants)..                                  buildCapacities(plants) =g= 0;
$offText

***     storage handle constraints
handleStorage(scenario, t, storages)..                                          storageLevel(scenario, t, storages) =e= storageLevel(scenario, t-1, storages) + storageLoading(scenario, t-1, storages)  - powerGeneration(scenario, t-1, storages);
non_negativity_constraint_storagesLevel(scenario, t, storages)..                storageLevel(scenario, t, storages) =g= 0;
storage_levelConstraint_maxCapacity(scenario, t, storages)..                    storageLevel(scenario, t, storages) =l= StorageCapacity(storages) + buildCapacities(storages);
storage_loadingConstraint_performance(scenario, t, storages)..                  storageLoading(scenario, t, storages) =l= (StorageCapacity(storages) + buildCapacities(storages)) / 6;

$onText
***     carbon Emissions
totalEmissionCap_EQ..                                                           TotalCarbonCap =g= sum((plants), carbonEmission(plants));
carbonEmission_EQ(plants) ..                                                    carbonEmission(plants) =e= sum((t), powerGeneration(scenario, t, plants) * Plants_carbonEmissions(plants) * CarbonEmissionEfficiencyScenarioFactor(plants));
*carbonEmissionCosts_EQ(plants)..                                               carbonEmissionCosts(plants) =e= sum((t), powerGeneration(scenario, t, plants)) * Plants_carbonEmissions(plants) * CarbonEmissionEfficiencyScenarioFactor(plants) * CO2Price;
$offText

***     investment costs
capacityCosts..                                                                 totalInvestmentCosts =e= sum((plants), buildCapacities(plants) * InvestmentCosts(plants));


***     water power constraint
waterConstraint..                                                               sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants)) * WaterCapacitieFactors =g= sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants) + buildCapacities(constraintInvestsPlants));


***     for some analysis
overallLoad_EQ(plants)..                                                        overallLoad(plants) =e= sum((t, scenario), powerGeneration(scenario, t, plants));


***     total costs - to be minimized
*total_cost..                                                                   TC =e= sum((scenario, t, plants), ScenarioData(scenario, 'probability') * powerGeneration(scenario, t, plants) * OperatingCosts(plants))  + totalInvestmentCosts;
* for testData (scaled opperational costs to equal op/invest costs ratio)

total_cost..                                                                    TC =e= sum((scenario, t, plants), ScenarioData(scenario, "probability") * powerGeneration(scenario, t, plants) * OperatingCosts(plants))  + totalInvestmentCosts;
*total_cost..                                                                   TC =e= sum((scenario, t, plants), ScenarioData(scenario, 'probability') * powerGeneration(scenario, t, plants) * OperatingCosts(plants) * 8.6666)  + totalInvestmentCosts;


Model epmProject /all/;


***Stage 1
Solve epmProject using LP minimising TC;
    StageOneInvestmentsDecision(plants) = buildCapacities.l(plants);
 
***Stage 2
Solve epmProject using LP minimising TC;
 

$onText
*** Stage 1
loop(scenarioStageOne,
    ScenarioProbability= ScenarioData(scenarioStageOne, 'probability');
    ScenarioFactor= ScenarioData(scenarioStageOne, 'factor');
    CurrentStageOneScenario = ord(scenarioStageOne);
     
    Solve epmProject using LP minimising TC;
    Z_SP(scenarioStageOne) = TC.l;
    StageOneInvestmentData(scenarioStageOne, plants) = buildCapacities.l(plants);
    Display TC.l, CurrentStageOneScenario, buildCapacities.l, totalInvestmentCosts.l;
   
);

*** Stage 2
loop(scenarioStageTwo,
   ScenarioProbability= ScenarioData(scenarioStageTwo, 'probability');
   ScenarioFactor= ScenarioData(scenarioStageTwo, 'factor');
   loop(scenarioStageOne, 
        StageOneInvestmentsDecision(plants) = StageOneInvestmentData(scenarioStageOne, plants);
        CurrentStageOneScenario = ord(scenarioStageOne);
        CurrentStageTwoScenario = ord(scenarioStageTwo);

        Solve epmProject using LP minimising TC;
        Z_SP(scenario) = TC.l;
        Display TC.l, Plants_capacities, totalInvestmentCosts.l, CurrentStageOneScenario, CurrentStageTwoScenario, StageOneInvestmentsDecision;
    );
);
$offText

*Display TC.l, powerGeneration.l, storageCapacity, storageLoading.l, import.l, export.l, Z_SP, stageOneInvestments, Plants_capacities;


execute_unload "res_energyEQ.gdx" energy_balance.l
execute 'gdxxrw.exe res_energyEQ.gdx o=res_energyEQ.xlsx var=energy_balance.l'

execute_unload "powerGeneration.gdx" powerGeneration.l
execute 'gdxxrw.exe res_powerGeneration.gdx o=res_powerGeneration.xls var=powerGeneration.l'

execute_unload "res_storageCapacity.gdx"storageCapacity
execute 'gdxxrw.exe res_storageCapacity.gdx o=res_storageCapacity.xls var=storageCapacity'

execute_unload "res_storageLoading.gdx" storageLoading.l
execute 'gdxxrw.exe res_storageLoading.gdx o=res_storageLoading.xls var=storageLoading.l'

execute_unload "res_overallLoad.gdx" overallLoad.l
execute 'gdxxrw.exe res_overallLoad.gdx o=res_overallLoad.xls var=overallLoad.l'

execute_unload "res_buildCapacities.gdx" buildCapacities.l
execute 'gdxxrw.exe res_buildCapacities.gdx o=res_buildCapacities.xls var=buildCapacities.l'

*execute 'gdxxrw.exe .gdx o=.xls var='