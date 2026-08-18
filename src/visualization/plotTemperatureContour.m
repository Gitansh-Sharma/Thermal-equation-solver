function plotTemperatureContour(solution)

y=linspace(0,0.5,50);

[X,Y]=meshgrid(solution.x,y);

Tcontour=repmat(solution.T,length(y),1);
figure;

contourf(X,Y,Tcontour,50,'LineStyle','none');
colormap("turbo");
colorbar;

shading interp;
xlabel('Position [x]');
ylabel('Temperature (k)');

title('Temeprature distribution contour');


end