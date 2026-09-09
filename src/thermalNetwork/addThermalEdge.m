function network = addThermalEdge(network, from, to, type, InputMode,parameters)

id = numel(network.edges) + 1;

Rth = calculateThermalResist(type, InputMode, parameters);

network.edges(id).id = id;
network.edges(id).from = from;
network.edges(id).to = to;
network.edges(id).type = type;
network.edges(id).R = Rth;

network.graph = addedge(network.graph, from, to, Rth);

end