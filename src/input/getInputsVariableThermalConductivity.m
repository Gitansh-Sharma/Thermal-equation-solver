function inputvariablek = getInputsVariableThermalConductivity()

fprintf('\n Equation for thermla conductivity is K(T)=ko(1+beta(T-Tref)');
inputvariablek.beta=input('\n Enter the value of constant Beta: ');

inputvariablek.Tref=input('\n Enter the reference temperature (Tref in K): ');
inputvariablek.ko = input('\n Enter the value of constant ko: ');

end