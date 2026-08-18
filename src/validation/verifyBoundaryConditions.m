function validation = verifyBoundaryConditions(inputs, solution, heatFlux)

tolerance = 1e-6;

T_left = solution.T(1);
T_right = solution.T(end);

switch inputs.BC.left.type

    case 1
        % Specified Temperature

        expected = inputs.BC.left.T;
        calculated = T_left;

        errorValue = abs(calculated - expected);

        if errorValue <= tolerance
            status = "PASS";
        else
            status = "FAIL";
        end

        validation.left.error = errorValue;
        validation.left.status = status;


    case 2
      
        expected = inputs.BC.left.q;
        calculated = heatFlux(1);

        errorValue = abs(calculated - expected);

        if errorValue <= tolerance
            status = "PASS";
        else
            status = "FAIL";
        end

        validation.left.error = errorValue;
        validation.left.status = status;


    case 3
        % Insulated

        expected = 0;
        calculated = heatFlux(1);

        errorValue = abs(calculated - expected);

        if errorValue <= tolerance
            status = "PASS";
        else
            status = "FAIL";
        end

        validation.left.error = errorValue;
        validation.left.status = status;


    case 4
        % Convection

        expected = inputs.BC.left.h *(T_left - inputs.BC.left.Tinf);

        calculated = -heatFlux(1);

        errorValue = abs(calculated - expected);

        if errorValue <= tolerance
            status = "PASS";
        else
            status = "FAIL";
        end

        validation.left.error = errorValue;
        validation.left.status = status;


    otherwise
        error('Invalid left boundary condition.');

end

switch inputs.BC.right.type

    case 1
        expected = inputs.BC.right.T;
        calculated = T_right;

        errorValue = abs(calculated - expected);

        if errorValue <= tolerance
            status = "PASS";
        else
            status = "FAIL";
        end

        validation.right.error = errorValue;
        validation.right.status = status;


    case 2

        expected = inputs.BC.right.q;
        calculated = heatFlux(end);

        errorValue = abs(calculated - expected);

        if errorValue <= tolerance
            status = "PASS";
        else
            status = "FAIL";
        end

        validation.right.error = errorValue;
        validation.right.status = status;


    case 3
        % Insulated

        expected = 0;
        calculated = heatFlux(end);

        errorValue = abs(calculated - expected);

        if errorValue <= tolerance
            status = "PASS";
        else
            status = "FAIL";
        end

        validation.right.error = errorValue;
        validation.right.status = status;


    case 4
        % Convection
    
        expected = inputs.BC.right.h *(T_right - inputs.BC.right.Tinf);

        calculated = heatFlux(end);

        errorValue = abs(calculated - expected);

        if errorValue <= tolerance
            status = "PASS";
        else
            status = "FAIL";
        end

        validation.right.error = errorValue;
        validation.right.status = status;


    otherwise
        error('Invalid right boundary condition.');

end

end