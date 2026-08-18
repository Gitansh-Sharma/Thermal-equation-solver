function heatFlux=calculateHeatFlux(inputs,solution)

heatFlux=-inputs.k*solution.dtdx;
end
