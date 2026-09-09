clc;
clear;

addpath(genpath('src'));

network = createThermalNetwork();

network = addThermalNode(network,"boundary",500);
network = addThermalNode(network,"internal",NaN);
network = addThermalNode(network,"internal",NaN);
network = addThermalNode(network,"internal",NaN);
network = addThermalNode(network,"internal",NaN);
network = addThermalNode(network,"boundary",300);

network = addThermalEdge(network,1,2,"conduction",0.01);
network = addThermalEdge(network,2,3,"conduction",0.02);
network = addThermalEdge(network,2,4,"conduction",0.040);
network = addThermalEdge(network,4,5,"conduction",0.050);
network = addThermalEdge(network,3,5,"conduction",0.030);
network = addThermalEdge(network,5,6,"conduction",0.010);


weights = network.graph.Edges.Weight;

labels = strings(numedges(network.graph),1);

for i = 1:numedges(network.graph)
    labels(i) = sprintf('%.4f K/W', weights(i));
end

figure;

p = plot(network.graph);

labeledge(p, 1:numedges(network.graph), labels);

disp(network.graph);

Req = calculateNetworkResistance(network,1,6);

fprintf('\nEquivalent Thermal Resistance = %.6f K/W\n', Req);
