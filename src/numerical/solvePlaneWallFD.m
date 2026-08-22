function solutionFD = solvePlaneWallFD(inputs)

L = inputs.t;
k = inputs.k;
qgen = inputs.qgen;
N = inputs.N;

BC = inputs.BC;

sigma = 5.670374419e-8;

x = linspace(0, L, N);

dx = x(2) - x(1);

tolerance = 1e-6;
maxIter = 100;

if BC.left.type == 5

    Tinitial = BC.left.Tsurr;

elseif BC.right.type == 5

    Tinitial = BC.right.Tsurr;

elseif BC.left.type == 1

    Tinitial = BC.left.T;

elseif BC.right.type == 1

    Tinitial = BC.right.T;

else

    Tinitial = 300;

end

T = ones(N,1) * Tinitial;

for iter = 1:maxIter

    F = zeros(N,1);

    J = zeros(N,N);

    switch BC.left.type

        case 1

            F(1) = T(1) - BC.left.T;

            J(1,1) = 1;

        case 2

            F(1) = -k * (T(2) - T(1)) / dx ...
                   - BC.left.q ...
                   + qgen * dx / 2;

            J(1,1) = k/dx;
            J(1,2) = -k/dx;

        case 3

            F(1) = T(2) - T(1) ...
                   + qgen * dx^2 / (2*k);

            J(1,1) = -1;
            J(1,2) = 1;

        case 4

            F(1) = -k * (T(2) - T(1)) / dx ...
                   - BC.left.h * (T(1) - BC.left.Tinf) ...
                   + qgen * dx / 2;

            J(1,1) = k/dx - BC.left.h;
            J(1,2) = -k/dx;

        case 5

            epsilon = BC.left.emissivity;
            Tsurr = BC.left.Tsurr;

            F(1) = k * (T(2) - T(1)) / dx ...
                   - epsilon * sigma * ...
                   (T(1)^4 - Tsurr^4) ...
                   + qgen * dx / 2;

            J(1,1) = -k/dx ...
                     - 4 * epsilon * sigma * T(1)^3;

            J(1,2) = k/dx;

    end

    for i = 2:N-1

        F(i) = T(i-1) ...
             - 2*T(i) ...
             + T(i+1) ...
             + qgen * dx^2 / k;

        J(i,i-1) = 1;
        J(i,i) = -2;
        J(i,i+1) = 1;

    end

    switch BC.right.type

        case 1

            F(N) = T(N) - BC.right.T;

            J(N,N) = 1;

        case 2

            F(N) = -k * (T(N) - T(N-1)) / dx ...
                   - BC.right.q ...
                   + qgen * dx / 2;

            J(N,N-1) = k/dx;
            J(N,N) = -k/dx;

        case 3

            F(N) = T(N) - T(N-1) ...
                   + qgen * dx^2 / (2*k);

            J(N,N-1) = -1;
            J(N,N) = 1;

        case 4

            F(N) = -k * (T(N) - T(N-1)) / dx ...
                   - BC.right.h * ...
                   (T(N) - BC.right.Tinf) ...
                   + qgen * dx / 2;

            J(N,N-1) = k/dx;

            J(N,N) = -k/dx ...
                     - BC.right.h;

        case 5

            epsilon = BC.right.emissivity;
            Tsurr = BC.right.Tsurr;

            F(N) = (k/dx) * ...
                   (T(N-1) - T(N)) ...
                   - epsilon * sigma * ...
                   (T(N)^4 - Tsurr^4) ...
                   + qgen * dx / 2;

            J(N,N-1) = k/dx;

            J(N,N) = -k/dx ...
                     - 4 * epsilon * sigma * T(N)^3;

    end

    deltaT = -J \ F;

    Tnew = T + deltaT;

    if max(abs(deltaT)) < tolerance

        T = Tnew;

        break;

    end

    T = Tnew;

end

solutionFD.x = x;

solutionFD.T = T(:);

solutionFD.dx = dx;

solutionFD.iterations = iter;

solutionFD.converged = max(abs(deltaT)) < tolerance;

solutionFD.residual = max(abs(F));

end