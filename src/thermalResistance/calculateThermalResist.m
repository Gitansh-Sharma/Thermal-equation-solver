function Rth = calculateThermalResist(type,InputMode,parameters)

switch lower(InputMode)
    case "direct"
        Rth=parameters.R;
    
    case "parameters"

        switch lower(type)
            case"conduction"
                Rth=calculateConductionResistance(parameters.L,parameters.k,parameters.A);

            case "contact"
                Rth=parameters.Rc;
            case "convection"
                Rth=1./(parameters.h*parameters.A);
            
            otherwise
                error("Invalid thermal resistance type");
        end
    otherwise
        error("Unsupported resistance input: ");
end
