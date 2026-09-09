function Req = calculateNetworkResistance(network, hotNode, coldNode)

G = network.graph;

% Check that hot and cold nodes are different
if hotNode == coldNode
    error("Hot and cold nodes must be different.");
end

% Set normalized boundary temperatures
T_hot = 1;
T_cold = 0;

n = numnodes(G);

% Identify unknown temperature nodes
internalNodes = setdiff(1:n, [hotNode coldNode]);

% Initialize conductance matrix
K = zeros(n,n);

% Build nodal conductance matrix
for e = 1:numedges(G)

    node1 = G.Edges.EndNodes(e,1);
    node2 = G.Edges.EndNodes(e,2);

    Rth = G.Edges.Weight(e);

    if Rth <= 0
        error("Thermal resistance must be greater than zero.");
    end

    Gth = 1/Rth;

    K(node1,node1) = K(node1,node1) + Gth;
    K(node2,node2) = K(node2,node2) + Gth;

    K(node1,node2) = K(node1,node2) - Gth;
    K(node2,node1) = K(node2,node1) - Gth;

end

% Extract equations for internal nodes
K_internal = K(internalNodes, internalNodes);

b = -(K(internalNodes,hotNode) * T_hot +K(internalNodes,coldNode) * T_cold);

% Solve internal node temperatures
T_internal = K_internal \ b;

% Store temperatures of all nodes
T = zeros(n,1);

T(hotNode) = T_hot;
T(coldNode) = T_cold;
T(internalNodes) = T_internal;

% Calculate total heat entering through hot boundary
Q_hot = 0;

for e = 1:numedges(G)

    node1 = G.Edges.EndNodes(e,1);
    node2 = G.Edges.EndNodes(e,2);

    Rth = G.Edges.Weight(e);

    if node1 == hotNode

        Q_hot = Q_hot + (T(node1) - T(node2))/Rth;

    elseif node2 == hotNode

        Q_hot = Q_hot + (T(node2) - T(node1))/Rth;

    end

end

% Equivalent thermal resistance
Req = (T_hot - T_cold)/Q_hot;

end