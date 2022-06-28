function [Xs,Xs_TD] = fun_footstepCombi(msfile, tdfile, modelData,feature_num)
measMat = msfile.measMat;
measMat_TD = tdfile.measMat_TD;

feat_coeffs = modelData.coeffs(:,feature_num);


% Shuffle around measurement vectors
measMatFull = measMat; % [x y z vx vy theta stanceFoot]
measMatMS = measMatFull(:,[1 2 3 4 5]);% [x y z vx vy]
measMatTD = measMat_TD(:,feature_num); 
measMatMS = [measMatMS measMatMS(:,4)*0]; % [x y z vx vy vz] artifically set vertical velocity to zero
stanceFoot = measMatFull(:,end); % record stance foot 1 = right, 2 = left

measMatMS(:,5) = measMatMS(:,5)*0; % set vy to zero

N = size(measMat,1);
%%
% x0 = [0 0.1174 0.9130 0.6350 0 0]';
% u = [0.2875 0.2506 2.9998]';

x_mean = mean(abs(measMat(:,1:6)))'; % compute the mean of the CoM position for the measured data.
x_mean = [x_mean;x_mean(4)]; %We use abs so we can flip the necessary signs as the stance foot changes

x0 = measMatMS(1,1:6)';
L0 = 0.92; % Subject's leg length as measured by Taylor

%% Set up Estimator

x = [x0;x0(4)]; % Set original intent state to be the same as vx

% Tuning Params
P = 1e-2*eye(length(x));
Q = diag([1e-4 1e-4 1e-4 1e-4 1e-4 1e-4 1e-3]);
R_MS = diag([1e-6 1e-6 1e-6 1e-5 1e-10 1e-10]); % x y z vx vy vz at MS
R_TD = 1e-5; % xf at TD
Q_TD = 1e-4;

% R_TD = diag([1e-6 1e-6 1e-6 1e-5 1e-8]);% x y z vx xf at TD

Xs = [];
Ps = [];

assert(size(R_MS,2) == size(measMatMS,2));
assert(size(P,2) == numel(x));

Xs(1,:) = x';
Ps(1,:) = diag(P);

D = eye(length(x));
D(2,2) = (-1)^(stanceFoot(2)+1);
D(5,5) = (-1)^(stanceFoot(2)+1)*-1;

%% Estimation loop
for ct = 2:N
    y_TD = measMatTD(ct,end)';
    y_MS = measMatMS(ct,:)';
    x_mean(4) = x(7); % set vx_mean to estimated intent, vx_d

    H_TD = measJacobian(feat_coeffs);
    
    % Simple dynamics to flip signs on the CoM state acc. to stance foot
%     D = eye(length(x));
%     D(2,2) = (-1)^(stanceFoot(ct)+1);
%     D(5,5) = (-1)^(stanceFoot(ct)+1)*-1;
    
    % Conditional Gaussian at TD
    P(7,7) = P(7,7) + Q_TD;
    Syy = (H_TD*P*H_TD'+R_TD(end,end)); % Model uncertainty
    
    steps(ct-1,:) = [y_TD measModel(x,feat_coeffs)];
    
    x = x + P*H_TD'/Syy*(y_TD - measModel(x,feat_coeffs)); % State Update
    P = P - P*H_TD'/Syy*H_TD*P; % Covariance Update
    Xs_TD(ct,:) = x';
    Ps_TD(ct,:) = diag(P)';
    
    diffCov_TD(ct,1) = subtractedCovariance(P,[7,4]); % Process covariance for later when looking at vx_d - vx
    
    % Kalman Filter at MS
    % Dynamics
    x = D*x;
    P = D*P*D'+Q;
    
    vxd = x(7);
    
    % Update at MS - next stance foot
    H_MS = eye(6,7);
    K = P*H_MS'/(H_MS*P*H_MS'+R_MS); % Kalman gain
        
    x = x + K*(y_MS - H_MS*x); % Kalman update
%     x(7) = vxd; % Override Kalman update for intent
    P = [eye(length(x)) - K*H_MS]*P; % Covariance update
        
    Xs(ct,:) = x';
    Ps(ct,:) = diag(P)';
    diffCov_MS(ct,1) = subtractedCovariance(P,[7,4]);

end

Xs_TD(1,:) = [];
Ps_TD(1,:) = [];
diffCov_TD(1,:) = [];
TDidx = 1.5:1:size(Xs,1);


%% Aux functions

function p = subtractedCovariance(P,idx)

p = P(idx(1),idx(1)) + P(idx(2),idx(2)) - 2*P(idx(1),idx(2));

end

function y = measModel(x,lenCoeffs)
% Measurement model to output step length
% This model computes the predicted step length change with Yang's model
% and adds it to the predicted mean step length using a datadriven fit from
% exo walking data


y = [1 x(4) x(7)-x(4)]*lenCoeffs;

end

function H = measJacobian(lenCoeffs)
% This function outputs the analytical jacobian of the measurement function
% Coeffs from Yang's paper
H = [0 0 0 lenCoeffs(1)-lenCoeffs(2) 0 0 lenCoeffs(2)];
end

end
