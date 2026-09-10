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

    fprintf('\nSelect Wall Type:\n');
    fprintf('1. Single Wall\n');
    fprintf('2. Thermal Network\n');
    walltype = input('Enter the number of your desired wall type: ');

    if walltype == 2
        
            fprintf("\n************************************\n");
            fprintf("******** Thermal Resistance Network ********\n");
            fprintf("************************************\n\n");
        
            % Create empty thermal network
            network = createThermalNetwork();
        
            % Create first node
            network = addThermalNode(network,"internal",NaN);
        
            nextNodeID = 2;
        
            % Start building network
            [network,nextNodeID] = buildThermalNetwork(network,1,nextNodeID);
        
            fprintf('\n========================================\n');
            fprintf('       NETWORK CONSTRUCTION COMPLETE\n');
            fprintf('========================================\n');
        
            fprintf('Number of nodes      : %d\n',nextNodeID - 1);
            fprintf('Number of components : %d\n',height(network.graph.Edges));
        
            fprintf('\nNetwork edges:\n');
            disp(network.graph.Edges);
        
            fprintf('\nThermal network graph:\n');
            disp(network.graph);
        
            figure;
            plot(network.graph);
            title('Thermal Resistance Network');
        
            % Boundary-condition input will be added here later.
            %
            % For now:
            % The network has only been constructed.
            %
            % Later this section will:
            % 1. Ask which nodes are boundaries
            % 2. Ask the boundary-condition type
            % 3. Collect BC parameters
            % 4. Pass network + BCs to the appropriate solver
        
            fprintf('\nNetwork topology has been created successfully.\n');
            fprintf('Boundary-condition input will be added next.\n');


    elseif walltype == 1

        inputs = getInputs();
        validateInputs(inputs);
        geometry = PlaneWall(inputs);

        if inputs.BC.left.type == 5 || inputs.BC.right.type == 5
    
            solutionFD = solvePlaneWallFD(inputs);
    
            fprintf('\n========================================\n');
            fprintf('                RESULTS\n');
            fprintf('========================================\n');
    
            fprintf('Geometry              : Plane Wall\n');
            if inputs.thermalchoice==0
                fprintf('Thermal Conductivity  : %.4f W/m-K\n',inputs.k);
            else
                fprintf('Thermal Conductivity  : Variable\n');
                fprintf('k0                    : %.4f W/m-K\n',inputs.variablek.ko);
                fprintf('Beta                  : %.6e 1/K\n',inputs.variablek.beta);
                fprintf('Tref                  : %.2f K\n',inputs.variablek.Tref);
            end
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
    
                case 5
                    fprintf('Boundary Condition   : Radiation\n');
                    fprintf('Emissivity            : %.4f\n', inputs.BC.left.emissivity);
                    fprintf('Surrounding Temperature: %.2f K\n', inputs.BC.left.Tsurr);
    
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
    
                case 5
                    fprintf('Boundary Condition   : Radiation\n');
                    fprintf('Emissivity            : %.4f\n', inputs.BC.right.emissivity);
                    fprintf('Surrounding Temperature: %.2f K\n', inputs.BC.right.Tsurr);
    
            end
    
            fprintf('\n----------------------------------------\n');
            fprintf('FINITE DIFFERENCE RESULTS\n');
            fprintf('----------------------------------------\n');
            
            fprintf('Number of Nodes      : %d\n', inputs.N);
            fprintf('Grid Spacing         : %.6e m\n', solutionFD.dx);
            fprintf('Newton Iterations    : %d\n', solutionFD.iterations);
            fprintf('Converged            : %d\n', solutionFD.converged);
            fprintf('Maximum Residual     : %.6e\n', solutionFD.residual);
            
            fprintf('\nMaximum Temperature  : %.4f K\n', max(solutionFD.T));
            fprintf('Minimum Temperature  : %.4f K\n', min(solutionFD.T));
            fprintf('Left Surface Temp    : %.4f K\n', solutionFD.T(1));
            fprintf('Right Surface Temp   : %.4f K\n', solutionFD.T(end));
            
            heatFluxFD = calculateHeatFluxFD(inputs, solutionFD);
            
            fprintf('\nHeat Flux at x = 0   : %.4f W/m^2\n', heatFluxFD(1));
            fprintf('Heat Flux at x = L   : %.4f W/m^2\n', heatFluxFD(end));
            
            fprintf('========================================\n');
            
            plotTemperature(solutionFD);
            plotTemperatureContour(solutionFD);
            plotHeatFlux(solutionFD, heatFluxFD);
    
    
        else
    
          if inputs.thermalchoice==0
                solution=solvePlaneWall(inputs);
                heatFlux=calculateHeatFlux(inputs,solution);
           else
                solution=solvePlaneWallFD(inputs);
                heatFlux=calculateHeatFluxFD(inputs,solution);
           end
            
            heatRate=calculateHeatRate(inputs,heatFlux);
            validation=verifyBoundaryConditions(inputs,solution,heatFlux);
    
            fprintf('\n========================================\n');
            fprintf('                RESULTS\n');
            fprintf('========================================\n');
    
            fprintf('Geometry              : Plane Wall\n');
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
                fprintf('Total Heat Generated : %.4f W\n', heatRate.generated);
                energyBalanceError = abs(heatRate.generated -  (heatRate.left + heatRate.right))/ heatRate.generated * 100;
    
                fprintf('Energy Balance Error : %.6f %%\n',energyBalanceError);
    
            else
                fprintf('Heat Generation      : None\n');
                fprintf('Heat Transfer Rate   : %.4f W\n',heatRate.right);
    
            end
            if inputs.thermalchoice==0
                Tmax=solution.T_max;
                xTmax=solution.x_Tmax;
                Tleft=solution.T_left;
                Tright=solution.T_right;
            else
                Tmax=max(solution.T);
                [~,imax]=max(solution.T);
                xTmax=solution.x(imax);
                Tleft=solution.T(1);
                Tright=solution.T(end);
            end
           if inputs.thermalchoice==0
    
                % Analytical solution
                fprintf('\nMaximum Temperature  : %.4f K\n',Tmax);
                fprintf('Location of Tmax     : %.4f m\n',xTmax);
                fprintf('Left Surface Temp    : %.4f K\n',Tleft);
                fprintf('Right Surface Temp   : %.4f K\n',Tright);
            
            else
            
                % Finite Difference solution
                fprintf('\nNumber of Nodes      : %d\n',inputs.N);
                fprintf('Grid Spacing         : %.6e m\n',solution.dx);
                fprintf('Newton Iterations    : %d\n',solution.iterations);
                fprintf('Converged            : %d\n',solution.converged);
                fprintf('Maximum Residual     : %.6e\n',solution.residual);
                fprintf('Maximum Temperature  : %.4f K\n',max(solution.T));
                fprintf('Minimum Temperature  : %.4f K\n',min(solution.T));
                fprintf('Left Surface Temp    : %.4f K\n',solution.T(1));
                fprintf('Right Surface Temp   : %.4f K\n',solution.T(end));
            
            end
            fprintf('========================================\n');
    
            plotTemperature(solution);
    
            plotTemperatureContour(solution);
    
            plotHeatFlux(solution, heatFlux);
    
            fprintf('\n----------------------------------------\n');
            fprintf('BOUNDARY CONDITION VALIDATION\n');
            fprintf('----------------------------------------\n');
    
            fprintf('Left Boundary Error  : %.6e\n',validation.left.error);
    
            fprintf('Left Boundary Status : %s\n',validation.left.status);
            fprintf('\nRight Boundary Error : %.6e\n', validation.right.error);
            fprintf('Right Boundary Status: %s\n',validation.right.status);
    
        end
        
    end
