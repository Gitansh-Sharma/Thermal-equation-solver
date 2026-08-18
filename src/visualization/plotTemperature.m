function plotTemperature(solution)

figure;

plot(solution.x,solution.T,'LineWidth',2);

title('1-D Temperature Distribution: ');

xlabel('Position(meters)');
ylabel('Temperature(k)');

end
