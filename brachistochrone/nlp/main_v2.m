clear all
clc

problem_data;
len_Z = 6*N+1;

cost_func = @(Z) Z(end);
Aeq = zeros(6,len_Z);
Aeq(1,1) = 1;
Aeq(2,N) = 1;
Aeq(3,N+1) = 1;
Aeq(4,2*N) = 1;
Aeq(5,2*N+1) = 1;
Aeq(6,3*N+1) = 1;
beq = [0;xT;0;yT;0;0];
A = [];
b = [];

% alg = 'interior-point';
alg = 'sqp';
opts = optimoptions('fmincon','Algorithm',alg,'Display','iter','MaxIterations',1e3,'MaxFunctionEvaluations',1e5,'UseParallel',true,'EnableFeasibilityMode',true);
Z = fmincon(@(Z) cost_func(Z),ones(len_Z,1),[],[],Aeq,beq,[],[],@(Z) constr_func(Z,@dyn_func_v2),opts);

z = [Z(1:N),Z(N+1:2*N),Z(2*N+1:3*N),Z(3*N+1:4*N)]';
u = [Z(4*N+1:5*N),Z(5*N+1:6*N)]';
s = Z(end);
[~,zz,uu,~] = propagate_foh(tau,z,u,s,@dyn_func_v2,'Single');

figure
plot(zz(1,:),zz(2,:),'-b');
hold on
plot(z(1,:),z(2,:),'om');
plot(x_true(C,T*tau_fine),y_true(C,T*tau_fine),'-r')
aX = gca;
aX.YDir = 'reverse';
legend('fmicon single shoot','truth');

function [c,ceq] = constr_func(Z,func)
    N = (length(Z)-1)/6;
    g = 9.806;
    z = [Z(1:N),Z(N+1:2*N),Z(2*N+1:3*N),Z(3*N+1:4*N)]';
    u = [Z(4*N+1:5*N),Z(5*N+1:6*N)]';
    s = Z(end);
    tau = linspace(0,1,N);
    [~,~,~,zprop] = propagate_foh(tau,z,u,s,func,'Multiple');
    ceq = reshape(z(:,2:end) - zprop(:,2:end),[4*N-4,1]);
    for k = 1:N-1
        ceq(end+1) = u(:,k)'*z(3:4,k);
%         ceq(end+1) = u(:,k)'*(u(:,k)+[0;g])+z(3:4,k)'*(u(:,k+1)-u(:,k))*(N-1);
%         dz = func(tau(k),z(:,k),u(:,k),s);
%         thet = atan(dz(2)/dz(1));
%         ceq(end+1) = - u(1,k)*sin(thet) + u(2,k)*cos(thet) + g*cos(thet);
    end
    c = [];
%     for k = 1:N
%         c(end+1) = norm(u(:,k)) - g;
%     end
end