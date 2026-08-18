function validateInputs(inputs)

if inputs.k <= 0
    error('Thermal conductivity k must be greater than zero.');
end

if inputs.t <= 0
    error('Wall thickness must be greater than zero.');
end

if inputs.a <= 0
    error('Area must be greater than zero.');
end

if inputs.N < 2 || mod(inputs.N,1) ~= 0
    error('Number of calculation points N must be an integer greater than or equal to 2.');
end

if inputs.heatGeneration ~= 0 && inputs.heatGeneration ~= 1
    error('Heat generation selection must be either 0 or 1.');
end

if inputs.heatGeneration == 1

    if inputs.qgen < 0
        error('Heat generation qgen cannot be negative.');
    end

end

switch inputs.BC.left.type

    case 1

        if ~isfinite(inputs.BC.left.T)
            error('Left boundary temperature must be a valid finite value.');
        end


    case 2

        if ~isfinite(inputs.BC.left.q)
            error('Left boundary heat flux must be a valid finite value.');
        end


    case 3
        % Insulated


    case 4

        if inputs.BC.left.h < 0
            error('Left convection coefficient h must be non-negative.');
        end

        if ~isfinite(inputs.BC.left.Tinf)
            error('Left fluid temperature must be a valid finite value.');
        end


    otherwise
        error('Invalid left boundary condition type.');

end

switch inputs.BC.right.type

    case 1

        if ~isfinite(inputs.BC.right.T)
            error('Right boundary temperature must be a valid finite value.');
        end


    case 2

        if ~isfinite(inputs.BC.right.q)
            error('Right boundary heat flux must be a valid finite value.');
        end


    case 3
        % Insulated


    case 4

        if inputs.BC.right.h < 0
            error('Right convection coefficient h must be non-negative.');
        end

        if ~isfinite(inputs.BC.right.Tinf)
            error('Right fluid temperature must be a valid finite value.');
        end


    otherwise
        error('Invalid right boundary condition type.');

end


fprintf('\nInput validation: PASSED\n');

end