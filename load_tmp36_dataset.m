%% load_tmp36_dataset.m
% Load the TMP36 source CSV and prepare the temperature input for Simulink.
%
% The Simulink model uses temperature_C as the true temperature input.
% The CSV's tmp36_output_V column is retained as the healthy reference
% for validation and result analysis.
%
% USE_PREVIEW = true  -> Load only the preview duration.
% USE_PREVIEW = false -> Load the complete source dataset.

clearvars -except faultType faultID faultSeverity_V faultStart_s ...
    faultDuration_s runID;

%% User settings

CSV_FILE = fullfile(pwd, "datasets", ...
    "tmp36_temperature_dataset_1M.csv");

USE_PREVIEW = true;
PREVIEW_DURATION_S = 600;       % 10-minute simulation preview

%% Check source file

if ~isfile(CSV_FILE)
    error("TMP36 source CSV not found: %s", CSV_FILE);
end

%% Read source dataset

tmp36_data = readtable(CSV_FILE);

requiredVars = [ ...
    "time_s", ...
    "temperature_C", ...
    "tmp36_output_V", ...
    "supply_voltage_V" ...
];

availableVars = string(tmp36_data.Properties.VariableNames);
missingVars = setdiff(requiredVars, availableVars);

if ~isempty(missingVars)
    error("Required CSV columns are missing: %s", ...
        strjoin(missingVars, ", "));
end

%% Validate source data

tAll = double(tmp36_data.time_s);
TAll = double(tmp36_data.temperature_C);
VAll = double(tmp36_data.tmp36_output_V);

% Time must be finite and strictly increasing for a time-based simulation.
if any(~isfinite(tAll)) || any(diff(tAll) <= 0)
    error("time_s must contain finite, strictly increasing values.");
end

% Temperature and healthy sensor output must contain valid numeric values.
if any(~isfinite(TAll)) || any(~isfinite(VAll))
    error("Temperature and TMP36 output data must not contain NaN or Inf.");
end

% Verify the expected 0.1-second source sampling interval.
Ts_dataset = median(diff(tAll));

if abs(Ts_dataset - 0.1) > 1e-9
    warning("Dataset sample time is %.12g s instead of the expected 0.1 s.", ...
        Ts_dataset);
end

%% Select simulation data

if USE_PREVIEW
    keep = tAll <= PREVIEW_DURATION_S;
    tmp36_run = tmp36_data(keep, :);
else
    tmp36_run = tmp36_data;
end

%% Prepare signals for Simulink

t = double(tmp36_run.time_s);
T_true = double(tmp36_run.temperature_C);

% The From Workspace block should use true_ts.
% The temperature is converted to TMP36 voltage inside Simulink.
true_ts = timeseries(T_true, t, "Name", "T_true");

% Healthy TMP36 output from the source dataset.
% This is used as the nominal/reference signal during validation.
V_healthy_reference = double(tmp36_run.tmp36_output_V);

%% Store dataset information

dataset_sample_time_s = median(diff(t));
dataset_start_time_s = t(1);
dataset_stop_time_s = t(end);
dataset_num_samples = numel(t);

%% Preview the selected temperature input

figure("Name", "TMP36 Source Temperature");

plot(t, T_true, "LineWidth", 1.1);

grid on;
xlabel("Time (s)");
ylabel("Temperature (degC)");
title("TMP36 Source Temperature Input");

%% Simulink configuration
%
% Configure the existing From Workspace block as:
%
%     Data = true_ts
%
% Keep the Zero-Order Hold after the TMP36 Gain and Bias blocks.
%
% For a preview run, set the Simulink Stop Time to:
%
%     dataset_stop_time_s