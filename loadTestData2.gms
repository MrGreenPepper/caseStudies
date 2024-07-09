
Sets
i loop stages /i1*i4/
t time steps /t1*t5/
snaps /snap1*snap4/
plants /wind, gas, battery, reservoirStorages/
conventionalPlants(plants) /gas/
renewablePlants(plants) /wind/
storages(plants)
country 
country_exp /DE, FR/
;            


Parameter storageCapacity(storages, country);

$call csv2gdx test.csv output=testcsv.gdx id=testId fieldSep=semiColon decimalSep=comma colCount=3 index=1,2 value=3 useHeader=y trace=1
$gdxIn testcsv.gdx
$load storages = dim1
$load country = dim2
$load storageCapacity = testId
$gdxIn
;

$onText
Set Table
map_pc(plants,country);
map_pc('wind_fr','FR')= YES;
map_pc('wind','DE')=YES;
map_pc('gas','DE')=YES;
map_pc('gas_fr','FR')=YES;
map_pc('battery','DE')=YES;
map_pc('battery_fr','FR')=YES;
$offText

Parameters
CarbonCaps(i) /i1 50000, i2 40000, i3 30000, i4 20000/
TotalCarbonCap
DiscountRate /0.02740/
InvestLifeTime / 30/
AnnuelFactor

Plants_carbonEmissions(plants)      /wind 10, gas 50, battery 1/
InvestmentCosts(plants)             /wind 100, gas 100, battery 10/
OperatingCosts(plants)              /wind 1, gas 20, battery 2, reservoirStorages 1/


;

Table
PowerDemand(t, country)                         
    DE          FR
t1  100         100
t2  200         200
t3  100         100
t4  100         100
;

Table
Plants_availability(plants, country)
            DE          FR
wind        100         100
gas         100         100
battery     100         100
;  

Table
Plants_capacities(plants, country)
            DE          FR
wind        100         100
gas         500         100
;

*import larger tabels like PowerDemand and plant data from excel
Table
SnapData(snaps, t, country)
            DE          FR
snap1.t1    100         100
snap1.t2    600         600                       
snap2.t1    100         100
snap2.t2    100         100
snap3.t1    100         100
snap3.t2    100         100
snap4.t1    100         100
snap4.t2    100         100  
;






