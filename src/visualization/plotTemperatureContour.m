function plotTemperatureContour(solution)

x = solution.x;
T = solution.T(:);

y = linspace(0, 0.5, 50);

[X,Y] = meshgrid(x,y);

Tcontour = repmat(T.', length(y), 1);

figure;

contourf(X,Y,Tcontour,50,'LineStyle','none');

colorbar;

xlabel('Position, x [m]');
ylabel('Height [m]');

title('Temperature Contour');

end