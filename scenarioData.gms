
Set
scenario /s1*s2/
scenarioProp /probability, factor/
;
Alias(scenario, scenarioStageOne);
Alias(scenario, scenarioStageTwo);


Scalar
ScenarioProbability
ScenarioFactor
EVPI
VSS_max
Z_PI
Z_DP
;
Parameter Table
ScenarioData(scenario, scenarioProp)
        probability     factor
s1      0.2             1.5
s2      0.8             1
;

Parameter
Z_SP(scenario)
StageOneInvestmentData(scenario, plants)
StageOneInvestmentsDecision(plants)
;

loop(plants,

        StageOneInvestmentsDecision(plants) = 0;
 
);