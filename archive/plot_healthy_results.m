%% Healthy TMP36 Sensor Analysis

t_true = T_true_log.Time;
T_true = T_true_log.Data;

t_healthy = V_healthy_log.Time;
V_healthy = V_healthy_log.Data;

t_measured = T_measured_log.Time;
T_measured = T_measured_log.Data;

% Interpolate all signals onto the T_true time vector
T_measured_interp = interp1(t_measured, T_measured, t_true, 'linear', 'extrap');
V_healthy_interp = interp1(t_healthy, V_healthy, t_true, 'linear', 'extrap');

% Expected sensor voltage
V_expected = 0.01 .* T_true + 0.5;

% Errors
temperature_error = T_measured_interp - T_true;
voltage_error = V_healthy_interp - V_expected;
percentage_error = (temperature_error ./ T_true) .* 100;

% Create figure
figure('Name','Healthy TMP36 Sensor Analysis',...
       'NumberTitle','off',...
       'Color','w');

% 1. Temperature
subplot(2,2,1);

plot(t_true, T_true, 'b-', 'LineWidth', 2);
hold on;
plot(t_true, T_measured_interp, 'r--', 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('True vs Measured Temperature');

legend('T_{true}', 'T_{measured}', 'Location','best');

hold off;

% 2. Sensor voltage
subplot(2,2,2);

plot(t_true, V_healthy_interp, 'g-', 'LineWidth', 2);
hold on;
plot(t_true, V_expected, 'm--', 'LineWidth', 2);

grid on;
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Healthy Sensor Voltage');

legend('V_{healthy}', 'V_{expected}', 'Location','best');

hold off;

% 3. Temperature error
subplot(2,2,3);

plot(t_true, temperature_error, 'r-', 'LineWidth', 2);
hold on;
yline(0, 'k--', 'LineWidth', 1.5);

grid on;
xlabel('Time (s)');
ylabel('Error (°C)');
title('Temperature Error');

legend('Temperature Error', 'Zero Error', 'Location','best');

hold off;

% 4. Voltage error
subplot(2,2,4);

plot(t_true, voltage_error, 'c-', 'LineWidth', 2);
hold on;
yline(0, 'k--', 'LineWidth', 1.5);

grid on;
xlabel('Time (s)');
ylabel('Error (V)');
title('Sensor Voltage Error');

legend('Voltage Error', 'Zero Error', 'Location','best');

hold off;

sgtitle('Healthy TMP36 Sensor Analysis',...
        'FontSize',14,...
        'FontWeight','bold');

% Display error values
fprintf('\nHealthy Sensor Error Analysis\n');
fprintf('-----------------------------------\n');
fprintf('Maximum Temperature Error : %.6f °C\n', ...
    max(abs(temperature_error)));

fprintf('Mean Absolute Temperature Error : %.6f °C\n', ...
    mean(abs(temperature_error)));

fprintf('Maximum Voltage Error : %.6f V\n', ...
    max(abs(voltage_error)));

fprintf('Mean Absolute Voltage Error : %.6f V\n', ...
    mean(abs(voltage_error)));

fprintf('Maximum Percentage Error : %.6f %%\n', ...
    max(abs(percentage_error)));

fprintf('-----------------------------------\n');