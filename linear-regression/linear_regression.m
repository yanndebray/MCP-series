% Linear Regression Example
% Generate sample data
rng(42); % For reproducibility
x = (1:50)';
y = 2*x + 5 + 10*randn(size(x)); % y = 2x + 5 + noise

% Perform linear regression
p = polyfit(x, y, 1); % Fit a polynomial of degree 1 (linear)
y_fit = polyval(p, x); % Evaluate the fitted line

% Display results
fprintf('Linear Regression Results:\n');
fprintf('Slope (m): %.4f\n', p(1));
fprintf('Intercept (b): %.4f\n', p(2));
fprintf('Equation: y = %.4f*x + %.4f\n', p(1), p(2));

% Calculate R-squared
ss_res = sum((y - y_fit).^2);
ss_tot = sum((y - mean(y)).^2);
r_squared = 1 - (ss_res / ss_tot);
fprintf('R-squared: %.4f\n', r_squared);

% Create visualization
figure;
scatter(x, y, 'b', 'filled');
hold on;
plot(x, y_fit, 'r-', 'LineWidth', 2);
xlabel('X');
ylabel('Y');
title('Linear Regression');
legend('Data', 'Fitted Line', 'Location', 'best');
grid on;
hold off;
