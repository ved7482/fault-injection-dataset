%% plot_tmp36_fault_run.m
% Plot healthy and fault-injected TMP36 signals from a Simulink run.
%
% Required workspace variables:
%   tmp36_data
%   V_faulty_log
%   T_measured_log

%% Settings

PLOT_DURATION_S = 600;  % Plot duration in seconds

%% Extract logged signals

tFault = V_faulty_log.Time(:);
Vfault = V_faulty_log.Data(:);

tMeas = T_measured_log.Time(:);
Tmeas = T_measured_log.Data(:);

%% Load healthy reference data

tSrc = double(tmp36_data.time_s);
VhealthySrc = double(tmp36_data.tmp36_output_V);
TtrueSrc = double(tmp36_data.temperature_C);

% Interpolate the source reference to the logged simulation timestamps.
Vhealthy = interp1(tSrc, VhealthySrc, tFault, "linear", "extrap");
Ttrue = interp1(tSrc, TtrueSrc, tMeas, "linear", "extrap");

%% Select plotting interval

keepV = tFault <= PLOT_DURATION_S;
keepT = tMeas <= PLOT_DURATION_S;

%% Plot sensor output voltage

figure("Name", "TMP36 Healthy vs Faulty Sensor Output");

plot(tFault(keepV), Vhealthy(keepV), "LineWidth", 1.1);
hold on;
plot(tFault(keepV), Vfault(keepV), "LineWidth", 1.1);

grid on;
xlabel("Time (s)");
ylabel("Sensor Output Voltage (V)");
legend("Healthy TMP36 Reference", ...
       "Faulty TMP36 Output", ...
       "Location", "best");

title("TMP36 Sensor Fault Injection");

%% Plot true and measured temperature

figure("Name", "TMP36 True vs Measured Temperature");

plot(tMeas(keepT), Ttrue(keepT), "LineWidth", 1.1);
hold on;
plot(tMeas(keepT), Tmeas(keepT), "LineWidth", 1.1);

grid on;
xlabel("Time (s)");
ylabel("Temperature (degC)");
legend("True Temperature", ...
       "Measured Temperature", ...
       "Location", "best");

title("Effect of Sensor Fault on Measured Temperature");