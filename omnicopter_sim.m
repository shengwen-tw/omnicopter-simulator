function omnicopter_sim()
ITERATION_TIMES = 20000;

math = se3_math;

%%%%%%%%%%%%%%
% Parameters %
%%%%%%%%%%%%%%
omnicopter_mode = true;

%parameters of uav dyanmics
uav_dynamics = dynamics;        %create uav dynamics object
uav_dynamics.dt = 0.001;        %set iteration period [sec]
uav_dynamics.mass = 1;          %set uav mass [kg]
uav_dynamics.a = [0; 0; 0];     %acceleration of uav [m/s^2], effected by applied force
uav_dynamics.v = [0; 0; 0];     %initial velocity of uav [m/s]
uav_dynamics.x = [0; 0; 0];     %initial position of uav [m]
uav_dynamics.W = [0; 0; 0];     %initial angular velocity of uav
uav_dynamics.W_dot = [0; 0; 0]; %angular acceleration of uav, effected by applied moment
uav_dynamics.f = [0; 0; 0];     %force generated by controller
uav_dynamics.M = [0; 0; 0];     %moment generated by controller
uav_dynamics.J = [0.01466 0 0;  %inertia matrix of uav
    0 0.01466 0;
    0 0 0.02848];

%initial attitude (DCM)
init_attitude(1) = deg2rad(0); %roll
init_attitude(2) = deg2rad(0); %pitch
init_attitude(3) = deg2rad(0); %yaw
uav_dynamics.R = math.euler_to_dcm(init_attitude(1), init_attitude(2), init_attitude(3));

%parameters of omnicopter
l = 0.5;
h = 0.5;
d = 2;

propeller_drag_coeff = 1;
motor_max_thrust = 900 * 8.825985; %[gram force] to [N]

%omnicopter control gains
omnicopter_kx = [7.0; 7.0; 7.0];
omnicopter_kv = [3.0; 3.0; 3.0];
omnicopter_kR = [10; 10; 10];
omnicopter_kW = [2; 2; 2];

