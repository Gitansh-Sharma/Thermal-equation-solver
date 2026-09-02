function heatFluxFD=calculateHeatFluxFD(inputs,solutionFD)

T=solutionFD.T;
dx=solutionFD.dx;

if inputs.thermalchoice==0
    k=inputs.k;
else
    k=variableThermalConductivity(T,inputs.variablek);
end

N=length(T);

heatFluxFD=zeros(N,1);

heatFluxFD(1)=-k(1)*(-3*T(1)+4*T(2)-T(3))/(2*dx);

for i=2:N-1
    heatFluxFD(i)=-k(i)*(T(i+1)-T(i-1))/(2*dx);
end

heatFluxFD(N)=-k(N)*(3*T(N)-4*T(N-1)+T(N-2))/(2*dx);

end