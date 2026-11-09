%% export_tmp36_freeze_fault_dataset.m
% Export Simulink Freeze fault results to an Excel dataset.
%
% The dataset combines the healthy TMP36 reference from the source CSV
% with the faulty sensor output, measured temperature, and derived
% fault-analysis features from the Simulink simulation.

clearvars -except V_faulty_log T_measured_log tmp36_data

%% Fault configuration

FAULT_TYPE = "Freeze";
FAULT_ID = 2;

% Freeze is identified by a held sensor output rather than a fixed
% voltage offset, so voltage severity is represented as zero.
FAULT_SEVERITY_V = 0;

% Must match the Timed trigger configured in Fault Analyzer.
FAULT_START_S = 300;

RUN_ID = "TMP36_Freeze_Run001";

OUTPUT_FILE = fullfile( ...
    "results", ...
    "TMP36_Freeze_Run001.xlsx");

CSV_FILE = fullfile( ...
    "datasets", ...
    "tmp36_temperature_dataset_1M.csv");

%% Validate source file

if ~isfile(CSV_FILE)
    error("Source CSV not found: %s", CSV_FILE);
end

%% Validate required simulation variables

if ~exist("tmp36_data", "var")
    error("tmp36_data is not available in the Workspace.");
end

if ~exist("V_faulty_log", "var")
    error("V_faulty_log is not available in the Workspace. Run the Freeze simulation first.");
end

if ~exist("T_measured_log", "var")
    error("T_measured_log is not available in the Workspace. Run the Freeze simulation first.");
end

%% Read healthy source dataset

sourceData = readtable(CSV_FILE);

requiredColumns = [ ...
    "time_s", ...
    "temperature_C", ...
    "tmp36_output_V"];

availableColumns = string(sourceData.Properties.VariableNames);

missingColumns = setdiff(requiredColumns, availableColumns);

if ~isempty(missingColumns)
    error("Required CSV columns are missing: %s", ...
        strjoin(missingColumns, ", "));
end

%% Extract logged Simulink signals

faultTime = double(V_faulty_log.Time(:));
V_faulty = double(V_faulty_log.Data(:));

measuredTime = double(T_measured_log.Time(:));
T_measured = double(T_measured_log.Data(:));

%% Validate logged signals

if numel(faultTime) ~= numel(V_faulty)
    error("V_faulty_log Time/Data size mismatch.");
end

if numel(measuredTime) ~= numel(T_measured)
    error("T_measured_log Time/Data size mismatch.");
end

if any(~isfinite(faultTime)) || any(diff(faultTime) <= 0)
    error("V_faulty_log time values must be finite and strictly increasing.");
end

if any(~isfinite(measuredTime)) || any(diff(measuredTime) <= 0)
    error("T_measured_log time values must be finite and strictly increasing.");
end

%% Use faulty-signal time base

t = faultTime;

%% Obtain healthy reference from source dataset

sourceTime = double(sourceData.time_s);

% Interpolate the source reference to the Simulink fault-signal timestamps.
T_true = interp1( ...
    sourceTime, ...
    double(sourceData.temperature_C), ...
    t, ...
    "linear", ...
    "extrap");

V_healthy = interp1( ...
    sourceTime, ...
    double(sourceData.tmp36_output_V), ...
    t, ...
    "linear", ...
    "extrap");

%% Align measured temperature

% Align the measured temperature with the faulty sensor-output timestamps
% so that sample-wise errors can be calculated correctly.
T_measured_aligned = interp1( ...
    measuredTime, ...
    T_measured, ...
    t, ...
    "linear", ...
    "extrap");

%% Generate sample and fault labels

% A sample is valid when the faulty sensor output is finite.
SampleValid = isfinite(V_faulty);

% Identify samples occurring after the Freeze fault activation time.
FaultActive = t >= FAULT_START_S;

N = numel(t);

FaultType = repmat("Normal", N, 1);
FaultType(FaultActive) = FAULT_TYPE;

FaultID = zeros(N, 1);
FaultID(FaultActive) = FAULT_ID;

FaultSeverity = zeros(N, 1);
FaultSeverity(FaultActive) = FAULT_SEVERITY_V;

RunID = repmat(string(RUN_ID), N, 1);

%% Calculate fault-analysis features

% Difference between faulty and healthy sensor outputs.
Voltage_Error = V_faulty - V_healthy;

% Difference between measured and true temperature.
Temperature_Error = T_measured_aligned - T_true;

% Rate of change of the faulty sensor output.
dVdt = [0; diff(V_faulty) ./ diff(t)];

%% Create labeled dataset

result = table( ...
    (1:N)', ...
    RunID, ...
    t, ...
    T_true, ...
    V_healthy, ...
    V_faulty, ...
    T_measured_aligned, ...
    Voltage_Error, ...
    Temperature_Error, ...
    dVdt, ...
    SampleValid, ...
    FaultActive, ...
    FaultID, ...
    FaultType, ...
    FaultSeverity, ...
    repmat(FAULT_START_S, N, 1), ...
    'VariableNames', { ...
    'Sample_ID', ...
    'Run_ID', ...
    'Time_s', ...
    'T_true_C', ...
    'V_sensor_healthy_V', ...
    'V_sensor_faulty_V', ...
    'T_measured_C', ...
    'Voltage_Error_V', ...
    'Temperature_Error_C', ...
    'dV_dt_V_per_s', ...
    'SampleValid', ...
    'FaultActive', ...
    'Fault_ID', ...
    'FaultType', ...
    'FaultSeverity_V', ...
    'FaultStart_s'});

%% Create output directory

if ~isfolder("results")
    mkdir("results");
end

%% Replace previous output file

if isfile(OUTPUT_FILE)
    try
        delete(OUTPUT_FILE);
    catch ME
        error("Unable to replace the existing output file. " + ...
            "Close the Excel file and run the script again.\n%s", ...
            ME.message);
    end
end

%% Export dataset to Excel

writetable( ...
    result, ...
    OUTPUT_FILE, ...
    "Sheet", ...
    "Freeze_Fault");