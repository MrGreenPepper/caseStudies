Scalars

calcEmissionScenarios       /1/
shortages                   /1/
CurrentStageOneScenario
CurrentStageTwoScenario
;

*for a fast code check:  $include loadTestData2 and "comment out" the rest
*$include loadTestData

$include loadFinalData
*$include loadTestData3

$include scenarioData


*EUR/tCO2    Sandbag (2019)
Parameter
CO2Price            /15.92/
stageOneInvestments(scenario, plants, country)
CurrentStageOneDecision(plants, country)

;

Variables
TC total cost
pumpOperation(t, storages)                  *pump operation
;



Positive Variable
totalCPCosts
totalInvestmentCosts
savedEnergy
buildCapacities(plants, country)
powerGeneration(t, plants, country)             generation per Technology (MW)
storageLoading(t, storages, country)
storageGen(t, storages)
storageLevel(t, storages, country)
export(country, t)
import(country, t)
carbonEmission(country, plants)
carbonEmissionCosts(country, plants)
overallLoad(plants)
addInvestCosts
;


Equations
***     basic constraints
energy_balance(t, country)
trade_constraint

***     powerGeneration constraints
generation_constraint_Plants
generation_constraint_rePlants(t, renewablePlants, country)
storage_genConstraint_capacity

***     baseload plants ramping up/down 
ramping_upper_constraint(t, baseLoadPlants, country)
ramping_bottom_constraint(t, baseLoadPlants, country)

$onText
***     non negativity constraints
non_negativity_constraint_power
non_negativity_constraint_reg(t,renewablePlants, country)               
non_negativity_constraint_storage(t,storages, country)  
non_negativity_constraint_capacities
$offText

***     storage handle constraints
handleStorage
non_negativity_constraint_storagesLevel
storage_loadingConstraint_performance    
storage_levelConstraint_maxCapacity

***     carbon Emissions
*totalEmissionCap_EQ
*carbonEmission_EQ(country, plants)
*carbonEmissionCosts_EQ(country, plants)..

***     investment costs
capacityCosts

***     water power constraint
waterConstraint

***     for some analysis
overallLoad_EQ(plants)



***     total costs - to be minimized
total_cost
;




***     basic constraints
energy_balance(t, country)..                                        sum((plants),powerGeneration(t, plants, country)) + import(country, t)  =e= PowerDemand(t, country)  * ScenarioFactor + export(country, t) + sum((storages), storageLoading(t, storages, country));
trade_constraint(t)..                                               sum(country, import(country, t)) =e=  sum(country, export(country, t)) * 0.9;


***     powerGeneration constraints
generation_constraint_Plants(t, plants, country)..                  powerGeneration(t, plants, country) =l= (Plants_capacities(plants, country) + buildCapacities(plants, country) + StageOneInvestmentsDecision(plants, country)) * Plants_availability(plants);
generation_constraint_rePlants(t, renewablePlants, country)..       powerGeneration(t, renewablePlants, country) =l= (Plants_capacities(renewablePlants, country) + buildCapacities(renewablePlants, country)) * CapacityFactor(t, renewablePlants);
storage_genConstraint_capacity(t, storages, country)..              powerGeneration(t, storages, country) =l= storageLevel(t, storages, country);


***     baseload plants ramping up/down 
ramping_upper_constraint(t, baseLoadPlants, country)..              powerGeneration(t, baseLoadPlants, country) =l= powerGeneration(t-1, baseLoadPlants, country) + ((Plants_capacities(baseLoadPlants, country) + buildCapacities(baseLoadPlants, country)) * (0.18));
ramping_bottom_constraint(t, baseLoadPlants, country)..             powerGeneration(t, baseLoadPlants, country) =g= powerGeneration(t-1, baseLoadPlants, country) - ((Plants_capacities(baseLoadPlants, country) + buildCapacities(baseLoadPlants, country)) * (0.18));

$onText
***     non negativity constraints
non_negativity_constraint_power(t,plants, country)..                powerGeneration(t, plants, country)=g=0;
non_negativity_constraint_reg(t,renewablePlants, country)..         powerGeneration(t, renewablePlants, country)=g=0;
non_negativity_constraint_storage(t,storages, country)..            powerGeneration(t, storages, country)=g=0;
non_negativity_constraint_capacities(plants, country)..             buildCapacities(plants, country) =g= 0;
$offText

