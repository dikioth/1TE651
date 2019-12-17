
%% METHOD 1: Recursive Least Square (RLS) Method.

% Description:
% Assumming that the target signal is a linear combination of x1 and x2.
%
%           N                     M
%          ___                   ===
%          \                     \
% xT[n] =  /    a_i * x1[n-i] +  /    b_i * x2[n-i]
%          ===                   ===
%          i = 0                 i = 0

% step 1: Using the frst 9.5 minutes of xT[n], x1[n], x2[n],
%         train the RLS filter and estimate the coefficients ai and bi.
% step 2: Estimate the last 0.5 minute (125*30 samples) by

% Importing filters and custom functions files.
addpath('filters', 'functions');

% Starting w/ patient 2 (by teacher suggestion)
p = 2; % Patient number
M = 70; % Filter tap for x1
N = 100; % Filter tap for x2

% Loading data from directory.
p2 = getpatient(p);

% Zero meaned signals.
[xTzm, xTmean] = getzeromean(p2.xT);
[x1zm, ~] = getzeromean(p2.x1);
[x2zm, ~] = getzeromean(p2.x2);

% Filter coefficients theta for x1 and x2. (RLS method).
ai = customRLS(xTzm, x1zm, M, 0.99);
bi = customRLS(xTzm, x2zm, N, 0.99);

% Reconstructing the last 30 secs (125*30 = 3750 samples)
xhatn1 = getReconstruction(ai, x1zm, 3750);
xhatn2 = getReconstruction(bi, x2zm, 3750);
xhat = xhatn1 + xhatn2 + xTmean;
%
xhat = getReconstruction(xTzm(1:107), x2zm, 3750) + xTmean;
% Performaance analysis
[Q1, Q2] = getPerformance(p2.xTm, xhat);

% Comparing reconstruction xhat and missing singal xm.
figure;
hold on;
plot(p2.xTm);
plot(xhat);
hold off;

%% Method 2: Kalman filter


% The target signal xT is defined as
%
% xT[n] = { xT[n-L], for 0 <= n <= L,       (*)
%         {  0       otherwise
%
% where L is the length of the missing part (125*30 = 3750 in this case).

close all; clear all; clc;
% importing filter and custom functions.
addpath('filters', 'functions');

% Loading data.
p2 = getpatient(2);

% Zero mean signals.
[xTzm, xTmean] = getzeromean(p2.xT);
[x1zm, x1mean] = getzeromean(p2.x1);
[x2zm, x2mean] = getzeromean(p2.x2);

% index
ii = p2.indexMissingPart;

% Extendind xT as defined in (*)
xTzm_ext = vertcat(p2.xT, zeros(125*30, 1));

% Kalman filter
[xhat, F] = customKF(xTzm_ext, x2zm, 106);

plot(xhat(1,:));


%% Signal modelling
close all;
p = 10000;
[ai, w] = aryule(p2.xT,p-1);

F = vertcat(ai, eye(p-1, p));
plot(F*p2.xT(1:p))
hold on; plot([0;p2.xT(1:p)], '--')


%% ADAM OPTIMIZER
close all; clc;
addpath('filters', 'functions');
p2 = getpatient(2);

% Zero mean signals.
[xTzm, xTmean] = getzeromean(p2.xT);
[x1zm, x1mean] = getzeromean(p2.x1);
[x2zm, x2mean] = getzeromean(p2.x2);

cc =  customADAM(xTzm, x2zm, 27);
xhat = getReconstruction(cc, x2zm,125*30) + xTmean;
plot(xhat)
hold on;
plot(p2.xTm, '--');
xlim([1, 125*5]);


%% LOOP
Qvect = zeros(200,1);
nn = 1;
while nn < 200
cc =  customADAM(xTzm, x2zm, nn);
xhat = getReconstruction(cc, x2zm,125*30) + xTmean;
[Q1, ~] = getPerformance(p2.xTm, xhat);

Qvect(nn) = Q1;
nn = nn + 1
end