else

    fprintf('\nSelected geometry has not been implemented yet, Try again later.\n');

end

function [network,nextNodeID] = buildThermalNetwork(network,currentNode,nextNodeID)

    finished = false;

    while ~finished

        fprintf('\n----------------------------------------\n');
        fprintf('Current node: %d\n',currentNode);
        fprintf('----------------------------------------\n');

        fprintf('1. Add component to new node\n');
        fprintf('2. Create parallel branches\n');
        fprintf('3. Move to existing node\n');
        fprintf('4. Finish network\n');

        choice = input('Enter your choice: ');

        switch choice

            case 1

                newNode = nextNodeID;
                nextNodeID = nextNodeID + 1;

                network = addThermalNode(network,"internal",NaN);

                fprintf('\nCreating Node %d...\n',newNode);

                [componentType,inputMode,parameters] = getThermalComponentInput();

                network = addThermalEdge(network,currentNode,newNode,componentType,inputMode,parameters);

                fprintf('Connection added: Node %d -> Node %d\n', ...
                    currentNode,newNode);

                currentNode = newNode;


            case 2

                fprintf('\n========================================\n');
                fprintf('       PARALLEL BRANCH GROUP\n');
                fprintf('========================================\n');

                [network,nextNodeID] = ...
                    buildParallelGroup(network,currentNode,nextNodeID);


            case 3

                fprintf('\n----------------------------------------\n');
                fprintf('Available nodes:\n');
                fprintf('----------------------------------------\n');

                for i = 1:(nextNodeID - 1)

                    if i ~= currentNode
                        fprintf('Node %d\n',i);
                    end

                end

                newCurrentNode = input( '\nEnter node to move to: ');

                if newCurrentNode >= 1 && newCurrentNode < nextNodeID && newCurrentNode ~= currentNode

                    currentNode = newCurrentNode;

                    fprintf('\nMoved to Node %d.\n',currentNode);

                else

                    fprintf('\nInvalid node selection.\n');

                end


            case 4

                finished = true;

                fprintf('\nFinishing network construction...\n');


            otherwise

                fprintf('\nInvalid choice. Please try again.\n');

        end
    end
