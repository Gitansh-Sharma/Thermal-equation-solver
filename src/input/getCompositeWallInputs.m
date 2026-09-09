function composite = getCompositeWallInputs()

fprintf('\n========================================\n');
fprintf('          COMPOSITE PLANE WALL\n');
fprintf('========================================\n');

composite.nLayers = input('Enter number of layers: ');

if composite.nLayers < 1 || mod(composite.nLayers,1) ~= 0
    error('Number of layers must be a positive integer.');
end

composite.Thot = input('Enter hot-side temperature [K]: ');
composite.Tcold = input('Enter cold-side temperature [K]: ');

if composite.Thot <= composite.Tcold
    error('Hot-side temperature must be greater than cold-side temperature.');
end

for i = 1:composite.nLayers

    fprintf('\nLayer %d\n',i);

    composite.layers(i).L = input('Thickness [m]: ');
    composite.layers(i).k = input('Thermal conductivity [W/m-K]: ');
    composite.layers(i).A = input('Area [m^2]: ');

end

for i = 1:composite.nLayers-1

    composite.contactResistance(i) = input(sprintf('Contact resistance between layer %d and %d [K/W]: ',i, i+1));

end

end