
Sets
t /t1*t8760/
snaps /snap1*snap4/
plants /windOff, windOn, water, biomass, solar, waste, geothermal, lignite, nuclear, hardcoal, gas, oil, pumpedStoragesPlants, battery, reservoirStorages/
conventionalPlants(plants) /lignite, nuclear, hardcoal, gas, oil/
renewablePlants(plants) /windOff, windOn, water, biomass, solar, waste, geothermal/
storages(plants)
country /DE, FR, BNL/
;            


Parameter storageCapacity(storages, country);
$call csv2gdx storageCapacities_2019_final.csv output=storageCapacity.gdx id=storageCapacity fieldSep=semiColon decimalSep=comma colCount=3 index=1,2 value=3 useHeader=y trace=1
$gdxIn storageCapacity.gdx
$load storages = dim1
*$load country = dim2
$load storageCapacity = storageCapacity
$gdxIn
;

$call gdxxrw.exe powerDemand_2019.xlsx par=PowerDemand rng=Sheet1!A1:D8761 dim=2 cdim=1 rdim=1 log=log_powerDemand.txt
Parameter PowerDemand(t, country)
$gdxIn powerDemand_2019.gdx
$load PowerDemand
$gdxIn
;


$call gdxxrw.exe installedCapacities_2019_01_final.xlsx par=Plants_capacities rng=Sheet1!A1:D15 dim=2 cdim=1 rdim=1 log=log_plantCapacities.txt
Parameter Plants_capacities(plants, country)
$gdxIn installedCapacities_2019_01_final.gdx
$load Plants_capacities
$gdxIn
;


$call gdxxrw.exe capFactors.xlsx par=CapacityFactor rng=Tabelle2!A1:G8761 dim=2 cdim=1 rdim=1 log=log_capacityFactors.txt
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

$call gdxxrw.exe InvestmentCosts.xlsx par=InvestmentCosts rng=Sheet1!A2:B18 rdim=1 cdim=0 log=log_investC.txt
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

Parameters
DiscountRate /0.02740/
InvestLifeTime / 30/
AnnuelFactor

*Plants_carbonEmissions(plants)      /wind 10, gas 50, battery 1/
*InvestmentCosts(plants)             /wind 100, gas 100, battery 10/
*OperatingCosts(plants)              /wind 1, gas 15, battery 2, reservoirStorages 1/


;



$onText

$offText
*import larger tabels like PowerDemand and plant data from excel