%rotation matrices for performing shape morphing
R45_p = math.euler_to_dcm(deg2rad(45), 0, 0);
R45_n = math.euler_to_dcm(deg2rad(-45), 0, 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization: calculate position and direction vectors %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%position vectors (octorotor mode)
p1 = [d * sin(deg2rad(45)); d * cos(deg2rad(45)); 0];
p2 = [d * sin(deg2rad(45)); -d * cos(deg2rad(45)); 0];
p3 = [-d * sin(deg2rad(45)); -d * cos(deg2rad(45)); 0];
p4 = [-d * sin(deg2rad(45)); d * cos(deg2rad(45)); 0];
p5 = [d * sin(deg2rad(45)); d * cos(deg2rad(45)); 0];
p6 = [d * sin(deg2rad(45)); -d * cos(deg2rad(45)); 0];
p7 = [-d * sin(deg2rad(45)); -d * cos(deg2rad(45)); 0];
p8 = [-d * sin(deg2rad(45)); d * cos(deg2rad(45)); 0];

%direction vectors (octorotor mode)
r1 = [0; 0; -1];
r2 = [0; 0; -1];
r3 = [0; 0; -1];
r4 = [0; 0; -1];
r5 = [0; 0; 1];
r6 = [0; 0; 1];
r7 = [0; 0; 1];
r8 = [0; 0; 1];

%transform to omnicopter mode
if omnicopter_mode == true
    p1 = R45_n * p1;
    p2 = R45_p * p2;
    p3 = R45_p * p3;
    p4 = R45_n * p4;
    p5 = R45_p * p5;
    p6 = R45_n * p6;
    p7 = R45_n * p7;
    p8 = R45_p * p8;
    
    r1 = R45_n * r1;
    r2 = R45_p * r2;
    r3 = R45_p * r3;
    r4 = R45_n * r4;
    r5 = R45_p * r5;
    r6 = R45_n * r6;
    r7 = R45_n * r7;
    r8 = R45_p * r8;
end

%translate from hinge coordinatre frame to COG coordinate frame
p1 = math.translation(0, +l*0.5, -h*0.5, p1);
p2 = math.translation(0, -l*0.5, -h*0.5, p2);
p3 = math.translation(0, -l*0.5, -h*0.5, p3);
p4 = math.translation(0, +l*0.5, -h*0.5, p4);
p5 = math.translation(0, +l*0.5, +h*0.5, p5);
p6 = math.translation(0, -l*0.5, +h*0.5, p6);
p7 = math.translation(0, -l*0.5, +h*0.5, p7);
p8 = math.translation(0, +l*0.5, +h*0.5, p8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization of position and direction vectors %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3d plot
figure
xlim([-3, 3]);
ylim([-3, 3]);
zlim([-3, 3]);
xlabel('x')
ylabel('y')
zlabel('z')
daspect([1 1 1])
view(-35,45);
grid on
hold on

%plot position vectors
quiver3(0, 0, 0, p1(1), p1(2), p1(3), 'color', [0 0 1]);
quiver3(0, 0, 0, p2(1), p2(2), p2(3), 'color', [0 0 1]);
quiver3(0, 0, 0, p3(1), p3(2), p3(3), 'color', [0 0 1]);
quiver3(0, 0, 0, p4(1), p4(2), p4(3), 'color', [0 0 1]);
quiver3(0, 0, 0, p5(1), p5(2), p5(3), 'color', [0 0 1]);
quiver3(0, 0, 0, p6(1), p6(2), p6(3), 'color', [0 0 1]);
quiver3(0, 0, 0, p7(1), p7(2), p7(3), 'color', [0 0 1]);
quiver3(0, 0, 0, p8(1), p8(2), p8(3), 'color', [0 0 1]);

%plot direction vectors
quiver3(p1(1), p1(2), p1(3), r1(1), r1(2), r1(3), 'color', [1 0 0]);
quiver3(p2(1), p2(2), p2(3), r2(1), r2(2), r2(3), 'color', [1 0 0]);
quiver3(p3(1), p3(2), p3(3), r3(1), r3(2), r3(3), 'color', [1 0 0]);
quiver3(p4(1), p4(2), p4(3), r4(1), r4(2), r4(3), 'color', [1 0 0]);
quiver3(p5(1), p5(2), p5(3), r5(1), r5(2), r5(3), 'color', [1 0 0]);
quiver3(p6(1), p6(2), p6(3), r6(1), r6(2), r6(3), 'color', [1 0 0]);
quiver3(p7(1), p7(2), p7(3), r7(1), r7(2), r7(3), 'color', [1 0 0]);
quiver3(p8(1), p8(2), p8(3), r8(1), r8(2), r8(3), 'color', [1 0 0]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct omnicopter Jacobian matrix %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%position matrix
P = [p1, p2, p3, p4, p5, p6, p7, p8];

%force Jacobian
Jf = [r1, r2, r3, r4, r5, r6, r7, r8];

%moment Jacobian
Jm_thrust = [cross(p1, r1), ...
    cross(p2, r2), ...
    cross(p3, r3), ...
    cross(p4, r4), ...
    cross(p5, r5), ...
    cross(p6, r6), ...
    cross(p7, r7), ...
    cross(p8, r8)];
Jm_drag = propeller_drag_coeff * P .* Jf;
Jm = Jm_thrust + Jm_drag;

%force/moment Jacobian
J = [Jf; Jm];

disp("force/moment Jacobian:");
disp(J);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct matrices and vectors for force/moment optimization QP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q = eye(8);
tb = [-motor_max_thrust;
    -motor_max_thrust;
    -motor_max_thrust;
    -motor_max_thrust;
    -motor_max_thrust;
    -motor_max_thrust;
    -motor_max_thrust;
    -motor_max_thrust];
tu = [motor_max_thrust;
    motor_max_thrust;
    motor_max_thrust;
    motor_max_thrust;
    motor_max_thrust;
    motor_max_thrust;
    motor_max_thrust;
    motor_max_thrust];

%%%%%%%%%%%%%%%%%%%%%
% Control main loop %
%%%%%%%%%%%%%%%%%%%%%
for i = 1: ITERATION_TIMES
    disp(sprintf('%dth iteration', i));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update System Dynamics %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    uav_dynamics = update(uav_dynamics);
    
    %desired attutide (DCM)
    desired_roll = deg2rad(0);
    desired_pitch = deg2rad(0);
    desired_yaw = deg2rad(0);
    Rd = math.euler_to_dcm(desired_roll, desired_pitch, desired_yaw);
    Rdt = Rd';
    
    Rt = uav_dynamics.R';
    I = eye(3);
    
    %attitude errors expressed in principle rotation angle
    eR_prv = 0.5 * trace(I - Rdt*uav_dynamics.R);
    
    %desired angular velocity
    Wd = [0; 0; 0];
    
    %desired angular acceleration
    W_dot_d = [0; 0; 0];
    
    %attitude error and attitude rate errors
    eR = 0.5 * math.vee_map_3x3((Rd'*uav_dynamics.R - Rt*Rd));
    eW = uav_dynamics.W - Rt*Rd*Wd;
    
    %calculate feedforward moment
    WJW = cross(uav_dynamics.W, uav_dynamics.J * uav_dynamics.W);
    M_feedfoward = WJW - uav_dynamics.J*(math.hat_map_3x3(uav_dynamics.W)*Rt*Rd*Wd - Rt*Rd*W_dot_d);
    
    %calculate desired moment
    M_d = [-omnicopter_kR(1)*eR(1) - omnicopter_kW(1)*eW(1) + M_feedfoward(1);
        -omnicopter_kR(2)*eR(2) - omnicopter_kW(2)*eW(2) + M_feedfoward(2);
        -omnicopter_kR(3)*eR(3) - omnicopter_kW(3)*eW(3) + M_feedfoward(3)];
    
    %calculate desired force
    
    F_d = [0; 0; 0]; %FIXME: DELETE THIS!
    M_d = [0; 0; 0]; %FIXME: DELETE THIS!
    
    %calculate motor thrust via optimization
    options = [];
    %options = optimoptions('quadprog','Display','off'); %make quadprog silent
    zeta = [F_d; M_d];
    f_motors = quadprog(Q, [], [], [], J, zeta, tb, tu, [], options);
    
    %convert motor thrusts to rigirbody force/torque
    p_array = [p1, p2, p3, p4, p5, p6, p7, p8];
    r_array = [r1, r2, r3, r4, r5, r6, r7, r8];
    f = omnicopter_thrust_to_force(f_motors, r_array);
    M = omnicopter_thrust_to_moment(f_motors, p_array, r_array, propeller_drag_coeff);
    
    %feed force/torque to the dynamics system
    uav_dynamics.M = M;
    uav_dynamics.f = f;
end

pause;
close all;

end

function f=omnicopter_thrust_to_force(f_motors, r_array)
    f = 0;
    for i = 1: 8
        f = f + (f_motors(i) * r_array(:, i));
    end
end

function M=omnicopter_thrust_to_moment(f_motors, p_array, r_array, propeller_drag_coeff)
    M = 0;
    for i = 1: 8
        M = M + f_motors(i) * cross(p_array(:, i), r_array(:, i)) + ...
            (propeller_drag_coeff * f_motors(i) * r_array(:, i));
    end
end
