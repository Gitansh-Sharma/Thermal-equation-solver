clc;
clear;

addpath(genpath('src'));

network = createThermalNetwork();

% Nodes
network = addThermalNode(network,"boundary",500);
network = addThermalNode(network,"internal",NaN);
network = addThermalNode(network,"internal",NaN);
network = addThermalNode(network,"internal",NaN);
network = addThermalNode(network,"internal",NaN);
network = addThermalNode(network,"boundary",300);


%% Conduction: Node 1 -> 2

parameters.L = 0.02;
parameters.k = 5;
parameters.A = 0.5;

network = addThermalEdge( ...
    network,1,2,"conduction","parameters",parameters);


%% Contact: Node 2 -> 3

parameters.Rc = 0.010;

network = addThermalEdge( ...
    network,2,3,"contact","parameters",parameters);


%% Convection: Node 2 -> 4

parameters.h = 80;
parameters.A = 0.5;

network = addThermalEdge( ...
    network,2,4,"convection","parameters",parameters);


%% Direct resistance: Node 3 -> 5

parameters.R = 0.010;

network = addThermalEdge( ...
    network,3,5,"conduction","direct",parameters);


%% Direct resistance: Node 4 -> 5

parameters.R = 0.025;

network = addThermalEdge( ...
    network,4,5,"conduction","direct",parameters);


%% Final resistance: Node 5 -> 6

parameters.R = 0.010;

network = addThermalEdge( ...
    network,5,6,"conduction","direct",parameters);


%% Display network

disp(network.graph);

disp(network.graph.Edges);


%% Calculate equivalent resistance

Req = calculateNetworkResistance(network,1,6);

fprintf('\nEquivalent Thermal Resistance = %.9f K/W\n',Req);