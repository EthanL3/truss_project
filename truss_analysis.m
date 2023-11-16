load('PracticeProblemInput.mat'); 

[C_rows, C_cols] = size(C);

Ax = zeros(C_rows, C_cols);
Ay = zeros(C_rows, C_cols);

total_length = 0;
total_cost = 10 * C_rows;
added_to_length = false;

%longest member will buckle first:
buckling_member = 0; %member number
buckling_length = 0; %member length 
%Loop for Ax matrix
for i = 1:C_rows
    members = find(C(i,:)); %columns of C
    for j = 1:numel(members)
        joints = find(C(:, members(j))); %rows of C
        joints = joints';
        x1 = X(joints(1)); %lower x
        x2 = X(joints(2)); %higher x
        y1 = Y(joints(1)); %lower y
        y2 = Y(joints(2)); %higher y
        r = sqrt((x2 - x1)^2 + (y2 - y1)^2);
        if r > buckling_length
            buckling_length = r;
            buckling__member = members(j);
        end
        total_length = total_length + r;
        if i == min(joints)
            Ax(i, members(j)) = (x2 - x1)/r;
            Ay(i, members(j)) = (y2 - y1)/r;
        else
            Ax(i, members(j)) = (x1-x2)/r;
            Ay(i, members(j)) = (y1 - y2)/r;
        end
    end
end
total_length = total_length/2;
total_cost = total_cost + total_length;
Ax_final = [Ax, Sx];
Ay_final = [Ay, Sy];
A = [Ax_final; Ay_final];
T = A\L;

%Live load:
x = find(L) - C_rows; %joint x is where load is applied
x_members = find(Ay(x, :));
y_force = 0; %Total force upwards opposing the load
for i = 1:length(x_members)
    y_force = y_force + (Ay(x, x_members(i)) * T(x_members(i)));
end
max_load = y_force / 9.8; %theoretical max load
%Buckling member:
F = 3654.533 .* buckling_length .^(-2.119); %force of buckling

disp('EK301, Section A6, Ethan L., Margaret H., Micheal M., 11/17/2023');
disp('Load: 25 N');
disp('Member forces in oz');

for i = 1:length(T) - 3
    if T(i) > 0
        fprintf('m%d: %.2f (C)\n', i, T(i));
    else
        fprintf('m%d: %.2f (T)\n', i, T(i));
    end
end
disp('Reaction forces in N:');
fprintf('Sx1: %.2f\n', T(length(T)-2));
fprintf('Sx2: %.2f\n', T(length(T)-1));
fprintf('Sx3: %.2f\n', T(length(T)));
fprintf('Total cost: %.2f\n', total_cost);
fprintf('Theoretical max load/cost ratio in oz/$: %f\n', max_load/total_cost);
fprintf('Member number: %d\n', buckling_member);
fprintf('Member length: %f\n', buckling_length);
fprintf('Predicted buckling strength: %f\n', F);







