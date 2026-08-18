clc;
clear all;

addpath(genpath('src'));

fprintf('========================================\n');
fprintf('       1-D HEAT CONDUCTION SOLVER\n');
fprintf('========================================\n\n');

fprintf('Select Geometry: \n');
fprintf('1. Plane Wall\n');
fprintf('2. Cylinder\n');
fprintf('3. Sphere\n');
fprintf('4. Cone\n');

geometryc = input('Enter the number of your desired geometry: ');

if geometryc == 1

    inputs = getInputs();
    validateInputs(inputs);
    geometry = PlaneWall(inputs);

    solution = solvePlaneWall(inputs);

    heatFlux = calculateHeatFlux(inputs, solution);
    heatRate = calculateHeatRate(inputs, heatFlux);
    validation = verifyBoundaryConditions(inputs, solution, heatFlux);
    fprintf('\n========================================\n');
    fprintf('                RESULTS\n');
    fprintf('========================================\n');

    fprintf('Geometry              : Plane Wall\n');
    fprintf('Thermal Conductivity  : %.4f W/m-K\n', inputs.k);
    fprintf('Thickness             : %.4f m\n', inputs.t);
    fprintf('Area                  : %.4f m^2\n', inputs.a);

    fprintf('\n----------------------------------------\n');
    fprintf('THERMAL RESULTS\n');
    fprintf('----------------------------------------\n');

    fprintf('\nLeft Boundary (x = 0):\n');

    switch inputs.BC.left.type

        case 1
            fprintf('Boundary Condition   : Specified Temperature\n');
            fprintf('Temperature           : %.2f K\n', inputs.BC.left.T);

        case 2
            fprintf('Boundary Condition   : Specified Heat Flux\n');
            fprintf('Specified Heat Flux   : %.4f W/m^2\n', inputs.BC.left.q);

        case 3
            fprintf('Boundary Condition   : Insulated\n');
            fprintf('Heat Flux             : 0 W/m^2\n');

        case 4
            fprintf('Boundary Condition   : Convection\n');
            fprintf('Convection Coefficient: %.4f W/m^2-K\n', inputs.BC.left.h);
            fprintf('Fluid Temperature     : %.2f K\n', inputs.BC.left.Tinf);

    end

    fprintf('\nRight Boundary (x = L):\n');

    switch inputs.BC.right.type

        case 1
            fprintf('Boundary Condition   : Specified Temperature\n');
            fprintf('Temperature           : %.2f K\n', inputs.BC.right.T);

        case 2
            fprintf('Boundary Condition   : Specified Heat Flux\n');
            fprintf('Specified Heat Flux   : %.4f W/m^2\n', inputs.BC.right.q);

        case 3
            fprintf('Boundary Condition   : Insulated\n');
            fprintf('Heat Flux             : 0 W/m^2\n');
        
        case 4
            fprintf('Boundary Condition   : Convection\n');
            fprintf('Convection Coefficient: %.4f W/m^2-K\n', inputs.BC.right.h);
            fprintf('Fluid Temperature     : %.2f K\n', inputs.BC.right.Tinf);
    end

    fprintf('\n----------------------------------------\n');
    fprintf('HEAT TRANSFER RESULTS\n');
    fprintf('----------------------------------------\n');

    fprintf('Heat Flux at x = 0   : %.4f W/m^2\n', heatFlux(1));
    fprintf('Heat Flux at x = L   : %.4f W/m^2\n', heatFlux(end));

    fprintf('Heat Rate - Left     : %.4f W\n', heatRate.left);
    fprintf('Heat Rate - Right    : %.4f W\n', heatRate.right);

    if inputs.heatGeneration == 1

        fprintf('Heat Generation      : %.4f W/m^3\n', inputs.qgen);

        fprintf('Total Heat Generated : %.4f W\n', ...
            heatRate.generated);

        energyBalanceError = abs( ...
            heatRate.generated - ...
            (heatRate.left + heatRate.right)) ...
            / heatRate.generated * 100;

        fprintf('Energy Balance Error : %.6f %%\n', ...
            energyBalanceError);

    else

        fprintf('Heat Generation      : None\n');

        fprintf('Heat Transfer Rate   : %.4f W\n', ...
            heatRate.right);

    end
    
    fprintf('\nMaximum Temperature : %.4f K\n', solution.T_max);
    fprintf('Location of Tmax    : %.4f m\n', solution.x_Tmax);
    fprintf('Left Surface Temp   : %.4f K\n', solution.T_left);
    fprintf('Right Surface Temp  : %.4f K\n', solution.T_right);


    fprintf('========================================\n');

    plotTemperature(solution);

    plotTemperatureContour(solution);

    plotHeatFlux(solution, heatFlux);

    fprintf('\n----------------------------------------\n');
    fprintf('BOUNDARY CONDITION VALIDATION\n');
    fprintf('----------------------------------------\n');
    
    fprintf('Left Boundary Error  : %.6e\n', ...
        validation.left.error);
    
    fprintf('Left Boundary Status : %s\n', ...
        validation.left.status);
    
    fprintf('\n');
    
    fprintf('Right Boundary Error : %.6e\n', ...
        validation.right.error);
    
     fprintf('Right Boundary Status: %s\n', ...
        validation.right.status);

else

    fprintf('\nSelected geometry has not been implemented yet, Try again later.\n');

end