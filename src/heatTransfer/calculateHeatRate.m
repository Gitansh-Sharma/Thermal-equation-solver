function heatRate=calculateHeatRate(inputs,heatFlux)

qleft=-heatFlux(1);
qright=heatFlux(end);

heatRate.left=qleft*inputs.a;
heatRate.right=qright*inputs.a;

heatRate.generated=inputs.qgen*inputs.a*inputs.t;


end