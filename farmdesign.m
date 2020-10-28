function farm = farmdesign
% structure with farm properties
%
% Output: farm.()
%   z_cult; depth of cultivation, [m]
%   x,y,z; dimension of farm [m]
%   dx,dy,dz; bin size [m] 
%   seeding; initial seeding biomass

%% farm dimensions and grid

    farm.z_cult = 20; %[m below surface]
    farm.z      = farm.z_cult; % [m]
    farm.dz     = 1; % [m]
    farm.seeding= 100; % seeding biomass [g-dry m-1]; 
    
end
