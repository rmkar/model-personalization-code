function [Xs,Xs_TD] = fun_BKF_cond(msfile, tdfile, userStruct, figs)

if nargin < 4
    figs = 0;
end

measMat = msfile.measMat;
measMat_TD = tdfile.measMat_TD;

% Shuffle around measurement vectors
measMatFull = measMat; % [x y z vx vy stanceFoot]
measMatMS = measMatFull(:,[1 2 3 4 5]);% [x y z vx vy]
measMatMS = [measMatMS measMatMS(:,4)*0]; % [x y z vx vy vz] artifically set vertical velocity to zero

measMat_TD(:,2) = [];
measMatTD = measMat_TD;

stanceFoot = measMatFull(:,end); % record stance foot 1 = right, 2 = left
N = size(measMat,1);

x0 = measMatMS(1,1:6)';

%% Set up Estimator

x = [x0;x0(4)]; % Set original intent state to be the same as vx

% Tuning Params
P = 1e-4*eye(length(x));
Q = diag([1e-4 1e-4 1e-4 1e-4 1e-4 1e-4 1e-2]);
R_MS = diag([1e-6 1e-6 1e-6 1e-5 1e-10 1e-10]); % x y z vx vy vz at MS

Xs = [];
Ps = [];

assert(size(R_MS,2) == size(measMatMS,2));
assert(size(P,2) == numel(x));

Xs(1,:) = x';
Ps(1,:) = diag(P);

D = eye(length(x));
D(2,2) = (-1)^(stanceFoot(2)+1);
D(5,5) = (-1)^(stanceFoot(2)+1)*-1;

for ct = 2:N
    y_TD = measMatTD(ct,:)';
    y_MS = measMatMS(ct,:)';
    
    feat_vec = [y_TD;x(4)];
    
    [vxd_hat,P_vxd] = userStruct.estimate_vel(feat_vec,userStruct.model_mean,userStruct.model_cov,[userStruct.selected_feat]);
    
    % Conditional Gaussian at TD
    P(7,7) = P_vxd;
    x(7) = vxd_hat;
    
    Xs_TD(ct,:) = x';
    Ps_TD(ct,:) = diag(P)';
    
    diffCov_TD(ct,1) = subtractedCovariance(P,[7,4]); % Process covariance for later when looking at vx_d - vx
    
    % Kalman Filter at MS
    % Dynamics
    x = D*x;
    P = D*P*D'+Q;
    
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

if figs == 1
    commandStep = msfile.commandStep;
    %% Plots
    figure(1)
    plot(Xs(:,7),'-ko');
    hold on
    plot(Xs(:,4),'-*');
    plot(measMat(1:size(Xs,1),4),'-s');
    plot(TDidx,Xs_TD(:,7),'-ro');
    hold off
    legend('Estimated Intent at MS $\hat{v}_x^d$','Estimated Speed $\hat{v}_x$','Measured Speed $v_x$','Estimated Intent at TD $\hat{v}_x^d$','Interpreter','Latex')
    xlabel('Steps','Interpreter','Latex')
    ylabel('Forward Velocity, $v_x$ (m/s)','Interpreter','Latex')
    vline(commandStep,':k')
    
    figure(2)
    yyaxis left
    plot(measMat(1:size(Xs,1),4),'-*');
    ylabel('Velocity (m/s)','Interpreter','Latex');
    hold on
    % plot(Xs(:,4)-measMat(1:size(Xs,1),4),'-*');
    yyaxis right
%     stem(TDidx,[0;diff(abs(Xs_TD(:,7)))],'--');
    stem(TDidx,Xs_TD(:,7) - Xs(1:end-1,4),'--');
    yline(userStruct.ss_threshold,'--k');
    yline(-userStruct.ss_threshold,'--k');
    hold off
    xlabel('Steps','Interpreter','Latex');
    ylabel('Estimated Intent Change (m/s/step)','Interpreter','Latex');
    legend('Measured Velocity, $\tilde{z}$ ','$\Delta(\hat{z})$ at TD','Significance Threshold','Interpreter','Latex')
    vline(commandStep,':k')
    
    figure(3)
    semilogy(sqrt(Ps(:,7)));
    hold on
    semilogy(TDidx,sqrt(Ps_TD(:,7)));
    hold off
    vline(commandStep,':k')
    legend('Uncertainty at MS','Uncertainty at TD')
    xlabel('Steps','Interpreter','Latex')
    ylabel('Uncertainty of $\hat{v}_x^d$ (m/s)','Interpreter','Latex');
end


%% Aux functions

    function p = subtractedCovariance(P,idx)
        
        p = P(idx(1),idx(1)) + P(idx(2),idx(2)) - 2*P(idx(1),idx(2));
        
    end

end