***     storage handle constraints
handleStorage(t, storages, country)..                               storageLevel(t, storages, country) =e= storageLevel(t-1, storages, country) + storageLoading(t-1, storages, country)  - powerGeneration(t-1, storages, country);
non_negativity_constraint_storagesLevel(t, storages, country)..     storageLevel(t, storages, country) =g= 0;
storage_levelConstraint_maxCapacity(t, storages, country)..         storageLevel(t, storages, country) =l= StorageCapacity(storages, country) + buildCapacities(storages, country);
storage_loadingConstraint_performance(t, storages, country)..       storageLoading(t, storages, country) =l= (StorageCapacity(storages, country) + buildCapacities(storages, country)) / 6;

$onText
***     carbon Emissions
totalEmissionCap_EQ..                                               TotalCarbonCap =g= sum((country, plants), carbonEmission(country, plants));
carbonEmission_EQ(country, plants) ..                               carbonEmission(country, plants) =e= sum((t), powerGeneration(t, plants, country) * Plants_carbonEmissions(plants) * CarbonEmissionEfficiencyScenarioFactor(plants));
*carbonEmissionCosts_EQ(country, plants)..                          carbonEmissionCosts(country, plants) =e= sum((t), powerGeneration(t, plants, country)) * Plants_carbonEmissions(plants) * CarbonEmissionEfficiencyScenarioFactor(plants) * CO2Price;
$offText

***     investment costs
capacityCosts(country)..                                            totalInvestmentCosts =e= sum((plants), buildCapacities(plants, country) * InvestmentCosts(plants));


***     water power constraint
waterConstraint(country)..                                          sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants, country)) * WaterCapacitieFactors(country) =g= sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants, country) + buildCapacities(constraintInvestsPlants, country));


***     for some analysis
overallLoad_EQ(plants)..                                            overallLoad(plants) =e= sum((country, t), powerGeneration(t, plants, country));


***     total costs - to be minimized
total_cost..                                                        TC =e= sum((t, plants, country),powerGeneration(t, plants, country) * OperatingCosts(plants))  + totalInvestmentCosts;


Model epmProject /all/;

*** Stage 1
loop(scenarioStageOne,
    ScenarioProbability= ScenarioData(scenarioStageOne, 'probaility');
    ScenarioFactor= ScenarioData(scenarioStageOne, 'factor');
    CurrentStageOneScenario = ord(scenarioStageOne);
     
    Solve epmProject using LP minimising TC;
    Z_SP(scenarioStageOne) = TC.l;
    StageOneInvestmentData(scenarioStageOne, plants, country) = buildCapacities.l(plants, country);
    Display TC.l, CurrentStageOneScenario, buildCapacities.l, totalInvestmentCosts.l;
   
);

*** Stage 2
loop(scenarioStageTwo,
   ScenarioProbability= ScenarioData(scenarioStageTwo, 'probaility');
   ScenarioFactor= ScenarioData(scenarioStageTwo, 'factor');
   loop(scenarioStageOne, 
        StageOneInvestmentsDecision(plants, country) = StageOneInvestmentData(scenarioStageOne, plants, country);
        CurrentStageOneScenario = ord(scenarioStageOne);
        CurrentStageTwoScenario = ord(scenarioStageTwo);

        Solve epmProject using LP minimising TC;
        Z_SP(scenario) = TC.l;
        Display TC.l, Plants_capacities, totalInvestmentCosts.l, CurrentStageOneScenario, CurrentStageTwoScenario, StageOneInvestmentsDecision;
    );
);


*Display TC.l, powerGeneration.l, storageCapacity, storageLoading.l, import.l, export.l, Z_SP, stageOneInvestments, Plants_capacities;


execute_unload "energyEQ.gdx" energy_balance.l
execute 'gdxxrw.exe energyEQ.gdx o=energyEQ.xlsx var=energy_balance.l'

execute_unload "powerGeneration.gdx" powerGeneration.l
execute 'gdxxrw.exe powerGeneration.gdx o=powerGeneration.xls var=powerGeneration.l'

execute_unload "storageCapacity.gdx"storageCapacity
execute 'gdxxrw.exe storageCapacity.gdx o=storageCapacity.xls var=storageCapacity'

execute_unload "storageLoading.gdx" storageLoading.l
execute 'gdxxrw.exe storageLoading.gdx o=storageLoading.xls var=storageLoading.l'

execute_unload "import" import.l
execute 'gdxxrw.exe import.gdx o=import.xls var=import.l'

execute_unload "export" export.l
execute 'gdxxrw.exe export.gdx o=export.xls var=export.l'




*execute 'gdxxrw.exe .gdx o=.xls var='