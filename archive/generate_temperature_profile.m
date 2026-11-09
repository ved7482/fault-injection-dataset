clear;
clc;

Ts = 0.1;                 % Sampling time: 100 ms
StopTime = 60;            % Simulation duration

t = (0:Ts:StopTime)';

% Temperature breakpoints
t_bp = [0 10 20 30 40 50 60];

% Temperature values at those times
T_bp = [25 30 40 35 50 45 30];

% Interpolated true temperature
T_true = interp1(t_bp, T_bp, t, 'linear');

% Timeseries for Simulink
T_true_ts = timeseries(T_true, t);

% Display

figure;
plot(t, T_true);
grid on;
xlabel('Time (s)');
ylabel('True Temperature (°C)');
title('Phase-1 True Temperature Profile');
