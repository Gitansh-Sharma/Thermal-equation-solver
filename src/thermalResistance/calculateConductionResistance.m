function R = calculateConductionResistance(L, k, A)

% calculateConductionResistance
% Calculates conduction thermal resistance of a plane-wall layer.
%
% R = L / (k*A)
%
% Inputs:
%   L - Layer thickness [m]
%   k - Thermal conductivity [W/m-K]
%   A - Cross-sectional area [m^2]
%
% Output:
%   R - Thermal resistance [K/W]

if L <= 0
    error('Layer thickness must be greater than zero.');
end

if k <= 0
    error('Thermal conductivity must be greater than zero.');
end

if A <= 0
    error('Area must be greater than zero.');
end

R = L/(k*A);

end