
Set
scenario /s1*s2/
scenarioProp /probaility, factor/
;

Scalar
Probability
Factor
;

Parameter Table
ScenarioData(scenario, scenarioProp)
        probaility          factor
s1      0.2                 2
s2      0.8                 1
;


Positive Variable
q_sell
profit
;

Equations
profit_eq
q_con
;

profit_eq(scenarioProp)..                 profit =e= q_sell *Probability  *Factor ;
q_con..                                   q_sell =l= 100;


Model test /all/;


loop(scenario,
   Probability= ScenarioData(scenario, 'probaility');
   Factor= ScenarioData(scenario, 'factor');
 Solve test using LP maximizing profit;
);
