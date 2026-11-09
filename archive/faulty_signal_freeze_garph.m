%% TMP36 Sensor Freeze Fault Verification

close all;
clc;

%% Extract TIME as numeric array

t = T_true_log.Time;

%% Extract DATA as numeric arrays

T_true_data     = T_true_log.Data;
V_healthy_data  = V_healthy_log.Data;
V_faulty_data   = V_faulty_log.Data;
T_measured_data = T_measured_log.Data;

% Make sure the data are simple numeric column vectors
t               = squeeze(t);
T_true_data     = squeeze(T_true_data);
V_healthy_data  = squeeze(V_healthy_data);
V_faulty_data   = squeeze(V_faulty_data);
T_measured_data = squeeze(T_measured_data);

%% Make sure everything is numeric

T_true_data     = double(T_true_data);
V_healthy_data  = double(V_healthy_data);
V_faulty_data   = double(V_faulty_data);
T_measured_data = double(T_measured_data);
t               = double(t);

%% 
% 1. HEALTHY VS FAULTY SENSOR VOLTAGE


figure;

plot(t, V_healthy_data, 'LineWidth', 1.5);
hold on;

plot(t, V_faulty_data, 'LineWidth', 1.5);

xline(10, '--', 'Fault starts');

grid on;

xlabel('Time (s)');
ylabel('Sensor Voltage (V)');

title('TMP36 Sensor Freeze Fault');

legend('Healthy Sensor', ...
       'Faulty / Frozen Sensor', ...
       'Fault Activation', ...
       'Location', 'best');

hold off;


%% 
% 2. TRUE TEMPERATURE VS MEASURED TEMPERATURE


figure;

plot(t, T_true_data, 'LineWidth', 1.5);
hold on;

plot(t, T_measured_data, 'LineWidth', 1.5);

xline(10, '--', 'Fault starts');

grid on;

xlabel('Time (s)');
ylabel('Temperature (^oC)');

title('Temperature Response to Sensor Freeze Fault');

legend('True Temperature', ...
       'Measured Temperature', ...
       'Fault Activation', ...
       'Location', 'best');

hold off;


%% 
% 3. SENSOR VOLTAGE ERROR


voltage_error = V_faulty_data - V_healthy_data;

figure;

plot(t, voltage_error, 'LineWidth', 1.5);

xline(10, '--', 'Fault starts');

grid on;

xlabel('Time (s)');
ylabel('Voltage Error (V)');

title('Sensor Voltage Error Due to Freeze Fault');

legend('V_{faulty} - V_{healthy}', ...
       'Fault Activation', ...
       'Location', 'best');

hold off;

%%

% 4. TEMPERATURE MEASUREMENT ERROR

temperature_error = T_measured_data - T_true_data;

figure;

plot(t, temperature_error, 'LineWidth', 1.5);

xline(10, '--', 'Fault starts');

grid on;

xlabel('Time (s)');
ylabel('Temperature Error (^oC)');

title('Temperature Measurement Error Due to Freeze Fault');

legend('T_{measured} - T_{true}', ...
       'Fault Activation', ...
       'Location', 'best');

hold off;