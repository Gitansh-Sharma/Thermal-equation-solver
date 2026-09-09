function network = addThermalEdge(network, from, to, type, R)

id = numel(network.edges) + 1;

network.edges(id).id = id;
network.edges(id).from = from;
network.edges(id).to = to;
network.edges(id).type = type;
network.edgse(id).R=R;


network.graph=addedge(network.graph,from,to,R);

end