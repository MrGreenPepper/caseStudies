

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
load_shedding(scenario, t)
totalCPCosts
total_shed
totalInvestmentCosts
savedEnergy
buildCapacities(plants)
powerGeneration(scenario, t, plants)             generation per Technology (MW)
storageLoading(scenario, t, storages)
storageGen(scenario, t, storages)
storageLevel(scenario, t, storages)
carbonEmission(plants)
carbonEmissionCosts(plants,t, scenario)
overallLoad(plants)
addInvestCosts
;
InvestmentCosts("windOff") = 324000;

Equations

energy_balance
load_sheddingEQ


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

load_sheddingEQ2

***     total costs - to be minimized
total_cost
;



                                 
energy_balance(scenario, t)..                                                   sum((plants),powerGeneration(scenario, t, plants))+ load_shedding(scenario, t) =e= (PowerDemand(t, scenario)) + sum((storages), storageLoading(scenario, t, storages));
load_sheddingEQ(scenario, t)..                                                  sum((plants),powerGeneration(scenario, t, plants))=g= load_shedding(scenario, t) ;
load_sheddingEQ2..                                                              total_shed=e= sum((scenario, t),load_shedding(scenario, t)) ;
***     powerGeneration constraints
generation_constraint_Plants(scenario,t, plants)..                              powerGeneration(scenario, t, plants) =l= (Plants_capacities(plants) + buildCapacities(plants)) * Plants_availability(plants);
generation_constraint_rePlants(scenario, t, renewablePlants)..                  powerGeneration(scenario,t, renewablePlants) =l= (Plants_capacities(renewablePlants) + buildCapacities(renewablePlants)) * CapacityFactor(t, renewablePlants);
storage_genConstraint_capacity(scenario,t, storages)..                          powerGeneration(scenario,t, storages) =l= storageLevel(scenario, t, storages);


***     baseload plants ramping up/down 
ramping_upper_constraint(scenario,t,h, baseLoadPlants)$(ord(t)-1 = ord(h))..     powerGeneration(scenario, t, baseLoadPlants) =l= powerGeneration(scenario,h, baseLoadPlants) + ((Plants_capacities(baseLoadPlants) + buildCapacities(baseLoadPlants)))/6 ;
ramping_bottom_constraint(scenario,t,h, baseLoadPlants)$(ord(t)-1 = ord(h))..    powerGeneration(scenario, t, baseLoadPlants) =g= powerGeneration(scenario,h, baseLoadPlants) ;
* 6 hours for reaching full Capacity

***     storage handle constraints
handleStorage(scenario, t,h,  storages)$(ord(t)-1 = ord(h))..                   storageLevel(scenario, t, storages) =e= storageLevel(scenario, h, storages) + storageLoading(scenario, h, storages)  - powerGeneration(scenario, h, storages)*store_eff;
non_negativity_constraint_storagesLevel(scenario, t, storages)..                storageLevel(scenario, t, storages) =g= 0;
storage_levelConstraint_maxCapacity(scenario, t, storages)..                    storageLevel(scenario, t, storages) =l= StorageCapacity(storages) + buildCapacities(storages);
storage_loadingConstraint_performance(scenario, t, storages)..                  storageLoading(scenario, t, storages) =l= (StorageCapacity(storages) + buildCapacities(storages)) / 6;


carbonEmissionCosts_EQ(plants,t, scenario)..                                    carbonEmissionCosts(plants,t, scenario) =e=  powerGeneration(scenario, t, plants)*Plants_carbonEmissions(plants) * CO2Price;
***     investment costs
capacityCosts..                                                                 totalInvestmentCosts =e= sum((plants), buildCapacities(plants) * InvestmentCosts(plants));
* * CarbonEmissionEfficiencyFactor(plants)

***     water power constraint
waterConstraint..                                                               sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants)) * WaterCapacitieFactors =g= sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants) + buildCapacities(constraintInvestsPlants));


***     for some analysis
overallLoad_EQ(plants)$(not storages(plants))..                                 overallLoad(plants) =e= sum((t, scenario), powerGeneration(scenario, t, plants));

