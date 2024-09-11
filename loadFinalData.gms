

Sets
t /t1*t8760/
scenario /s1*s3/
snaps /snap1*snap4/
plants /windOff, windOn, water, biomass, solar, waste, geothermal, lignite, nuclear, hardcoal, gas, oil, pumpedStoragesPlants, battery, reservoirStorages/
conventionalPlants(plants) /lignite, nuclear, hardcoal, gas, oil/
baseLoadPlants(plants)      /lignite, hardcoal/
renewablePlants(plants) /windOff, windOn, water, biomass, solar, waste, reservoirStorages/
constraintInvestsPlants(plants)       /water, reservoirStorages/
storages(plants)

;





$call gdxxrw.exe powerDemand.xlsx par=PowerDemand rng=gams!A5:D8765 dim=2 cdim=1 rdim=1 log=log_powerDemand.txt
Parameter PowerDemand(t, scenario)
$gdxIn powerDemand.gdx
$load PowerDemand
$gdxIn
;



Scalar
WaterCapacitieFactors /3.793961864/
;

Parameter StorageCapacity(storages);
$call csv2gdx storageCapacities_2019_final.csv output=storageCapacity.gdx id=storageCapacity fieldSep=semiColon decimalSep=comma colCount=2 index=1 value=2 useHeader=y trace=1
$gdxIn storageCapacity.gdx
$load storages = dim1
*$load country = dim2
$load StorageCapacity = storageCapacity
$gdxIn
;

$call gdxxrw.exe installedCapacities_2019_01_final.xlsx par=Plants_capacities rng=Sheet1!A1:B15 dim=1 cdim=0 rdim=1 log=log_plantCapacities.txt
Parameter Plants_capacities(plants)
$gdxIn installedCapacities_2019_01_final.gdx
$load Plants_capacities
$gdxIn
;

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

$call gdxxrw.exe carbonEmission_2019.xlsx par=Plants_carbonEmissions rng=Sheet1!A2:B15 rdim=1 cdim=0 log=log_carbEm.txt
Parameter Plants_carbonEmissions(plants)
$gdxIn carbonEmission_2019.gdx
$load Plants_carbonEmissions
$gdxIn
;

$call gdxxrw.exe plant_efficiency.xlsx par=carbonEmissionEfficiencyFactor rng=Sheet1!A2:B5 rdim=1 cdim=0 log=log_carbEmEff.txt
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