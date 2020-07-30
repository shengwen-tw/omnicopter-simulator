math = se3_math;

R45_p = math.euler_to_dcm(deg2rad(45), 0, 0);
R45_n = math.euler_to_dcm(deg2rad(-45), 0, 0);

d = 2;

%position vectors (before transform)
p1 = [d * sin(deg2rad(45)); d * cos(deg2rad(45)); 0];
p2 = [d * sin(deg2rad(45)); -d * cos(deg2rad(45)); 0];
p3 = [-d * sin(deg2rad(45)); -d * cos(deg2rad(45)); 0];
p4 = [-d * sin(deg2rad(45)); d * cos(deg2rad(45)); 0];
p5 = [d * sin(deg2rad(45)); d * cos(deg2rad(45)); 0];
p6 = [d * sin(deg2rad(45)); -d * cos(deg2rad(45)); 0];
p7 = [-d * sin(deg2rad(45)); -d * cos(deg2rad(45)); 0];
p8 = [-d * sin(deg2rad(45)); d * cos(deg2rad(45)); 0];


%direction vectors (before transform)
r1 = [0; 0; -1];
r2 = [0; 0; -1];
r3 = [0; 0; -1];
r4 = [0; 0; -1];
r5 = [0; 0; 1];
r6 = [0; 0; 1];
r7 = [0; 0; 1];
r8 = [0; 0; 1];

%transform
if 1  
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

%3d plot
figure
xlim([-3, 3]);
ylim([-3, 3]);
zlim([-3, 3]);
xlabel('x')
ylabel('y')
zlabel('z')
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

pause;
close all;