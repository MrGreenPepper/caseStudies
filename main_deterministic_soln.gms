

$include loadFinalData
*$include loadTestData

$include scenarioData
Alias(t, h);



scalars
store_eff storage efficiency  /0.9/
voll    value of lost load Euro per MWh/15000/
CO2Price            Euro per T of Co2 Eq.  /500/
;


Variables
TC total cost
pumpOperation(t, storages)                      *pump operation
;



Positive Variable
totalCPCosts
load_shedding( t)
totalInvestmentCosts
savedEnergy
buildCapacities(plants)
powerGeneration( t, plants)             generation per Technology (MW)
storageLoading( t, storages)
storageGen(t, storages)
storageLevel( t, storages)
carbonEmission(plants)
carbonEmissionCosts(plants,t)
overallLoad(plants)
addInvestCosts
;
InvestmentCosts("windOff") = 324000;

Equations

***     basic constraints
energy_balance
load_sheddingEQ( t)

***     powerGeneration constraints
generation_constraint_Plants
generation_constraint_rePlants
storage_genConstraint_capacity

***     baseload plants ramping up/down 
ramping_upper_constraint
ramping_bottom_constraint

***     storage handle constraints
handleStorage
non_negativity_constraint_storagesLevel
storage_loadingConstraint_performance    
storage_levelConstraint_maxCapacity

carbonEmissionCosts_EQ

***     investment costs
capacityCosts

***     water power constraint
waterConstraint

***     for some analysis
overallLoad_EQ



***     total costs - to be minimized
total_cost
;




energy_balance( t)..                                                   sum((plants),powerGeneration( t, plants))+load_shedding(t) =e= sum(scenario, ScenarioProbability(scenario)*(PowerDemand(t, scenario))) + sum((storages), storageLoading( t, storages));
load_sheddingEQ( t)..                                                  sum((plants),powerGeneration( t, plants))=g= load_shedding( t) ;

***     powerGeneration constraints
generation_constraint_Plants(t, plants)..                              powerGeneration( t, plants) =l= (Plants_capacities(plants) + buildCapacities(plants)) * Plants_availability(plants);
generation_constraint_rePlants( t, renewablePlants)..                  powerGeneration(t, renewablePlants) =l= (Plants_capacities(renewablePlants) + buildCapacities(renewablePlants)) * CapacityFactor(t, renewablePlants);
storage_genConstraint_capacity(t, storages)..                          powerGeneration(t, storages) =l= storageLevel( t, storages);


***     baseload plants ramping up/down 
ramping_upper_constraint(t,h, baseLoadPlants)$(ord(t)-1 = ord(h))..     powerGeneration( t, baseLoadPlants) =l= powerGeneration(h, baseLoadPlants) + ((Plants_capacities(baseLoadPlants) + buildCapacities(baseLoadPlants)))/6 ;
ramping_bottom_constraint(t,h, baseLoadPlants)$(ord(t)-1 = ord(h))..    powerGeneration( t, baseLoadPlants) =g= powerGeneration(h, baseLoadPlants) ;
* 6 hours for reaching full Capacity


***     storage handle constraints
handleStorage( t,h,  storages)$(ord(t)-1 = ord(h))..                   storageLevel( t, storages) =e= storageLevel( h, storages) + storageLoading( h, storages)  - powerGeneration( h, storages)*store_eff;
non_negativity_constraint_storagesLevel( t, storages)..                storageLevel( t, storages) =g= 0;
storage_levelConstraint_maxCapacity( t, storages)..                    storageLevel( t, storages) =l= StorageCapacity(storages) + buildCapacities(storages);
storage_loadingConstraint_performance( t, storages)..                  storageLoading( t, storages) =l= (StorageCapacity(storages) + buildCapacities(storages)) / 6;


carbonEmissionCosts_EQ(plants,t)..                                              carbonEmissionCosts(plants,t) =e=  powerGeneration( t, plants)*Plants_carbonEmissions(plants) * CO2Price;
***     investment costs
capacityCosts..                                                                 totalInvestmentCosts =e= sum((plants), buildCapacities(plants) * InvestmentCosts(plants));
* * CarbonEmissionEfficiencyFactor(plants)

***     water power constraint
waterConstraint..                                                               sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants)) * WaterCapacitieFactors =g= sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants) + buildCapacities(constraintInvestsPlants));


***     for some analysis
overallLoad_EQ(plants)$(not storages(plants))..                                 overallLoad(plants) =e= sum((t), powerGeneration( t, plants));



total_cost..                                                                    TC =e= sum(( t, plants),  (powerGeneration( t, plants) * OperatingCosts(plants) + carbonEmissionCosts(plants,t)))  + totalInvestmentCosts+sum((t),load_shedding(t)*voll);
*total_cost..                                                                   TC =e= sum((scenario, t, plants), ScenarioData(scenario, 'probability') * powerGeneration( t, plants) * OperatingCosts(plants) * 8.6666)  + totalInvestmentCosts;


Model epmProjectEV /all/;

buildCapacities.fx("nuclear")=0;


overallLoad.fx("nuclear")=0;


powerGeneration.up( t,"biomass") = sum(scenario, ScenarioProbability(scenario)*(PowerDemand(t, scenario)))*0.05;
powerGeneration.up( t,"waste") = sum(scenario, ScenarioProbability(scenario)*(PowerDemand(t, scenario)))*0.05;
powerGeneration.up( t,"geothermal") = sum(scenario, ScenarioProbability(scenario)*(PowerDemand(t, scenario)))*0.05;
* at max 5% for these technolgies


storageLevel.up(t, storages) = sum(scenario, ScenarioProbability(scenario)*(PowerDemand(t, scenario)))*0.1;

* at max 10% storage allowed

***Stage 1
Solve epmProjectEV using LP minimising TC;


execute_unload "res_energyEQDS.gdx" energy_balance.l
execute 'gdxxrw.exe res_energyEQDS.gdx o=res_energyEQDS.xlsx var=energy_balance.l'

execute_unload "powerGenerationDS.gdx" powerGeneration.l
execute 'gdxxrw.exe res_powerGenerationEV.gdx o=res_powerGenerationDS.xls var=powerGeneration.l'

execute_unload "res_storageCapacityDS.gdx"storageCapacity
execute 'gdxxrw.exe res_storageCapacityEV.gdx o=res_storageCapacityDS.xls var=storageCapacity'

execute_unload "res_storageLoadingDS.gdx" storageLoading.l
execute 'gdxxrw.exe res_storageLoadingDS.gdx o=res_storageLoadingDS.xls var=storageLoading.l'

execute_unload "res_overallLoadDS.gdx" overallLoad.l
execute 'gdxxrw.exe res_overallLoadDS.gdx o=res_overallLoadDS.xls var=overallLoad.l'

execute_unload "res_buildCapacitieDS.gdx" buildCapacities.l
execute 'gdxxrw.exe res_buildCapacities.gdx o=res_buildCapacitiesDS.xls var=buildCapacities.l'

*execute 'gdxxrw.exe .gdx o=.xls var='