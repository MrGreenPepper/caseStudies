
Set
scenario /s1*s2/
scenarioProp /probaility, factor/

;

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
s1      0.2                 2
s2      0.8                 1
;

Parameter
Z_SP(scenario)
;