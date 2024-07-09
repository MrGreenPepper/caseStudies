Set
*i /i1*i6/
i /i6/ 
;


Parameter PowerDemandFactors(i);
$call csv2gdx scenarios.csv output=scenarios.gdx id=PowerDemandFactors fieldSep=semiColon decimalSep=comma colCount=3 index=1 value=2 useHeader=y trace=1
$gdxIn scenarios.gdx
*$load i = dim1
*$load country = dim2
$load PowerDemandFactors = PowerDemandFactors
$gdxIn
;

Parameter CarbonCaps(i);
$call csv2gdx scenarios.csv output=scenarios.gdx id=CarbonCaps fieldSep=semiColon decimalSep=comma colCount=3 index=1 value=3 useHeader=y trace=1
$gdxIn scenarios.gdx
*$load i = dim1
*$load country = dim2
$load CarbonCaps = CarbonCaps
$gdxIn
;

Parameter
*CarbonCaps(i) /i1 500000000000000000000, i2 40000000000000000000000, i3 30000000000000000000000, i4 2000000000000000000000000000/
TotalCarbonCap
PowerDemandFactor
*PowerDemandFactors(i)    /i1 1.5, i2 0.9, i3 1.2, i4 1.5/
;

$call gdxxrw.exe politicalDecisions.xlsx par=PoliticalDecisions rng=Sheet1!A1:H46 dim=3 cdim=1 rdim=2 log=log_polDe.txt
Parameter PoliticalDecisions(plants, country, i)
$gdxIn politicalDecisions.gdx
$load PoliticalDecisions
$gdxIn
;