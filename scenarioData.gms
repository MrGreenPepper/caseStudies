
*Alias(scenario, scenarioStageOne);
*Alias(scenario, scenarioStageTwo);


Scalar
EVPI
VSS_max
Z_PI
Z_DP
;

Parameter 
ScenarioProbability(scenario)           /s1 0.5, s2 0.3, s3 0.2/
Z_SP(scenario)
StageOneInvestmentData(scenario, plants)
StageOneInvestmentsDecision(plants)
;

loop(plants,

        StageOneInvestmentsDecision(plants) = 0;
 
);