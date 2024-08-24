

Sets
*t /t1*t168, t4200*t4368/
t /t1*t24/
snaps /snap1*snap4/
plants /windOff, windOn, water, biomass, solar, waste, geothermal, lignite, nuclear, hardcoal, gas, oil, pumpedStoragesPlants, battery, reservoirStorages/
conventionalPlants(plants) /lignite, nuclear, hardcoal, gas, oil/
baseLoadPlants(plants)      /lignite, hardcoal/
renewablePlants(plants) /windOff, windOn, water, biomass, solar, waste, reservoirStorages/
constraintInvestsPlants(plants)       /water, reservoirStorages/
storages(plants)
country /DE, FR, BNL/;
Table Plants_capacities(plants, country)
                                        
                    BNL     DE      FR
biomass             0       0       0
lignite             0       0       0
gas                 82778   82778 82778
hardcoal            0       0       0
oil                 0       0       0
pumpedStoragesPlants 0       0       0
water               0       0       0
reservoirStorages   0       0       0
nuclear             0       0       0
solar               0       0       0
waste               0       0       0
windOff             0       0       0
windOn              0       0       0
battery             0       0       0
;             




$call gdxxrw.exe waterCapacityFactors.xlsx par=WaterCapacitieFactors rng=Sheet1!A1:B7 dim=1 cdim=0 rdim=1 log=log_waterCapFactor.txt
Parameter WaterCapacitieFactors(country)
$gdxIn waterCapacityFactors.gdx
$load WaterCapacitieFactors
$gdxIn
;

Parameter StorageCapacity(storages, country);
$call csv2gdx storageCapacities_2019_final.csv output=storageCapacity.gdx id=storageCapacity fieldSep=semiColon decimalSep=comma colCount=3 index=1,2 value=3 useHeader=y trace=1
$gdxIn storageCapacity.gdx
$load storages = dim1
*$load country = dim2
$load StorageCapacity = storageCapacity
$gdxIn
;

$call gdxxrw.exe powerDemand_2019.xlsx par=PowerDemand rng=Sheet1!A1:D8761 dim=2 cdim=1 rdim=1 log=log_powerDemand.txt
Parameter PowerDemand(t, country)
$gdxIn powerDemand_2019.gdx
$load PowerDemand
$gdxIn
;
$onText
$call gdxxrw.exe installedCapacities_2019_01_final.xlsx par=Plants_capacities rng=Sheet1!A1:D15 dim=2 cdim=1 rdim=1 log=log_plantCapacities.txt
Parameter Plants_capacities(plants, country)
$gdxIn installedCapacities_2019_01_final.gdx
$load Plants_capacities
$gdxIn
;
$offtext

$call gdxxrw.exe capFactors.xlsx par=CapacityFactor rng=Tabelle1!A1:H8761 dim=2 cdim=1 rdim=1 log=log_capacityFactors.txt
Parameter CapacityFactor(t, plants)
$gdxIn capFactors.gdx
$load CapacityFactor
$gdxIn
;

Parameter Plants_availability(plants);
$call gdxxrw.exe plant_availabilities_2019.xlsx par=Plants_availability rng=Sheet1!A1:B14 dim=1 cdim=0 rdim=1 log=log_plantAvail.txt
$gdxIn plant_availabilities_2019.gdx
$load Plants_availability 
$gdxIn
;


$call gdxxrw.exe carbonEmission_2019.xlsx par=Plants_carbonEmissions rng=Sheet1!A1:B15 rdim=1 cdim=0 log=log_carbEm.txt
Parameter Plants_carbonEmissions(plants)
$gdxIn carbonEmission_2019.gdx
$load Plants_carbonEmissions
$gdxIn
;

$call gdxxrw.exe plant_efficiency.xlsx par=carbonEmissionEfficiencyFactor rng=Sheet1!A1:B5 rdim=1 cdim=0 log=log_carbEmEff.txt
Parameter CarbonEmissionEfficiencyFactor(plants)
$gdxIn plant_efficiency.gdx
$load carbonEmissionEfficiencyFactor
$gdxIn
;

$call gdxxrw.exe InvestmentCosts.xlsx par=InvestmentCosts rng=Sheet1!A2:B20 rdim=1 cdim=0 log=log_investC.txt
Parameter InvestmentCosts(plants)
$gdxIn InvestmentCosts.gdx
$load InvestmentCosts
$gdxIn
;

$call gdxxrw.exe opperational_costs_2019_2.xlsx par=OperatingCosts rng=Sheet1!A2:B17 rdim=1 cdim=0 log=log_opC.txt
Parameter OperatingCosts(plants)
$gdxIn opperational_costs_2019_2.gdx
$load OperatingCosts
$gdxIn
;


$onText

$offText
*import larger tabels like PowerDemand and plant data from excel








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


*for a fast code check:  $include loadTestData2 and "comment out" the rest
*$include loadTestData

*$include loadFinalData
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
*buildCapacities(plants, country)
powerGeneration(scenario, t, plants, country)             generation per Technology (MW)
storageLoading(scenario, t, storages, country)
storageGen(scenario, t, storages)
storageLevel(scenario, t, storages, country)
export(scenario, country, t)
import(scenario, country, t)
carbonEmission(country, plants)
carbonEmissionCosts(country, plants)
overallLoad(plants)
addInvestCosts
;


Equations
*PropabilityDis
*TrimodalEquation
***     basic constraints
energy_balance
trade_constraint

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
overallLoad_EQ



***     total costs - to be minimized
total_cost
;



