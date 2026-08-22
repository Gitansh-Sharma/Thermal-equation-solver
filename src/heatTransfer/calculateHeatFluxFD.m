function heatFluxFD = calculateHeatFluxFD(inputs, solutionFD)

k = inputs.k;

T = solutionFD.T;
dx = solutionFD.dx;

N = length(T);

heatFluxFD = zeros(N,1);

heatFluxFD(1) = -k * (T(2) - T(1)) / dx;

for i = 2:N-1

    heatFluxFD(i) = -k *(T(i+1) - T(i-1)) / (2*dx);

end

heatFluxFD(N) = -k *(T(N) - T(N-1)) / dx;

end