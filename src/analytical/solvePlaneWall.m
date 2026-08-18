function solution = solvePlaneWall(inputs)

x = linspace(0, inputs.t, inputs.N);

L = inputs.t;
k = inputs.k;
qgen = inputs.qgen;
% T(x) = C1 + C2*x - (qgen/(2*k))*x^2
% dT/dx = C2 - (qgen/k)*x

A = zeros(2,2);
b = zeros(2,1);

switch inputs.BC.left.type

    case 1
        % Specified temperature
    
        A(1,1) = 1;
        A(1,2) = 0;

        b(1) = inputs.BC.left.T;

    case 2
        % Specified heat flux

        A(1,1) = 0;
        A(1,2) = -k;

        b(1) = inputs.BC.left.q;

    case 3
        % Insulated
       
        A(1,1) = 0;
        A(1,2) = 1;

        b(1) = 0;
    case 4
        % Convection Boundary Condition
        A(1,1) = inputs.BC.left.h;
        A(1,2) = -k;

        b(1) = inputs.BC.left.h * inputs.BC.left.Tinf;
    otherwise
        error('Invalid left boundary condition.');

end


switch inputs.BC.right.type

    case 1
        % Specified temperature
        A(2,1) = 1;
        A(2,2) = L;

        b(2) = inputs.BC.right.T + ...
            (qgen/(2*k))*L^2;

    case 2
        % Specified heat flux
        A(2,1) = 0;
        A(2,2) = -k;

        b(2) = inputs.BC.right.q - qgen*L;

    case 3
        % Insulated
        %
        % dT/dx = 0

        A(2,1) = 0;
        A(2,2) = 1;

        b(2) = qgen*L/k;
    
    case 4
        A(2,1)=inputs.BC.right.h;
        A(2,2)=(inputs.BC.right.h*inputs.t) + inputs.k;

        b(2)=(inputs.BC.right.h)*(inputs.BC.right.Tinf) + (inputs.qgen*inputs.t)+ ((inputs.BC.right.h*inputs.qgen*(inputs.t)^2)/(2*inputs.k));
    otherwise
        error('Invalid right boundary condition.');

end
C = A\b;

C1 = C(1);
C2 = C(2);

T = C1 + C2.*x -(qgen/(2*k)).*x.^2;

dTdx = C2 -(qgen/k).*x;

solution.x = x;

solution.T = T;

solution.dtdx = dTdx;

solution.C1 = C1;

solution.C2 = C2;

solution.T_left=C1;

solution.T_right= C1 + C2*L -(qgen/(2*k))*L^2;

if qgen > 0

    % dT/dx = 0
    x_Tmax = (k*C2)/qgen;

    % whether the maximum lies inside the wall
    if x_Tmax >= 0 && x_Tmax <= L

        T_max = C1 + C2*x_Tmax -(qgen/(2*k))*x_Tmax^2;

    else

        % Maximum occurs at one of the boundaries
        if T_left >= T_right
            T_max = T_left;
            x_Tmax = 0;
        else
            T_max = T_right;
            x_Tmax = L;
        end

    end

else

    % No heat generation → linear temperature profile
    if T_left >= T_right
        T_max = T_left;
        x_Tmax = 0;
    else
        T_max = T_right;
        x_Tmax = L;
    end

end

solution.T_max = T_max;
solution.x_Tmax = x_Tmax;

end