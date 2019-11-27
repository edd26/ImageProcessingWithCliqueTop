clc
clear all
%% Add path tothe Cique-top library
addpath("clique-top")
%% Load the matricies with the data
loading = true;
if loading
    load("geometric_matrix.csv")
    load("shuffeled_matrix.csv")
    load("random_matrix.csv")
end
%% Compute the clique topology
% The bigger the matrix, the longer the computations (45 mins for 88x88
% matrix)
ending = 66;

[bettiCurves, edgeDensities, persistenceIntervals,...
        unboundedIntervals] =  compute_clique_topology( ...
            geometric_matrix(1:ending, 1:ending), 'Algorithm', 'combine');

%% Print the Betti curves

figure
plot(edgeDensities, bettiCurves(:,1), 'g--')
hold on
plot(edgeDensities, bettiCurves(:,2), 'r--')
plot(edgeDensities, bettiCurves(:,3), 'b--')

title("Betti curves for geometric matrix")
legend("\beta_0","\beta_1","\beta_2")
hold off