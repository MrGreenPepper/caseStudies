
Sets
i loop stages /i1*i4/
t time steps /t1*t5/
snaps /snap1*snap4/
plants /wind_de, gas_de, battery_de, wind_fr, gas_fr,battery_fr/
conventionalPlants(plants) /gas_de,gas_fr/
renewablePlants(plants) /wind_de, wind_fr/
storages(plants) /battery_de, battery_fr/
country /DE, FR/
country_exp /Germany, France/
;            


$onText
Set Table
map_pc(plants,country);
map_pc('wind_fr','France')= YES;
map_pc('wind_de','Germany')=YES;
map_pc('gas_de','Germany')=YES;
map_pc('gas_fr','France')=YES;
map_pc('battery_de','Germany')=YES;
map_pc('battery_fr','France')=YES;
$offText

Parameters
CarbonCaps(i) /i1 50000, i2 40000, i3 30000, i4 20000/
TotalCarbonCap
DiscountRate /0.02740/
InvestLifeTime / 30/
AnnuelFactor        
Plants_carbonEmissions(plants)      /wind_de 10, gas_de 50, battery_de 1, wind_fr 10, gas_fr 50, battery_fr 1/
InvestmentCosts(plants)             /wind_de 100, gas_de 100, battery_de 1, wind_fr 150, gas_fr 100, battery_fr 1/
OperatingCosts(plants)              /wind_de 10, gas_de 15, battery_de 1, wind_fr 10, gas_fr 15, battery_fr 1/
;

*Parameter storageCapacity(storages)   /battery_de 1000, battery_fr 1000/;

*$onText
Table storageCapacity(storages, country)       
                DE          FR
battery_de      1000        0
battery_fr      0           1000
;
*$offText

Table
Plants_capacities(plants, country)
                DE          FR
wind_de         200         0
gas_de          200         0
wind_fr         0           200
gas_fr          0           200
;


Table
PowerDemand(t, country)                         
    DE          FR
t1  100         100
t2  200         200
t3  400         600
t4  100         100
;

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
Table
Plants_availability(plants, country)
            DE          FR
wind_de     100         0
wind_fr     0           100
gas_de      100         0
gas_fr      0           100
battery_de  100         0
battery_fr  0           100
;  

*import larger tabels like PowerDemand and plant data from excel







