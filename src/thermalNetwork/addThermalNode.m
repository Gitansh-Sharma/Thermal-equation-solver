function network = addThermalNode(network, type, T)

id = numel(network.nodes) + 1;

network.nodes(id).id = id;
network.nodes(id).type = type;
network.nodes(id).T = T;

network.graph = addnode(network.graph, 1);

end