function heatFluxFD = calculateHeatFluxFD(inputs, solutionFD)

    k = inputs.k;

    T = solutionFD.T;
    dx = solutionFD.dx;

    N = length(T);

    heatFluxFD = zeros(N,1);

    % Left boundary: second-order forward difference
    heatFluxFD(1) = -k * ...
        (-3*T(1) + 4*T(2) - T(3)) / (2*dx);

    % Interior nodes: central difference
    for i = 2:N-1

        heatFluxFD(i) = -k * ...
            (T(i+1) - T(i-1)) / (2*dx);

    end

    % Right boundary: second-order backward difference
    heatFluxFD(N) = -k * ...
        (3*T(N) - 4*T(N-1) + T(N-2)) / (2*dx);

end