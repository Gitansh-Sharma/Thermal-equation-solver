function solutionp = solveParallelNetwork(parallel)

% solveParallelNetwork
% Calculates equivalent thermal resistance of
% parallel conduction paths.
%
% Assumptions:
% - Plane wall
% - Constant thermal conductivity
% - All paths are in parallel
% - Same temperature difference across each path

nPaths = parallel.nPaths;

if nPaths < 2
    error('A parallel network must have at least two paths.');
end

R = zeros(1,nPaths);

% Calculate resistance of each parallel path
for i = 1:nPaths

    R(i) = calculateConductionResistance(parallel.paths(i).L,parallel.paths(i).k,parallel.paths(i).A);

end

% Equivalent parallel resistance
Rparallel = 1 / sum(1 ./ R);

% Total heat transfer rate
Q = (parallel.Thot - parallel.Tcold) / Rparallel;

% Heat transfer rate through each path
Qpath = zeros(1,nPaths);

for i = 1:nPaths

    Qpath(i) = (parallel.Thot - parallel.Tcold) / R(i);

end

% Store results
solutionp.R = R;
solutionp.Rparallel = Rparallel;
solutionp.Q = Q;
solutionp.Qpath = Qpath;

end