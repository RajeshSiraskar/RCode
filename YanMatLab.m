%-----------------------------------------------------------
% Yanmar Project
% Date:     03-July-2015
% Author:   Rajesh Siraskar
%-----------------------------------------------------------
% Event at: 16-May-2010 23:11:42 i.e. Record 85,2110
% Important Features: 10, 21 and 24
% Data frequency: 5 secs.
% Benchmark: 4 mins = 4*60 = 240 secs. i.e. 48 records
%-----------------------------------------------------------
% Idea: Regression on normalized ALL vars.
% 4	5	10	18	19	20	21	22	23	24	25	27	28	29	30	31
%-----------------------------------------------------------

clc;

fprintf('\n-----------------------------------------------------------\n');
fprintf('\n              YANMAR PROJECT\n');
fprintf('\n              Regression on normalized ALL vars.\n');
fprintf('\n 4	5	10	18	19	20	21	22	23	24	25	27	28	29	30	31\n');
fprintf('\n-----------------------------------------------------------\n');

% # Define
LOADDATA = true;
rEvent = 852110;  % Actual recorded event: 852110
windowPre = 120;
windowPost = 100;
windowBM = windowPre - (4*60/5); % Benchmark, 4 mins

iFeatures = [4	5	10	18	19 20	21	22	23	24	25	27	28	29	30	31];

nVars = length(iFeatures);

% Create matrix for just selected features
nRecords = (windowPre + windowPost + 1);
YData = zeros(nRecords, length(iFeatures));

if (LOADDATA)
    fprintf('\nLoad data...');
    load ('YanmarData.mat');
    fprintf('\nCut data...');
    
    for i = 1:nVars
        YData(:,i) = Data1((rEvent-windowPre):(rEvent+windowPost), iFeatures(i));
    end
    
    fprintf('\nClear all other variables...\n\n');
    clearvars variables Data1 Data2 Data3 AllTimeStamp;
    LOADDATA = false;
end

% Feature normalize variables to scale

for i = 1:nVars
    % Normalize column 1
    mu = mean(YData(:,i));
    stddev = std(YData(:,i));
    mu = repmat(mu, [length(YData) 1]);
    stddev = repmat(stddev, [length(YData) 1]);

    YData (:,i) = (YData(:,i) - mu)./stddev;
end

figure();
hold off;
for i = 1:nVars
    fprintf('\nPlot %s\n', char(Ship.VarNames(iFeatures(i))));
    pause();
    plot(YData(:,i));
    title(Ship.VarNames(iFeatures(i)))
    %hold on;
    minY = 0.9*min(YData(:,i));
    maxY = 1.1*max(YData(:,i));
    line ([windowPre windowPre], [minY maxY], 'LineWidth', 1, 'LineStyle', '-.', 'Color', [0.2 0.4 1.0])
    line ([windowBM windowBM],   [minY maxY], 'LineWidth', 1, 'LineStyle', '-.', 'Color', [0.2 0.4 1.0])
   
end
