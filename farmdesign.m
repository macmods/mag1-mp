function farm = farmdesign
% structure with farm properties
%
% Output: farm.()
%   z_cult; depth of cultivation, [m]
%   x,y,z; dimension of farm [m]
%   dx,dy,dz; bin size [m] 
%   farm.frondcount is a pre-allocation term

%% farm dimensions and grid

    farm.z_cult = 20; %[m below surface]
    farm.x      = 1; % [m]
    farm.y      = 1; % [m]
    farm.z      = farm.z_cult; % [m]
    farm.dx     = 1; % [m]
    farm.dy     = 1; % [m]
    farm.dz     = 1; % [m]
        
%% track fronds (preallocate and initialize)

    farm.frondcount = 300; % typically need less than 50 per year;

end
