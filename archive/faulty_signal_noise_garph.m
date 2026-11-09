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
title('TMP36 Sensor Voltage: Healthy vs Excessive Noise');
legend('Healthy Sensor','Faulty Sensor - Noisy','Fault Activation','Location','best');
hold off;

figure;
plot(t,T_true_data,'LineWidth',1.5);
hold on;
plot(t,T_measured_data,'LineWidth',1.0);
xline(10,'--','Fault starts');
grid on;
xlabel('Time (s)');
ylabel('Temperature (^oC)');
title('TMP36 Temperature: True vs Measured');
legend('True Temperature','Measured Temperature','Fault Activation','Location','best');
hold off;

figure;
plot(t,voltage_error,'LineWidth',1.2);
xline(10,'--','Fault starts');
yline(0,'-');
grid on;
xlabel('Time (s)');
ylabel('Voltage Error (V)');
title('Sensor Voltage Error Due to Excessive Noise');
legend('V_{faulty} - V_{healthy}','Fault Activation','Location','best');
hold off;

figure;
plot(t,temperature_error,'LineWidth',1.2);
xline(10,'--','Fault starts');
yline(0,'-');
grid on;
xlabel('Time (s)');
ylabel('Temperature Error (^oC)');
title('Temperature Measurement Error Due to Excessive Noise');
legend('T_{measured} - T_{true}','Fault Activation','Location','best');
hold off;