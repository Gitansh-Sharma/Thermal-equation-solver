function BC = getBoundaryConditions()

fprintf('\n----------------------------------------\n');
fprintf('        BOUNDARY CONDITIONS\n');
fprintf('----------------------------------------\n');

fprintf("\nBoundary condition type Selection: ");
fprintf("\n1. Specific Temperature Condition");
fprintf("\n2. Specific Heat Flux Condition");
fprintf("\n3. Insulating Boundary Condition");
fprintf("\n4. Heat convection Boundary Condition");
fprintf("\n5. Radiation Boundary Condition");

BC.left.type = input("\nSelect the Boundary Condition type for x[0]: ");

switch BC.left.type

    case 1
        BC.left.T = input("Enter the Specific temperature of boundary wall: ");

    case 2
        BC.left.q = input("Enter the value of heat flux: ");

    case 3
        BC.left.q = 0;
    
    case 4
        BC.left.h=input("Enter the convection coefficient: ");
        BC.left.Tinf=input("Enter the surrounding flow temperature: ");
    
    case 5
        BC.left.emissivity=input("Enter the value of emmissivity: ");
        BC.left.Tsurr=input("Enter the value of surrounding temperature(K): ");
    otherwise
        error('Invalid boundary condition type.');

end

BC.right.type = input("\nSelect the Boundary Condition type for x[L]: ");

switch BC.right.type

    case 1
        BC.right.T = input("Enter the Specific temperature of boundary wall: ");

    case 2
        BC.right.q = input("Enter the value of heat flux: ");

    case 3
        BC.right.q = 0;
    case 4
        BC.right.h=input("Enter the convection coefficient: ");
        BC.right.Tinf=input("Enter the surrounding flow temperature: ");

     case 5
        BC.right.emissivity=input("Enter the value of emmissivity: ");
        BC.right.Tsurr=input("Enter the value of surrounding temperature(K): ");
    otherwise
        error('Invalid boundary condition type.');

end

end