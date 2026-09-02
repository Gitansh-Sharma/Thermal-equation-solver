function inputs=getInputs()
clc;

fprintf('\n----------------------------------------\n');
fprintf('           PLANE WALL INPUTS\n');
fprintf('----------------------------------------\n');


inputs.thermalchoice=input('\n Is it variable thermal Conductivity: Yes[1] or NO[0]: ');
if inputs.thermalchoice==0
        inputs.k=input('\nThermal conductivity of the material: ');
        
        inputs.t=input('\n Enter the thickness of plane wall: ');
        inputs.a=input('\n Enter the area of the plane wall: ');
        
        inputs.N=input('\n Enter the number of calculation points: ');
        
        inputs.heatGeneration=input("\nIs there any heat Generation yes[1] or no[0]: ");
        
        GenerationChoice=inputs.heatGeneration;
        
        if(GenerationChoice == 1)
            inputs.qgen=input("\nEnter the value of heat generation: W/m3: ");
        else
            inputs.qgen=0;
        end
        
        inputs.BC=getBoundaryConditions();

elseif inputs.thermalchoice==1
     inputs.variablek=getInputsVariableThermalConductivity();
     inputs.t=input('\n Enter the thickness of plane wall: ');
            inputs.a=input('\n Enter the area of the plane wall: ');
            
            inputs.N=input('\n Enter the number of calculation points: ');
            
            inputs.heatGeneration=input("\nIs there any heat Generation yes[1] or no[0]: ");
            
            GenerationChoice=inputs.heatGeneration;
            
            if(GenerationChoice == 1)
                inputs.qgen=input("\nEnter the value of heat generation: W/m3: ");
            else
                inputs.qgen=0;
            end
            
            inputs.BC=getBoundaryConditions();

else
    error('\nInvalid choice. Enter 0 or 1:')
end

end

