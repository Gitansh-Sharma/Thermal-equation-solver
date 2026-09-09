function Req = calculateNetworkResistance(network, hotNode, coldNode)

G = network.graph;

T_hot = 1;
T_cold = 0;

n = numnodes(G);

internalNodes = setdiff(1:n, [hotNode coldNode]);

K = zeros(n,n);

for e = 1:numedges(G)

    node1 = G.Edges.EndNodes(e,1);
    node2 = G.Edges.EndNodes(e,2);

    R = G.Edges.Weight(e);

    conductance = 1/R;

    K(node1,node1) = K(node1,node1) + conductance;
    K(node2,node2) = K(node2,node2) + conductance;

    K(node1,node2) = K(node1,node2) - conductance;
    K(node2,node1) = K(node2,node1) - conductance;

end

K_internal = K(internalNodes,internalNodes);

b = -(K(internalNodes,hotNode)*T_hot + ...
      K(internalNodes,coldNode)*T_cold);

T_internal = K_internal\b;

T = zeros(n,1);

T(hotNode) = T_hot;
T(coldNode) = T_cold;
T(internalNodes) = T_internal;

Q_hot = 0;

for e = 1:numedges(G)

    node1 = G.Edges.EndNodes(e,1);
    node2 = G.Edges.EndNodes(e,2);

    R = G.Edges.Weight(e);

    if node1 == hotNode
        Q_hot = Q_hot + (T(node1)-T(node2))/R;

    elseif node2 == hotNode
        Q_hot = Q_hot + (T(node2)-T(node1))/R;
    end

end

Req = (T_hot-T_cold)/Q_hot;

end