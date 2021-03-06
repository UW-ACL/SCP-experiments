

N = 15;
g = 9.806;
tau = linspace(0,1,N);
tau_fine = linspace(0,1,N*10);

xT = 3;
yT = 3;

x_true = @(C,phi) 0.5 * C * ( phi - sin(phi) );
y_true = @(C,phi) C * ( 0.5 - 0.5 * cos(phi) );
func = @(Z) [x_true(Z(1),Z(2)) - xT;
             y_true(Z(1),Z(2)) - yT];

Z = fsolve(func,rand(2,1));
C = Z(1); phiT = Z(2);
T = sqrt(C/g)*phiT;

assert(abs(x_true(C,phiT) - xT)<1e-7);
assert(abs(y_true(C,phiT) - yT)<1e-7);


