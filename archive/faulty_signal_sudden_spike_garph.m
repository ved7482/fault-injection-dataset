close all;
clc;

t = T_true_log.Time;

T_true_data     = double(squeeze(T_true_log.Data));
V_healthy_data  = double(squeeze(V_healthy_log.Data));
V_faulty_data   = double(squeeze(V_faulty_log.Data));
T_measured_data = double(squeeze(T_measured_log.Data));

voltage_error = V_faulty_data - V_healthy_data;
temperature_error = T_measured_data - T_true_data;

figure;
plot(t,V_healthy_data,'LineWidth',1.5);
hold on;
plot(t,V_faulty_data,'LineWidth',1.0);
xline(10,'--','Fault starts');
grid on;
xlabel('Time (s)');
ylabel('Sensor Voltage (V)');
title('TMP36 Sensor Voltage: Healthy vs Sudden Spike');
legend('Healthy Sensor','Faulty Sensor - Spike','Fault Activation','Location','best');
hold off;

figure;
plot(t,T_true_data,'LineWidth',1.5);
hold on;
plot(t,T_measured_data,'LineWidth',1.0);
xline(10,'--','Fault starts');
grid on;
xlabel('Time (s)');
ylabel('Temperature (^oC)');
title('TMP36 Temperature: True vs Measured with Sudden Spike');
legend('True Temperature','Measured Temperature','Fault Activation','Location','best');
hold off;

figure;
plot(t,voltage_error,'LineWidth',1.2);
xline(10,'--','Fault starts');
yline(0,'-');
grid on;
xlabel('Time (s)');
ylabel('Voltage Error (V)');
title('Sensor Voltage Error Due to Sudden Spike');
legend('V_{faulty} - V_{healthy}','Fault Activation','Location','best');
hold off;

figure;
plot(t,temperature_error,'LineWidth',1.2);
xline(10,'--','Fault starts');
yline(0,'-');
grid on;
xlabel('Time (s)');
ylabel('Temperature Error (^oC)');
title('Temperature Error Due to Sudden Spike');
legend('T_{measured} - T_{true}','Fault Activation','Location','best');
hold off;

fault_indices = t >= 10;

voltage_error_after_fault = voltage_error(fault_indices);
temperature_error_after_fault = temperature_error(fault_indices);

[max_voltage_error,max_index] = max(voltage_error_after_fault);
[max_temperature_error,~] = max(temperature_error_after_fault);

fault_times = t(fault_indices);
spike_time = fault_times(max_index);

fprintf('\n');
fprintf('TMP36 SUDDEN SPIKE FAULT RESULTS\n');
fprintf('--------------------------------\n');
fprintf('Fault activation time   : %.2f s\n',10);
fprintf('Configured spike        : %.4f V\n',0.10);
fprintf('Maximum voltage error   : %.6f V\n',max_voltage_error);
fprintf('Spike occurrence time   : %.6f s\n',spike_time);
fprintf('Maximum temperature error : %.4f deg C\n',max_temperature_error);