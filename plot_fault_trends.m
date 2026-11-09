%% Plot TMP36 bias and freeze fault trends

clear;
clc;

BIAS_FILE   = fullfile("results","TMP36_Bias_20mV_Run001.xlsx");
FREEZE_FILE = fullfile("results","TMP36_Freeze_Run001.xlsx");

PLOT_WINDOW_S = 120;

%% Load exported datasets
biasData   = readtable(BIAS_FILE);
freezeData = readtable(FREEZE_FILE);

%% Ensure required derived columns exist
biasData = addDerivedColumns(biasData);
freezeData = addDerivedColumns(freezeData);

%% Determine fault start times
biasStart   = getFaultStart(biasData);
freezeStart = getFaultStart(freezeData);

%% Select plotting windows
biasWindow = biasData.Time_s >= biasStart - PLOT_WINDOW_S & ...
             biasData.Time_s <= biasStart + PLOT_WINDOW_S;

freezeWindow = freezeData.Time_s >= freezeStart - PLOT_WINDOW_S & ...
               freezeData.Time_s <= freezeStart + PLOT_WINDOW_S;

%% -------------------- Bias fault --------------------

figure("Name","TMP36 Bias - Sensor Voltage");

plot(biasData.Time_s(biasWindow), ...
     biasData.V_sensor_healthy_V(biasWindow), ...
     "LineWidth",1.2);

hold on;

plot(biasData.Time_s(biasWindow), ...
     biasData.V_sensor_faulty_V(biasWindow), ...
     "LineWidth",1.2);

xline(biasStart,"--");

grid on;

xlabel("Time (s)");
ylabel("Sensor Voltage (V)");

title("TMP36 Bias Fault - Sensor Output");

legend("Healthy","Faulty","Fault Start","Location","best");


figure("Name","TMP36 Bias - Temperature");

plot(biasData.Time_s(biasWindow), ...
     biasData.T_true_C(biasWindow), ...
     "LineWidth",1.2);

hold on;

plot(biasData.Time_s(biasWindow), ...
     biasData.T_measured_C(biasWindow), ...
     "LineWidth",1.2);

xline(biasStart,"--");

grid on;

xlabel("Time (s)");
ylabel("Temperature (degC)");

title("TMP36 Bias Fault - Temperature Response");

legend("True Temperature","Measured Temperature", ...
       "Fault Start","Location","best");


figure("Name","TMP36 Bias - Temperature Error");

plot(biasData.Time_s(biasWindow), ...
     biasData.Temperature_Error_C(biasWindow), ...
     "LineWidth",1.2);

xline(biasStart,"--");

yline(0,":");

grid on;

xlabel("Time (s)");
ylabel("Temperature Error (degC)");

title("TMP36 Bias Fault - Measurement Error");

legend("Temperature Error","Fault Start","Location","best");


%% -------------------- Freeze fault --------------------

figure("Name","TMP36 Freeze - Sensor Voltage");

plot(freezeData.Time_s(freezeWindow), ...
     freezeData.V_sensor_healthy_V(freezeWindow), ...
     "LineWidth",1.2);


hold on;

plot(freezeData.Time_s(freezeWindow), ...
     freezeData.V_sensor_faulty_V(freezeWindow), ...
     "LineWidth",1.2);

xline(freezeStart,"--");

grid on;

xlabel("Time (s)");
ylabel("Sensor Voltage (V)");

title("TMP36 Freeze Fault - Sensor Output");

legend("Healthy","Frozen","Fault Start","Location","best");


figure("Name","TMP36 Freeze - Temperature");

plot(freezeData.Time_s(freezeWindow), ...
     freezeData.T_true_C(freezeWindow), ...
     "LineWidth",1.2);

hold on;

plot(freezeData.Time_s(freezeWindow), ...
     freezeData.T_measured_C(freezeWindow), ...
     "LineWidth",1.2);

xline(freezeStart,"--");

grid on;

xlabel("Time (s)");
ylabel("Temperature (degC)");

title("TMP36 Freeze Fault - Temperature Response");

legend("True Temperature","Measured Temperature", ...
       "Fault Start","Location","best");


figure("Name","TMP36 Freeze - Temperature Error");

plot(freezeData.Time_s(freezeWindow), ...
     freezeData.Temperature_Error_C(freezeWindow), ...
     "LineWidth",1.2);

xline(freezeStart,"--");

yline(0,":");

grid on;

xlabel("Time (s)");
ylabel("Temperature Error (degC)");

title("TMP36 Freeze Fault - Measurement Error");

legend("Temperature Error","Fault Start","Location","best");


%% =========================================================
% Local helper functions
% =========================================================

function T = addDerivedColumns(T)

required = { ...
    "Time_s", ...
    "T_true_C", ...
    "V_sensor_healthy_V", ...
    "V_sensor_faulty_V", ...
    "T_measured_C"};

for k = 1:numel(required)
    if ~ismember(required{k}, T.Properties.VariableNames)
        error("Missing required column: %s", required{k});
    end
end

if ~ismember("Voltage_Error_V", T.Properties.VariableNames)
    T.Voltage_Error_V = ...
        T.V_sensor_faulty_V - T.V_sensor_healthy_V;
end

if ~ismember("Temperature_Error_C", T.Properties.VariableNames)
    T.Temperature_Error_C = ...
        T.T_measured_C - T.T_true_C;
end

end


function startTime = getFaultStart(T)

if ismember("FaultStart_s",T.Properties.VariableNames)
    startTime = T.FaultStart_s(1);
    return;
end

if ismember("FaultActive",T.Properties.VariableNames)

    idx = find(T.FaultActive ~= 0,1,"first");

    if ~isempty(idx)
        startTime = T.Time_s(idx);
        return;
    end
end

error("Fault start time could not be determined from the dataset.");

end
