%% TMP36 Fault Verification

% Get data from To Workspace blocks
T_true     = T_true_log;
V_healthy  = V_healthy_log;
V_faulty   = V_faulty_log;
T_measured = T_measured_log;

%% Extract time and data
% This works if your To Workspace blocks save data as timeseries

t = T_true.Time;

T_true_data     = T_true.Data;
V_healthy_data  = V_healthy.Data;
V_faulty_data   = V_faulty.Data;
T_measured_data = T_measured.Data;

%% Figure 1: Sensor voltage
figure;

plot(t, V_healthy_data, 'LineWidth', 1.5);
hold on;

plot(t, V_faulty_data, 'LineWidth', 1.5);

grid on;

xlabel('Time (s)');
ylabel('Sensor Voltage (V)');
title('TMP36 Sensor Voltage: Healthy vs Faulty');

legend('Healthy Voltage', 'Faulty Voltage', ...
    'Location', 'best');

hold off;


%% Figure 2: Temperature
figure;

plot(t, T_true_data, 'LineWidth', 1.5);
hold on;

plot(t, T_measured_data, 'LineWidth', 1.5);

grid on;

xlabel('Time (s)');
ylabel('Temperature (^oC)');
title('TMP36 Temperature: True vs Measured');

legend('True Temperature', 'Measured Temperature', ...
    'Location', 'best');

hold off;


%% Figure 3: Fault error
figure;

voltage_error = V_faulty_data - V_healthy_data;
temperature_error = T_measured_data - T_true_data;

plot(t, temperature_error, 'LineWidth', 1.5);

grid on;

xlabel('Time (s)');
ylabel('Temperature Error (^oC)');
title('Temperature Measurement Error Due to Fault');

hold off;