
Set
scenario /s1*s2/
scenarioProp /probaility, factor/
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
        probaility          factor
s1      0.2                 10000000
s2      0.8                 0.001
;

Parameter
Z_SP(scenario)
StageOneInvestmentData(scenario, plants, country)
StageOneInvestmentsDecision(plants, country)
;

loop(plants,
    loop(country,
        StageOneInvestmentsDecision(plants, country) = 0;
    );
);