total_cost..                                                                    TC =e= sum((scenario, t, plants), ScenarioProbability(scenario) * (powerGeneration(scenario, t, plants) * OperatingCosts(plants) + carbonEmissionCosts(plants,t, scenario)))  + totalInvestmentCosts+sum((scenario,t),ScenarioProbability(scenario)*load_shedding(scenario, t)*voll);


Model epmProject /all/;

buildCapacities.fx("nuclear")=0;


overallLoad.fx("nuclear")=0;


powerGeneration.up(scenario, t,"biomass") = (PowerDemand(t, scenario))*0.05;
powerGeneration.up(scenario, t,"waste") = (PowerDemand(t, scenario))*0.05;
powerGeneration.up(scenario, t,"geothermal") = (PowerDemand(t, scenario))*0.05;
* at max 5% for these technolgies


storageLevel.up(scenario, t, storages) = (PowerDemand(t, scenario))*0.1;
* at max 10% storage allowed


$ontext

the following buildCapacities are the solution from the deterministic model



windOff                       .         19112.7929        +INF             .          
windOn                        .        101812.3810        +INF             .          
water                         .           687.3146        +INF             .          
biomass                       .          3677.3508        +INF             .          
solar                         .        103123.5443        +INF             .          
waste                         .          2424.5332        +INF             .          
geothermal                    .              .            +INF       162628.5877      
lignite                       .              .            +INF       110728.5062      
nuclear                       .              .              .        332185.5186      
hardcoal                      .              .            +INF       101986.7820      
gas                           .         53494.1308        +INF             .          
oil                           .              .            +INF        98514.5394      
pumpedStoragesPlants          .              .            +INF       102087.0660      
battery                       .          5391.7620        +INF             .          
reservoirStorages             .              .            +INF       336275.3095      

$offtext



buildCapacities.fx("windOff")=19112.7929;
buildCapacities.fx("windOn")=101812.3810;
buildCapacities.fx("water")=687.3146;
buildCapacities.fx("biomass")=3677.3508;
buildCapacities.fx("solar")=103123.5443;
buildCapacities.fx("waste")=2424.5332;
buildCapacities.fx("geothermal")=0;
buildCapacities.fx("lignite ")=0;
buildCapacities.fx("nuclear")=0;
buildCapacities.fx("hardcoal")=0;
buildCapacities.fx("gas")=53494.1308;
buildCapacities.fx("oil")=0;
buildCapacities.fx("pumpedStoragesPlants")=0;
buildCapacities.fx("battery")=5391.7620;



***Stage 1
Solve epmProject using LP minimising TC;

Parameters gen_costs(scenario), shedding_cost(scenario);

gen_costs(scenario) = sum((t, plants),(powerGeneration.l(scenario, t, plants) * OperatingCosts(plants) + carbonEmissionCosts.l(plants,t, scenario)));
shedding_cost(scenario) = sum((t),load_shedding.l(scenario, t)*voll );

display gen_costs, shedding_cost;


execute_unload "res_energyEQEV.gdx" energy_balance.l
execute 'gdxxrw.exe res_energyEQEV.gdx o=res_energyEQEV.xlsx var=energy_balance.l'

execute_unload "powerGenerationEV.gdx" powerGeneration.l
execute 'gdxxrw.exe res_powerGenerationEV.gdx o=res_powerGenerationEV.xls var=powerGeneration.l'

execute_unload "res_storageCapacityEV.gdx"storageCapacity
execute 'gdxxrw.exe res_storageCapacityEV.gdx o=res_storageCapacityEV.xls var=storageCapacity'

execute_unload "res_storageLoadingEV.gdx" storageLoading.l
execute 'gdxxrw.exe res_storageLoadingEV.gdx o=res_storageLoadingEV.xls var=storageLoading.l'

execute_unload "res_overallLoadEV.gdx" overallLoad.l
execute 'gdxxrw.exe res_overallLoadEV.gdx o=res_overallLoadEV.xls var=overallLoad.l'

execute_unload "res_buildCapacitiesEV.gdx" buildCapacities.l
execute 'gdxxrw.exe res_buildCapacitiesEV.gdx o=res_buildCapacitiesEV.xls var=buildCapacities.l'

*execute 'gdxxrw.exe .gdx o=.xls var='