function kvar=variableThermalConductivity(T,inputvariablek)
kvar=inputvariablek.ko.*(1+inputvariablek.beta.*(T-inputvariablek.Tref));
end