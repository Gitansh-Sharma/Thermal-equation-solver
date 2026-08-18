function plotHeatFlux(solution, heatFlux)

figure;

plot(solution.x, heatFlux, 'LineWidth', 2);

grid on;

xlabel('Position, x [m]');
ylabel('Heat Flux, q'''' [W/m^2]');

title('Heat Flux Distribution');

end