end

function [network,nextNodeID] = buildParallelGroup( network,parentNode,nextNodeID)

    anotherBranch = true;
    branchNumber = 1;

    while anotherBranch

        fprintf('\n----------------------------------------\n');
        fprintf('Building Parallel Branch %d from Node %d\n', ...
            branchNumber,parentNode);
        fprintf('----------------------------------------\n');

        [network,nextNodeID] = buildBranch(network,parentNode,nextNodeID);

        fprintf('\nBranch %d completed.\n',branchNumber);

        fprintf('\nAdd another parallel branch from Node %d?\n',parentNode);
        fprintf('1. Yes\n');
        fprintf('2. No\n');

        choice = input('Enter your choice: ');

        if choice == 1

            branchNumber = branchNumber + 1;

        elseif choice == 2

            anotherBranch = false;

        else

            fprintf('\nInvalid choice. Ending parallel group.\n');
            anotherBranch = false;

        end
    end

    fprintf('\nParallel group completed at Node %d.\n',parentNode);
end

function [network,nextNodeID] = buildBranch( network,parentNode,nextNodeID)

    currentNode = parentNode;
    branchFinished = false;

    while ~branchFinished

        fprintf('\n----------------------------------------\n');
        fprintf('Parallel Branch - Current node: %d\n',currentNode);
        fprintf('----------------------------------------\n');

        fprintf('1. Continue branch to a new node\n');
        fprintf('2. Create nested parallel branches\n');
        fprintf('3. Finish this branch\n');

        choice = input('Enter your choice: ');

        switch choice

            case 1

                newNode = nextNodeID;
                nextNodeID = nextNodeID + 1;

                network = addThermalNode(network,"internal",NaN);

                fprintf('\nCreating Node %d...\n',newNode);

                [componentType,inputMode,parameters] =getThermalComponentInput();

                network = addThermalEdge(network,currentNode,newNode, componentType,inputMode,parameters);

                fprintf('Connection added: Node %d -> Node %d\n', currentNode,newNode);

                currentNode = newNode;


            case 2

                fprintf('\nStarting nested parallel group from Node %d...\n',currentNode);

                [network,nextNodeID] =buildParallelGroup(network,currentNode,nextNodeID);

                fprintf('\nReturned to Node %d.\n',currentNode);


            case 3

                branchFinished = true;

                fprintf('\nBranch finished.\n');


            otherwise

                fprintf('\nInvalid choice. Please try again.\n');

        end
    end
end

function [componentType,inputMode,parameters] = getThermalComponentInput()

    fprintf('\n========================================\n');
    fprintf('        THERMAL COMPONENT\n');
    fprintf('========================================\n');

    fprintf('1. Conduction\n');
    fprintf('2. Thermal Contact\n');
    fprintf('3. Convection\n');
    fprintf('4. Direct Resistance\n');

    componentChoice = input('Select component: ');

    parameters = struct();

    switch componentChoice

        case 1

            componentType = "conduction";

            fprintf('\nResistance input method:\n');
            fprintf('1. Direct resistance\n');
            fprintf('2. Physical parameters\n');

            modeChoice = input('Enter choice: ');

            if modeChoice == 1

                inputMode = "direct";

                parameters.R = input( 'Enter thermal resistance [K/W]: ');

            elseif modeChoice == 2

                inputMode = "parameters";

                parameters.L = input( 'Enter conduction length L [m]: ');

                parameters.k = input( 'Enter thermal conductivity k [W/m-K]: ');

                parameters.A = input('Enter area A [m^2]: ');

            else

                error('Invalid resistance input mode.');

            end


        case 2

            componentType = "contact";

            inputMode = "parameters";

            parameters.Rc = input( ...
                'Enter contact resistance Rc [K/W]: ');


        case 3

            componentType = "convection";

            fprintf('\nResistance input method:\n');
            fprintf('1. Direct resistance\n');
            fprintf('2. Physical parameters\n');

            modeChoice = input('Enter choice: ');

            if modeChoice == 1

                inputMode = "direct";

                parameters.R = input('Enter thermal resistance [K/W]: ');

            elseif modeChoice == 2

                inputMode = "parameters";

                parameters.h = input('Enter convection coefficient h [W/m^2-K]: ');

                parameters.A = input( 'Enter convection area A [m^2]: ');

            else

                error('Invalid resistance input mode.');

            end


        case 4

            componentType = "conduction";
            inputMode = "direct";

            parameters.R = input( 'Enter thermal resistance [K/W]: ');


        otherwise

            error('Invalid thermal component selection.');

    end

end