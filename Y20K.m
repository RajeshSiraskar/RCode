%-----------------------------------------------------------
% Yanmar Project
% Date:     05-July-2015
% Author:   Rajesh Siraskar
%-----------------------------------------------------------
% - Works on windowed data (20 K records)
% - Event at: 16-May-2010 23:11:42 i.e. Record# 85,2110
% - Engine # 1, Cylinder #5
% - Important Features: 10, 21 and 24
% - Data frequency: 5 secs.
% - Benchmark: 4 mins = 4*60 = 240 secs. i.e. 48 records
%-----------------------------------------------------------
%-----------------------------------------------------------

function Y20K (rWindow)

clc;

fprintf('\n-----------------------------------------------------------\n');
fprintf('\n                YANMAR PROJECT\n');
fprintf('\n              Y20K ! 05-Jul-2015\n');
fprintf('\n-----------------------------------------------------------\n');

% Load data
load('YData.mat')

if (nargin == 0) 
    fprintf('\nAssumed window of 100+50 dps\n');
    rWindow = 19900;    
else
    if (rWindow > length(YData1)) 
        error ('ERROR! Window exceeds no. of records. Abort!');
    end
    fprintf('\nAnalyze window of %d+50 dps\n', rWindow);
end

% ORIGINAL DATA Milestones
rEvent     = 852110;
windowPre  = 20000;
windowPost = 50;

% Windowed data start/end records mapped to original data
wStartRecord = rEvent - windowPre;
wEndRecord   = rEvent + windowPost;

windowBM = (4*60/5); % Benchmark, 4 mins

% Select features or all?
% All features 
% iFeatures = 1:32;
% Selected features
iFeatures = [1 4:25 27 31];

nVars = length(iFeatures);

% Create matrix for just selected features
nRecords = (windowPre + windowPost + 1);
YData = zeros(nRecords, length(iFeatures));

figure();
hold off;

% Truncate here based on zoom desired
% rWindow: Length of window to analyze
YData = YData1((nRecords-rWindow):end, :);

% Replace Engine run = 1 and engine stop=0
KEngineStops = (YData(:, 1) < 0);
KEngineStops = not(KEngineStops); % 0 where stop and 1 where on
YData(:, 1) = KEngineStops;

XMAX = length(YData);

% Window markers
xPre = XMAX - windowPost - windowBM;
xBM = XMAX - windowPost;

for i = 1:nVars
    fprintf('\nPlot %s\n', char(Ship.VarNames(iFeatures(i))));  
    pause();
    plot(YData(:,i), 'LineWidth', 1.5);
    xlim([0 XMAX]);
    title(strcat(num2str(iFeatures(i)), ': ', Ship.VarNames(iFeatures(i))))
    %hold on;
    minY = 0.9*min(YData(:,i));
    maxY = 1.1*max(YData(:,i));
    line ([xPre xPre], [minY maxY], 'LineWidth', 1, 'LineStyle', '-.', 'Color', [0.2 0.4 1.0])
    line ([xBM xBM],   [minY maxY], 'LineWidth', 1, 'LineStyle', '-.', 'Color', [0.2 0.4 1.0])   
end
