function solutionc = solveCompositeWall(composite)

% solveCompositeWall
% Calculates thermal resistance and heat transfer
% through a plane-wall composite system.
% Required fields:
%   composite.nLayers
%   composite.layers(i).L
%   composite.layers(i).k
%   composite.layers(i).A
%   composite.Thot
%   composite.Tcold

nLayers = composite.nLayers;

if nLayers < 1
    error('Number of layers must be at least 1.');
end

R = zeros(1,nLayers);

% Calculate resistance of each layer
for i = 1:nLayers

    R(i) = calculateConductionResistance(composite.layers(i).L,composite.layers(i).k,composite.layers(i).A);

end

Rcontact = sum(composite.contactResistance);

% Total resistance for series layers
Rtotal = sum(R) + Rcontact;

% Total heat-transfer rate
Q = (composite.Thot - composite.Tcold)/Rtotal;

% Heat flux
% For Version 1, use the area of the first layer.
A = composite.layers(1).A;

q = Q/A;

% Interface temperatures
Tinterface = zeros(1,nLayers-1);

Tcurrent = composite.Thot;

for i = 1:nLayers-1

    Tcurrent = Tcurrent - Q*R(i);
    
    Tcurrent = Tcurrent - Q*composite.contactResistance(i);
    
    Tinterface(i) = Tcurrent;

end

% Store results
solutionc.R = R;
solutionc.Rtotal = Rtotal;
solutionc.Q = Q;
solutionc.q = q;
solutionc.Tinterface = Tinterface;
solutionc.Rcontact = Rcontact;

end