*PropabilityDis..                                                  propability =e= 1/(std* sqrt(2*pi)) * e**((-1/2*((propFactor)-mean))/std**2);
*TrimodalEquation..                                                 
***     basic constraints
*energy_balance(scenario, t, country)..                                          sum((plants),powerGeneration(scenario, t, plants, country)) + import(scenario, country, t)  =e= (PowerDemand(t, country) * ScenarioData(scenario, 'factor')) + export(scenario, country, t);
energy_balance(scenario, t, country)..                                          sum((plants),powerGeneration(scenario, t, plants, country)) + import(scenario, country, t)  =e= (PowerDemand(t, country) * ScenarioData(scenario, 'factor')) + export(scenario, country, t) + sum((storages), storageLoading(scenario, t, storages, country));
trade_constraint(scenario,t)..                                                           sum(country, import(scenario, country, t)) =e=  sum(country, export(scenario, country, t)) * 0.9;


***     powerGeneration constraints
generation_constraint_Plants(scenario,t, plants, country)..                     powerGeneration(scenario, t, plants, country) =l= (Plants_capacities(plants, country)) * Plants_availability(plants);
generation_constraint_rePlants(scenario, t, renewablePlants, country)..         powerGeneration(scenario,t, renewablePlants, country) =l= (Plants_capacities(renewablePlants, country)) * CapacityFactor(t, renewablePlants);
storage_genConstraint_capacity(scenario,t, storages, country)..                 powerGeneration(scenario,t, storages, country) =l= storageLevel(scenario, t, storages, country);


***     baseload plants ramping up/down 
ramping_upper_constraint(scenario,t, baseLoadPlants, country)..                 powerGeneration(scenario, t, baseLoadPlants, country) =l= powerGeneration(scenario,t-1, baseLoadPlants, country) + ((Plants_capacities(baseLoadPlants, country) ) * (0.18));
ramping_bottom_constraint(scenario,t, baseLoadPlants, country)..                powerGeneration(scenario, t, baseLoadPlants, country) =g= powerGeneration(scenario,t-1, baseLoadPlants, country) - ((Plants_capacities(baseLoadPlants, country) ) * (0.18));

$onText
***     non negativity constraints
non_negativity_constraint_power(t,plants, country)..                            powerGeneration(scenario, t, plants, country)=g=0;
non_negativity_constraint_reg(t,renewablePlants, country)..                     powerGeneration(t, renewablePlants, country)=g=0;
non_negativity_constraint_storage(t,storages, country)..                        powerGeneration(t, storages, country)=g=0;
non_negativity_constraint_capacities(plants, country)..                         buildCapacities(plants, country) =g= 0;
$offText

***     storage handle constraints
handleStorage(scenario, t, storages, country)..                                 storageLevel(scenario, t, storages, country) =e= storageLevel(scenario, t-1, storages, country) + storageLoading(scenario, t-1, storages, country)  - powerGeneration(scenario, t-1, storages, country);
non_negativity_constraint_storagesLevel(scenario, t, storages, country)..                 storageLevel(scenario, t, storages, country) =g= 0;
storage_levelConstraint_maxCapacity(scenario, t, storages, country)..                     storageLevel(scenario, t, storages, country) =l= StorageCapacity(storages, country) + plants_Capacities(storages, country);
storage_loadingConstraint_performance(scenario, t, storages, country)..                   storageLoading(scenario, t, storages, country) =l= (StorageCapacity(storages, country) + plants_Capacities(storages, country)) / 6;

$onText
***     carbon Emissions
totalEmissionCap_EQ..                                               TotalCarbonCap =g= sum((country, plants), carbonEmission(country, plants));
carbonEmission_EQ(country, plants) ..                               carbonEmission(country, plants) =e= sum((t), powerGeneration(scenario, t, plants, country) * Plants_carbonEmissions(plants) * CarbonEmissionEfficiencyScenarioFactor(plants));
*carbonEmissionCosts_EQ(country, plants)..                          carbonEmissionCosts(country, plants) =e= sum((t), powerGeneration(scenario, t, plants, country)) * Plants_carbonEmissions(plants) * CarbonEmissionEfficiencyScenarioFactor(plants) * CO2Price;
$offText

***     investment costs
capacityCosts(country)..                                                        totalInvestmentCosts =e= sum((plants), plants_Capacities(plants, country) * InvestmentCosts(plants));


***     water power constraint
waterConstraint(country)..                                                      sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants, country)) * WaterCapacitieFactors(country) =g= sum((constraintInvestsPlants), Plants_capacities(constraintInvestsPlants, country));


***     for some analysis
overallLoad_EQ(scenario, plants)..                                              overallLoad(plants) =e= sum((country, t), powerGeneration(scenario, t, plants, country));


***     total costs - to be minimized
total_cost..                                                                    TC =e= sum((scenario, t, plants, country),  powerGeneration(scenario, t, plants, country) * OperatingCosts(plants))  + totalInvestmentCosts;


Model epmProject /all/;


***Stage 1
*Solve epmProject using LP minimising TC;
*StageOneInvestmentsDecision(plants, country) = buildCapacities.l(plants, country);
 
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
    StageOneInvestmentData(scenarioStageOne, plants, country) = buildCapacities.l(plants, country);
    Display TC.l, CurrentStageOneScenario, buildCapacities.l, totalInvestmentCosts.l;
   
);

*** Stage 2
loop(scenarioStageTwo,
   ScenarioProbability= ScenarioData(scenarioStageTwo, 'probability');
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
$offText

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